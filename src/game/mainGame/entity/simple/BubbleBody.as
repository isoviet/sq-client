package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.controllers.BubbleController;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;

	public class BubbleBody extends GameBody implements IPinFree, ISensor
	{
		static private const COLOR_FILTERS:Array = [
			[new ColorMatrixFilter([0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]), new ColorMatrixFilter([1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0])],
			[new ColorMatrixFilter([0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0]), new ColorMatrixFilter([2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0])],
			[new ColorMatrixFilter([0, 0.5, 0.5, 0, 0, 0.5, 0, 0.5, 0, 0, 0.5, 0.5, 0, 0, 0, 0, 0, 0, 1, 0]), new ColorMatrixFilter([3, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0])]
		];

		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(40 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0, 0.5, 0.1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var view:StarlingAdapterMovie = null;

		private var disposed:Boolean = false;

		private var controller:BubbleController = null;
		private var color:int = 0;

		private var hero:Hero = null;
		private var jointToHero:b2Joint = null;

		private var _touchCount:int = 5;

		private var deserializedId:int = 0;

		private var allowBurst:Boolean = true;

		public var velocity:Number;

		public function BubbleBody():void
		{
			this.view = new StarlingAdapterMovie(new BubbleBodyView);
			this.view.x = 0;
			this.view.y = 0;
			this.view.loop = false;
			addChildStarling(this.view);

			this.color = int(Math.random() * COLOR_FILTERS.length);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);

			super.build(world);

			///this.filters = COLOR_FILTERS[this.color];

			if (this.deserializedId != 0){
				this.view.gotoAndStop(this.view.totalFrames - 1);
				catchHero(this.deserializedId);
			} else {
				this.view.gotoAndPlay(0);
			}

			this.controller = new BubbleController();
			this.controller.bubble = this;
			this.controller.speedLimit = this.velocity;
			world.AddController(this.controller);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function dispose():void {
			if (this.controller) {
				this.controller.bubble = null;
				this.controller.GetWorld().RemoveController(this.controller);
				this.controller = null;
			}

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);
			this.view.removeFromParent(true);

			releaseSquirrel();

			this.visible = false;
			super.dispose();
		}

		override public function serialize():*
		{
			var data:Array = super.serialize();
			data.push([this.color, this.velocity, this.touchCount]);
			if (this.hero)
				data[data.length - 1].push(this.hero.id);
			return data;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var dataPointer:Array = data.pop();
			this.color = dataPointer[0];
			this.velocity = dataPointer[1];
			this.touchCount = dataPointer[2];

			if (dataPointer.length < 4)
				return;

			this.deserializedId = dataPointer[3];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.gameInst && (this.y + 80 < -this.gameInst.map.size.y + Game.ROOM_HEIGHT))
				commandBurstBubble();
		}

		public function set touchCount(value:int):void
		{
			this._touchCount = value;

			if (value <= 0)
				commandBurstBubble();
		}

		public function get touchCount():int
		{
			return this._touchCount;
		}

		public function beginContact(contact:b2Contact):void
		{
			var otherBody:* = contact.GetFixtureA().GetBody().GetUserData();
			if (otherBody == this)
				otherBody = contact.GetFixtureB().GetBody().GetUserData();

			if (otherBody is Hero)
			{
				var hero:Hero = otherBody as Hero;
				if (hero.isDead || hero.inHollow || this.hero || hero.inBubble)
					return;

				commandCatchHero(hero);
				return;
			}

			this.touchCount --;
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var otherBody:* = contact.GetFixtureA().GetBody().GetUserData();
			if (otherBody == this)
				otherBody = contact.GetFixtureB().GetBody().GetUserData();

			if (otherBody is Hero || otherBody is BubbleBody)
				contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function commandCatchHero(hero:Hero):void
		{
			if (hero.id > 0 && hero.id != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				catchHero(hero.id);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'bubbleSquirrel': [this.id, hero.id]}));
		}

		private function commandBurstBubble():void
		{
			if (this.hero && this.hero.id > 0 && this.hero.id != Game.selfId || !this.hero && this.gameInst && !this.gameInst.squirrels.isSynchronizing)
				return;

			if (!this.allowBurst || this.disposed)
				return;

			if (this.gameInst is SquirrelGameEditor)
				burst();
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'bubbleBurst': [this.id]}));

			this.allowBurst = false;
			setTimeout(setAllowBurst, 500);
		}

		private function setAllowBurst():void
		{
			this.allowBurst = true;
		}

		private function catchHero(heroId:int):void
		{
			if (!this.gameInst || this.hero != null)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow)
				return;

			this.hero = hero;

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyA = this.body;
			hero.bindToRevoluteJointDef(jointDef, false);
			jointDef.collideConnected = false;
			jointDef.enableLimit = true;
			jointDef.lowerAngle = 0;
			jointDef.upperAngle = 0;
			jointDef.localAnchorA = new b2Vec2(0, 1);
			jointDef.localAnchorB = new b2Vec2();
			this.jointToHero = this.body.GetWorld().CreateJoint(jointDef);

			hero.inBubble = true;

			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);
			hero.addEventListener(Hero.EVENT_TELEPORT, onEvent);
			hero.addEventListener(Hero.EVENT_REMOVE, onEvent);

			hero.addEventListener(Hero.EVENT_UP, updateTouchCount);
		}

		private function onEvent(e:Event):void
		{
			burst(true);
		}

		private function updateTouchCount(e:Event):void
		{
			this.touchCount--;
		}

		private function destroy():void
		{
			if (this.body == null)
				return;

			releaseSquirrel();
			this.removeFromParent();
			this.gameInst.map.remove(this, true);
		}

		private function releaseSquirrel():void
		{
			if (!this.hero)
				return;

			this.hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			this.hero.removeEventListener(Hero.EVENT_TELEPORT, onEvent);
			this.hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
			this.hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			this.hero.removeEventListener(Hero.EVENT_REMOVE, onEvent);

			this.hero.removeEventListener(Hero.EVENT_UP, updateTouchCount);

			hero.inBubble = false;

			if (!this.body)
				return;

			if (this.jointToHero)
				this.body.GetWorld().DestroyJoint(this.jointToHero);

			this.jointToHero = null;
			this.hero = null;
		}

		private function burst(quick:Boolean = false):void
		{
			if (this.disposed)
				return;

			this.view.stop();
			this.view.visible = false;
			this.disposed = true;

			if (quick)
			{
				dispose();
				return;
			}

			var burstView:StarlingAdapterMovie = new StarlingAdapterMovie(new BubbleBurst());

			burstView.loop = false;
			burstView.play();
			addChildStarling(burstView);

			var onComplete:Function = function ():void
			{
				burstView.removeEventListener(Event.COMPLETE, onComplete);
				burstView.removeFromParent(true);
				burstView = null;
				destroy();
			};

			burstView.addEventListener(Event.COMPLETE, onComplete);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('bubbleSquirrel' in data)
			{
				if (data['bubbleSquirrel'][0] != this.id)
					return;

				catchHero(data['bubbleSquirrel'][1]);
			}

			if ('bubbleBurst' in data)
			{
				if (data['bubbleBurst'][0] != this.id)
					return;

				burst();
			}
		}
	}
}