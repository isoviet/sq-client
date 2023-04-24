package game.mainGame.entity.editor
{
	import flash.utils.Timer;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.ILags;
	import game.mainGame.ScriptUtils;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameNet.SquirrelGameNet;
	import screens.ScreenStarling;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.RecorderCollection;
	import protocol.packages.server.PacketRoundCommand;

	import starling.display.Button;
	import starling.display.ButtonState;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.BlurFilter;

	import utils.starling.StarlingAdapterSprite;

	public class ClickButton extends GameBody implements ISensor, ISizeable, ILags
	{
		static private const CATEGORY:int = CollisionGroup.OBJECT_NONE_CATEGORY;
		static private const MASK:int = CollisionGroup.OBJECT_NONE_CATEGORY;

		static private var RED_FILTER: BlurFilter;
		static private var GREEN_FILTER: BlurFilter;

		private var _size:b2Vec2 = new b2Vec2(20 / Game.PIXELS_TO_METRE, 20 / Game.PIXELS_TO_METRE);
		private var world:b2World;
		private var execQueue:Array = [];
		private var canClick:Boolean = false;

		private var _clickDelay:int = 2000;

		private var _toggle:Boolean;
		private var downState:StarlingAdapterSprite = new StarlingAdapterSprite(new ClickButtonDown());
		private var upState:StarlingAdapterSprite = new StarlingAdapterSprite(new ClickButtonUp());
		private var delayTimer:Timer = new Timer(clickDelay, 1);

		protected var _rect:Boolean = false;

		public var enabled:Boolean = true;
		public var onScript:String = "";
		public var offScript:String = "";

		public var haxeScript:Boolean = false;

		private var defWidth: int = 0;
		private var defHeight:int = 0;
		private var isMouseIn :Boolean = false;
		private var filter: BlurFilter = null;
		private var button: Button;
		private var buttonState: ButtonState;

		public function ClickButton():void
		{
			button = new Button(upState.texture, '', downState.texture);
			button.alignPivot();
			this.addChildStarling(button);
			button.addEventListener(TouchEvent.TOUCH, onTouchButton);
			button.enabled = false;
			button.overlay.parent.alpha = 1;
			defWidth = downState.width;
			defHeight = downState.height;

			//ScreenStarling.overlay.addChild(button);

			this.toggle = false;
			size = size;
			this.fixed = true;
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
			this.rect = true;

			this.getStarlingView().touchable = true;
			this.getStarlingView().useHandCursor = true;
			this.touchable = true;
		}

		override public function set alpha(value: Number): void {
			super.alpha = value;
			if (this.getStarlingView())
			{
				this.getStarlingView().touchable = true;
				this.getStarlingView().useHandCursor = true;
			}

			this.touchable = true;
		}
		private function onTouchButton(e: starling.events.TouchEvent): void
		{
			var touch:Touch = e.getTouch(button);
			if (!touch)
				return;

			this.canClick =  !this.delayTimer.running && this.enabled && Hero.selfAlive && Hero.self.shaman;
			if (touch && touch.phase == TouchPhase.BEGAN && this.canClick)
				onMouseClick();
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(new b2BodyDef(false, false, b2Body.b2_dynamicBody));
			this.body.CreateFixture(new b2FixtureDef(b2PolygonShape.AsOrientedBox(this.size.x / 2 + 1, this.size.y / 2 + 1, new b2Vec2()), this, 0, 0, 0.1, CATEGORY, MASK, 0));

			super.build(world);
			this.world = world;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([onScript, offScript, [this.size.x, this.size.y], enabled, toggle, clickDelay, haxeScript]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var result:Array = data[GameBody.isOldStyle(data) ? 3 : 1];

			this.onScript = result[0];
			this.offScript = result[1];
			this.size = new b2Vec2(result[2][0], result[2][1]);
			this.enabled = Boolean(result[3]);
			this.toggle = Boolean(result[4]);
			this.clickDelay = result[5];

			if (!(6 in result))
				return;

			this.haxeScript = Boolean(result[6]);
		}

		public function executeScript(script:String, forceExecute:Boolean = false):void
		{
			if (!(this.gameInst is SquirrelGameNet) || forceExecute)
			{
				this.gameInst.scriptUtils.execute(script, this, {}, haxeScript ? ScriptUtils.HAXE_SCRIPT : ScriptUtils.LUA_SCRIPT);
				this.toggle = !this.toggle;
				RecorderCollection.addDataClient(PacketClient.ROUND_COMMAND, [by.blooddy.crypto.serialization.JSON.encode({'ClickButton':[this.id]})]);
			}
			else
			{
				var data:Object = {'ClickButton':[this.id]};
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode(data));
			}
		}

		public function endContact(contact:b2Contact):void
		{}

		public function beginContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
		}

		public function get size():b2Vec2
		{
			return _size;
		}

		public function set size(value:b2Vec2):void
		{
			value.x = value.y = Math.max(value.x, value.y);

			value.x = Math.max(value.x, 0);
			value.y = Math.max(value.y, 0);

			_size = value;

			this.downState.scaleX = this.upState.scaleX = (_size.x * Game.PIXELS_TO_METRE) / defWidth;
			this.downState.scaleY = this.upState.scaleY = (_size.y * Game.PIXELS_TO_METRE) / defHeight;
			button.upState = this.upState.texture;
			button.downState = this.downState.texture;
			button.width = (_size.x * Game.PIXELS_TO_METRE);
			button.height = (_size.y * Game.PIXELS_TO_METRE);
			button.alignPivot();
		}

		public function get rect():Boolean
		{
			return _rect;
		}

		public function set rect(value:Boolean):void
		{
			_rect = value;
		}

		public function get toggle():Boolean
		{
			return _toggle;
		}

		public function set toggle(value:Boolean):void
		{
			_toggle = value;
			this.button.state = value ? ButtonState.DOWN : ButtonState.UP;
		}

		public function get clickDelay():int
		{
			return _clickDelay;
		}

		public function set clickDelay(value:int):void
		{
			_clickDelay = value;
			this.delayTimer.delay = value;
		}

		public function estimateLags():Number
		{
			return 0.1 * (int(this.onScript != "") + int(this.offScript != ""));
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);
			while (execQueue.length > 0)
			{
				var data:Array = execQueue.shift();
				executeScript(data[0], Boolean(data[1]));
			}

			if (!RED_FILTER)
				RED_FILTER = BlurFilter.createGlow(0xff3a33);
			if (!GREEN_FILTER)
				GREEN_FILTER = BlurFilter.createGlow(0xC7FEB1);

			var newFilter: BlurFilter = this.canClick ? GREEN_FILTER : this.delayTimer.running ? RED_FILTER : null;

			if (newFilter)
			{
				filter = newFilter;
				this.button.filter = filter;
			}
		}

		override public function dispose():void
		{
			button.dispose();
			super.dispose();
			this.world = null;
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORY;
		}

		protected function onClick(force:Boolean = false):void
		{
			executeScriptQueue(this.toggle ? offScript : onScript, force);
		}

		private function executeScriptQueue(script:String, forceExecute:Boolean = false):void
		{
			execQueue.push([script, forceExecute]);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var result:Object = packet.dataJson;
			if (!('ClickButton' in result))
				return;

			var data:Array = result['ClickButton'];
			if (data[0] != this.id)
				return;

			onClick(true);
		}

		private function onMouseClick():void
		{
			this.onClick();
			this.delayTimer.reset();
			this.delayTimer.start();
		}

	}
}