package game.mainGame.entity.editor
{
	import flash.utils.getTimer;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.ScriptUtils;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.gameNet.SquirrelGameNet;

	import by.blooddy.crypto.serialization.JSON;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;

	public class ScriptedTimer extends StarlingAdapterSprite implements IGameObject, IEditorDebugDraw, IUpdate, ISerialize, IDispose
	{
		private var lastFireTime:int;
		private var builded:Boolean = false;
		private var gameInst:SquirrelGame;

		private var _running:Boolean = true;

		public var onTickEnabled:Boolean = true;
		public var tickScript:String = "";

		public var onCompleteEnabled:Boolean = true;
		public var completeScript:String = "";

		public var delay:int = 0;
		public var repeatCount:int = 0;
		public var currentCount:int = 0;

		public var haxeScript:Boolean = false;

		public function ScriptedTimer():void
		{
			this.visible = false;
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
			draw();
		}

		public function build(world:b2World):void
		{
			this.visible = false;
			gameInst = world.userData as SquirrelGame;
			this.builded = true;
		}

		public function serialize():*
		{
			var result:Array = [];
			result.push([tickScript, completeScript, running, delay, repeatCount, currentCount, onTickEnabled, onCompleteEnabled, [this.position.x, this.position.y], this.haxeScript]);
			return result;
		}

		public function deserialize(data:*):void
		{
			var result:Array = data[0];

			this.tickScript = result[0];
			this.completeScript = result[1];
			this.running = Boolean(result[2]);
			this.delay = result[3];
			this.repeatCount = result[4];
			this.currentCount = result[5];
			this.onTickEnabled = Boolean(result[6]);
			this.onCompleteEnabled = Boolean(result[7]);
			this.position = new b2Vec2(result[8][0], result[8][1]);

			if ('9' in result)
				this.haxeScript = Boolean(result[9]);
		}

		public function get id():int
		{
			if ((gameInst == null) || (this.gameInst.map == null))
				return -1;

			return this.gameInst.map.getID(this);
		}

		public function executeScript(script:String, forceExecute:Boolean = false):void
		{
			if (!(this.gameInst is SquirrelGameNet) || forceExecute)
				this.gameInst.scriptUtils.execute(script, this, {}, haxeScript ? ScriptUtils.HAXE_SCRIPT : ScriptUtils.LUA_SCRIPT);
			else
			{
				var data:Object = {'ScriptedTimer' : [this.id, script == tickScript ? 0 : 1]};
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode(data));
			}
		}

		public function set showDebug(value:Boolean):void
		{
			this.visible = value;
		}

		public function dispose():void
		{
			if (parentStarling)
				parentStarling.removeChildStarling(this);

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			this.removeFromParent(true);
		}

		public function update(timeStep:Number = 0):void
		{
			if (!builded || !this.running || this.delay <= 0)
				return;

			var current:int = getTimer();

			if (this.lastFireTime == 0)
				this.lastFireTime = current;

			if ((current - this.lastFireTime) > this.delay)
			{
				if (this.onTickEnabled)
				{
					if (this.gameInst.scriptUtils.isSync)
						executeScript(this.tickScript);
				}

				this.lastFireTime = current;

				if (repeatCount > 0)
				{
					this.currentCount++;
					if (this.currentCount < repeatCount)
						return;

					if (onCompleteEnabled)
					{
						if (this.gameInst.scriptUtils.isSync)
							executeScript(this.completeScript);

						this.running = false;
					}
				}
				else
				{
					reset();
					this.running = true;
				}
			}
		}

		public function set running(value:Boolean):void
		{
			if (this.running == value)
				return;
			this._running = value;
			this.lastFireTime = getTimer();
		}

		public function get running():Boolean
		{
			return this._running;
		}

		public function reset():void
		{
			this.currentCount = 0;
			this.lastFireTime = getTimer();
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		private function draw():void
		{
			var view:StarlingAdapterSprite = new StarlingAdapterSprite(new ScriptedTimerIcon());
			view.x = -view.width / 2;
			view.y = -view.height / 2;
			addChildStarling(view);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var result:Object = packet.dataJson;
			if (!('ScriptedTimer' in result))
				return;

			var data:Array = result['ScriptedTimer'];
			if (data[0] != this.id)
				return;

			var script:String = data[1] == 0 ? tickScript : completeScript;

			executeScript(script, true);
		}
	}
}