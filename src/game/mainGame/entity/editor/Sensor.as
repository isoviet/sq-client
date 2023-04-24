package game.mainGame.entity.editor
{
	import flash.display.Shape;
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
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
	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ILags;
	import game.mainGame.ScriptUtils;
	import game.mainGame.entity.INetHidden;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameNet.SquirrelGameNet;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;

	public class Sensor extends GameBody implements ISensor, ISizeable, IEditorDebugDraw, ILags, INetHidden
	{
		static private const CATEGORY:int = CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK:int = CollisionGroup.HERO_CATEGORY | CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY;

		private var _size:b2Vec2 = new b2Vec2(40 / Game.PIXELS_TO_METRE, 40 / Game.PIXELS_TO_METRE);
		private var world:b2World;
		private var execQueue:Array = [];
		private var _contactsCount:int = 0;
		private var beginScriptExecuted:Boolean = false;

		private var currentContacts:Object = {};

		protected var _rect:Boolean = false;
		protected var checkContacts:Boolean = false;

		public var enabled:Boolean = true;
		public var onBeginEnabled:Boolean = true;
		public var onEndEnabled:Boolean = true;

		public var beginContactScript:String = "";
		public var endContactScript:String = "";

		public var activateOnHero:Boolean = true;

		public var activateOnObject:Boolean = true;
		public var haxeScript:Boolean = false;

		public function Sensor():void
		{
			size = size;
			this.fixed = true;
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
			draw();
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(new b2BodyDef(false, false, b2Body.b2_dynamicBody));
			if (rect)
				this.body.CreateFixture(new b2FixtureDef(b2PolygonShape.AsOrientedBox(this.size.x / 2, this.size.y / 2, new b2Vec2()), this, 0, 0, 0.1, CATEGORY, MASK, 0));
			else
				this.body.CreateFixture(new b2FixtureDef(new b2CircleShape(this._size.x / 2), this, 0, 0, 0.1, CATEGORY, MASK, 0));

			super.build(world);
			this.world = world;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([beginContactScript, endContactScript, [this.size.x, this.size.y], enabled, activateOnHero, activateOnObject, onBeginEnabled, onEndEnabled, haxeScript]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var result:Array = data[GameBody.isOldStyle(data) ? 3 : 1];

			this.beginContactScript = result[0];
			this.endContactScript = result[1];
			this.size = new b2Vec2(result[2][0], result[2][1]);
			this.enabled = Boolean(result[3]);
			this.activateOnHero = Boolean(result[4]);
			this.activateOnObject = Boolean(result[5]);

			if (!(6 in result))
				return;

			this.onBeginEnabled = Boolean(result[6]);
			this.onEndEnabled = Boolean(result[7]);

			if (!(8 in result))
				return;
			this.haxeScript = Boolean(result[8]);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);
			while (this.execQueue.length > 0)
			{
				var data:Array = this.execQueue.shift();
				executeScript(data[0], data[1], Boolean(data[2]));
			}
		}

		public function executeScript(script:String, detectedObject:*, forceExecute:Boolean = false):void
		{
			if (!(this.gameInst is SquirrelGameNet) || forceExecute)
			{
				if ((script == beginContactScript && this.contactsCount == 1) || (script == beginContactScript && (this.contactsCount > 0 || forceExecute) && !this.beginScriptExecuted) || (script == endContactScript && this.contactsCount == 0) || !this.checkContacts)
				{
					this.gameInst.scriptUtils.execute(script, this, {'detectedObject':detectedObject}, this.haxeScript ? ScriptUtils.HAXE_SCRIPT : ScriptUtils.LUA_SCRIPT);
					this.beginScriptExecuted = (script == beginContactScript);
				}
			}
			else
			{
				var data:Object = {'Sensor': [this.id, detectedObject ? detectedObject.id : -1, detectedObject is Hero, script == beginContactScript ? 0 : 1]};
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode(data));
			}
		}

		public function beginContact(contact:b2Contact):void
		{
			var otherObject:*;

			if (contact.GetFixtureA().GetUserData() == this)
				otherObject = contact.GetFixtureB().GetBody().GetUserData();
			else
				otherObject = contact.GetFixtureA().GetBody().GetUserData();

			if (otherObject is Hero)
			{
				(otherObject as Hero).addEventListener(Hero.EVENT_DIE, onDie);
				(otherObject as Hero).addEventListener(Hero.EVENT_REMOVE, onRemove);
			}

			if (!enabled || !onBeginEnabled)
				return;

			if ((!this.activateOnHero && (otherObject is Hero)) || (!this.activateOnObject && (otherObject is GameBody)) || otherObject == null)
				return;

			if (otherObject is Hero && !(otherObject as Hero).isSelf)
				return;

			if (!(otherObject is Hero) && (!this.gameInst || !this.gameInst.scriptUtils || !this.gameInst.scriptUtils.isSync))
				return;

			this.contactsCount++;

			onBegin(otherObject);
		}

		public function endContact(contact:b2Contact):void
		{
			var otherObject:*;

			if (contact.GetFixtureA().GetUserData() == this)
				otherObject = contact.GetFixtureB().GetBody().GetUserData();
			else
				otherObject = contact.GetFixtureA().GetBody().GetUserData();

			if (otherObject is Hero)
			{
				(otherObject as Hero).removeEventListener(Hero.EVENT_DIE, onDie);
				(otherObject as Hero).removeEventListener(Hero.EVENT_REMOVE, onRemove);

				if ((otherObject.id > 0) && (!(otherObject.id in this.currentContacts) || this.currentContacts[otherObject.id] != 1))
					return;
			}

			if (!enabled || !onEndEnabled)
				return;

			if ((!this.activateOnHero && (otherObject is Hero)) || (!this.activateOnObject && ((otherObject is GameBody) || otherObject == null)))
				return;

			if (otherObject is Hero && !(otherObject as Hero).isSelf)
				return;

			if (!(otherObject is Hero) && !this.gameInst.scriptUtils.isSync)
				return;

			this.contactsCount--;

			onEnd(otherObject);
		}

		public function estimateLags():Number
		{
			return 0.1 * (int(this.onEndEnabled) + int(this.onBeginEnabled));
		}

		private function onDie(e:Event):void
		{
			var otherObject:Hero = e.currentTarget as Hero;
			otherObject.removeEventListener(Hero.EVENT_DIE, onDie);

			if ((otherObject.id > 0) && (!(otherObject.id in this.currentContacts) || this.currentContacts[otherObject.id] != 1))
				return;

			if (!this.activateOnHero)
				return;

			if (!(otherObject as Hero).isSelf)
				return;

			this.contactsCount--;

			onEnd(otherObject);
		}

		private function onRemove(e:Event):void
		{
			var otherObject:Hero = e.currentTarget as Hero;
			otherObject.removeEventListener(Hero.EVENT_REMOVE, onRemove);

			if ((otherObject.id > 0) && (!(otherObject.id in this.currentContacts) || this.currentContacts[otherObject.id] != 1))
				return;

			if (!this.activateOnHero)
				return;

			this.contactsCount--;

			onEnd(otherObject, true);
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		override public function set showDebug(value:Boolean):void
		{
			super.showDebug = value;

			this.visible = value;
		}

		public function get size():b2Vec2
		{
			return _size;
		}

		public function set size(value:b2Vec2):void
		{
			if (!rect)
				value.x = value.y = Math.max(value.x, value.y);

			value.x = Math.max(value.x, 0);
			value.y = Math.max(value.y, 0);

			_size = value;
			draw();
		}

		public function get rect():Boolean
		{
			return _rect;
		}

		public function set rect(value:Boolean):void
		{
			_rect = value;
			this.draw();
		}

		public function get contactsCount():int
		{
			return _contactsCount;
		}

		public function set contactsCount(value:int):void
		{
			_contactsCount = value;
		}

		override public function dispose():void
		{
			super.dispose();
			this.world = null;
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORY;
		}

		protected function onBegin(otherObject:*, force:Boolean = false):void
		{
			if (otherObject is Hero)
				this.currentContacts[otherObject.id] = 1;

			executeScriptQueue(beginContactScript, otherObject, force);
		}

		protected function onEnd(otherObject:*, force:Boolean = false):void
		{
			if (otherObject is Hero)
				this.currentContacts[otherObject.id] = 0;

			executeScriptQueue(endContactScript, otherObject, force);
		}

		protected function draw():void
		{
			while (this.numChildren > 0)
				this.removeChildStarlingAt(0, true);

			var shape: Shape = new Shape();

			shape.graphics.clear();
			shape.graphics.lineStyle(1, 0x000000, 0.5);
			shape.graphics.beginFill(0xFFFFFF, 0.5);
			if (rect)
				shape.graphics.drawRect(-_size.x / 2 * Game.PIXELS_TO_METRE, -_size.y / 2 * Game.PIXELS_TO_METRE, _size.x * Game.PIXELS_TO_METRE, _size.y * Game.PIXELS_TO_METRE);
			else
				shape.graphics.drawCircle(0, 0, _size.x / 2 * Game.PIXELS_TO_METRE);
			shape.graphics.endFill();

			this.addChildStarling(new StarlingAdapterSprite(shape));
		}

		private function executeScriptQueue(script:String, detectedObject:*, forceExecute:Boolean = false):void
		{
			this.execQueue.push([script, detectedObject, forceExecute]);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var result:Object = packet.dataJson;
			if (!('Sensor' in result))
				return;

			var data:Array = result['Sensor'];
			if (data[0] != this.id)
				return;

			var objectId:int = data[1];
			var isHero:Boolean = Boolean(data[2]);
			var func:Function = data[3] == 0 ? onBegin : onEnd;

			if (packet.playerId != Game.selfId)
				this.contactsCount += data[3] == 0 ? 1 : -1;

			func(isHero ? this.gameInst.squirrels.get(objectId) : this.gameInst.map.getObject(objectId), true);
		}
	}
}