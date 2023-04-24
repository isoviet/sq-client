package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.view.RopeView;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Trap extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(33 / Game.PIXELS_TO_METRE, 5 / Game.PIXELS_TO_METRE, new b2Vec2(0, -4 / Game.PIXELS_TO_METRE));
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const ROPE_LENGTH:int = 70;

		static private const TIME_TO_UNLEASH:int = 5 * 1000;

		static private const SPEED_BONUS_FACTOR:int = 50;

		static private const STATE_OPENED:int = 0;
		static private const STATE_CLOSED:int = 1;
		static private const STATE_UNLEASHED:int = 2;

		private var view:StarlingAdapterMovie = null;

		private var _state:int = STATE_OPENED;

		private var hero:Hero = null;

		private var jointToHero:b2Joint = null;
		private var jointToWorld:b2Joint = null;

		private var ropeDefinition:b2DistanceJointDef = null;
		private var ropeView:RopeView = null;

		private var pullTime:int = 0;

		private var buff:BuffRadialView = null;
		private var timer:Timer = new Timer(50, 100);

		private var runBonus:Number = 0;
		private var ropeEndPoint:StarlingAdapterSprite = null;

		private var deserializedData:Array = null;

		public var ropeLength:int = ROPE_LENGTH / Game.PIXELS_TO_METRE;

		public function Trap():void
		{
			this.view = new StarlingAdapterMovie(new TrapView());
			this.view.x = 0;
			this.view.y = 0;
			this.view.loop = false;
			this.view.gotoAndStop(0);
			addChildStarling(this.view);

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function get angle():Number
		{
			return 0;
		}

		override public function set angle(value:Number):void
		{}

		override public function get rotation():Number
		{
			return 0;
		}

		override public function set rotation(value:Number):void
		{}

		override public function hitTestPointStarling(localPoint: Point):Boolean
		{
			return this.view.hitTestPointStarling(localPoint);
		}

		override public function set filters(filter:Array):void
		{
			this.view.filters = filter;
		}

		override public function serialize():*
		{
			var data:Array = super.serialize();
			data.push([this.ropeLength]);
			if (this.hero)
				data[data.length - 1].push([this.hero.id, this.state, [this.ropeDefinition.localAnchorA.x, this.ropeDefinition.localAnchorA.y]]);
			return data;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var dataPointer:Array = data.pop();
			this.ropeLength = dataPointer[0];

			if (dataPointer.length < 2)
				return;

			this.deserializedData = dataPointer[1];
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetUserData(this);

			super.build(world);

			this.ropeDefinition = new b2DistanceJointDef();
			this.ropeDefinition.bodyA = this.body.GetWorld().GetGroundBody();
			this.ropeDefinition.bodyB = this.body;
			this.ropeDefinition.localAnchorB = new b2Vec2();
			this.ropeDefinition.frequencyHz = 3;
			this.ropeDefinition.rope = true;
			this.ropeDefinition.length = this.ropeLength;

			this.ropeView = new RopeView();
			this.ropeView.visible = false;
			this.ropeView.start = new Point(0, 0);
			addChildStarling(this.ropeView);

			this.ropeEndPoint = new StarlingAdapterSprite(new RopeToTrapEnd);
			this.ropeEndPoint.visible = false;
			addChildStarling(this.ropeEndPoint);

			if (!this.deserializedData)
				return;

			this.position = new b2Vec2(this.deserializedData[2][0], this.deserializedData[2][1]);

			if (this.deserializedData[1] == STATE_CLOSED)
				captureHero(this.deserializedData[0]);

			this.ropeDefinition.localAnchorA = new b2Vec2(this.deserializedData[2][0], this.deserializedData[2][1]);

			if (this.deserializedData[1] != STATE_UNLEASHED)
				return;

			this.hero = this.gameInst.squirrels.get(this.deserializedData[0]);
			this.state = STATE_CLOSED;
			unleashSquirrel();
		}

		override public function dispose():void
		{
			releaseHero(true);

			if (this.jointToWorld)
				this.body.GetWorld().DestroyJoint(this.jointToWorld);

			this.jointToWorld = null;

			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			this.view.removeEventListener(Event.COMPLETE, onAnimation);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.jointToWorld && (this.ropeView.length > (this.ropeLength * Game.PIXELS_TO_METRE + 4)))
			{
				this.pullTime += timeStep * 1000;
				if (this.pullTime >= TIME_TO_UNLEASH)
					commandUnleashHero();
			}
			else
				this.pullTime = 0;

			if (!this.jointToWorld)
				return;

			var vec:b2Vec2 = b2Math.SubtractVV(this.jointToWorld.GetAnchorA(), this.position);
			vec.Multiply(Game.PIXELS_TO_METRE);
			this.ropeEndPoint.x = vec.x;
			this.ropeEndPoint.y = vec.y;
			this.ropeView.end = new Point(vec.x, vec.y);
		}

		public function get empty():Boolean
		{
			return this.hero == null;
		}

		public function beginContact(contact:b2Contact):void
		{
			if (this.ghost || this.state != STATE_OPENED)
			{
				contact.SetEnabled(false);
				return;
			}

			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (!hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (hero == null)
				return;

			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			var normal:b2Vec2 = maniFold.m_normal.Copy();

			if (contact.GetFixtureB().GetUserData() == this)
				normal = normal.GetNegative();

			var upVector:b2Vec2 = ((this.body != null) ? new b2Vec2(Math.cos(this.body.GetAngle() - Math.PI / 2), Math.sin(this.body.GetAngle() - Math.PI / 2)) : new b2Vec2(0, 0));

			if (b2Math.Dot(normal, upVector) < 0.5)
				return;

			if (hero.isDead || hero.inHollow || this.hero || hero.hasJoints("trap"))
				return;

			commandCaptureHero(hero);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (this.ghost || this.state != STATE_OPENED)
				contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function commandCaptureHero(hero:Hero):void
		{
			if (hero.id > 0 && hero.id != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				captureHero(hero.id);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'trapSquirrel': [this.id, hero.id]}));
		}

		public function commandReleaseHero():void
		{
			if (this.hero && this.hero.id > 0 && this.hero.id != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				releaseHero();
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'trapRemove': [this.id]}));
		}

		private function commandUnleashHero():void
		{
			if (this.hero && this.hero.id > 0 && this.hero.id != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				unleashSquirrel();
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'trapUnleash': [this.id]}));
		}

		private function captureHero(heroId:int):void
		{
			if (!this.gameInst || this.hero != null || this.state != STATE_OPENED)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || hero.hasJoints("trap"))
				return;

			this.hero = hero;

			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(SquirrelEvent.LEAVE, onEvent);
			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(Hero.EVENT_TELEPORT, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			this.ropeDefinition.localAnchorA = this.body.GetPosition().Copy();

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyB = this.body;
			hero.bindToRevoluteJointDef(jointDef);
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2(0, 2);
			jointDef.localAnchorB = new b2Vec2();
			jointDef.lowerAngle = 0;
			jointDef.upperAngle = 0;
			jointDef.enableLimit = true;
			this.jointToHero = this.body.GetWorld().CreateJoint(jointDef);
			this.jointToHero.SetUserData("trap");

			this.state = STATE_CLOSED;

			this.runBonus = 0;
		}

		private function releaseHero(onDispose:Boolean = false):void
		{
			if (!this.hero)
				return;

			this.hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			this.hero.removeEventListener(SquirrelEvent.LEAVE, onEvent);
			this.hero.removeEventListener(Hero.EVENT_TELEPORT, onEvent);
			this.hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
			this.hero.removeEventListener(SquirrelEvent.RESET, onEvent);

			if (this.runBonus != 0)
				this.hero.runSpeed += this.runBonus;

			if (this.jointToHero)
			{
				this.body.GetWorld().DestroyJoint(this.jointToHero);
				this.jointToHero = null;
			}

			if (this.timer.running)
			{
				this.timer.reset();
				this.hero.removeBuff(this.buff, this.timer);
			}

			if (!onDispose)
				this.state = STATE_OPENED;
			this.hero = null;
		}

		private function unleashSquirrel():void
		{
			if (!this.hero || this.state != STATE_CLOSED)
				return;

			if (!this.buff)
				this.buff = new BuffRadialView(new TrapView, 0.7, 0.5, gls("Белка в капкане бежит на 50% медленне."));

			this.hero.addBuff(buff, this.timer);

			this.runBonus = this.hero.runSpeed * SPEED_BONUS_FACTOR / 100;
			this.hero.runSpeed -= this.runBonus;

			this.timer.reset();
			this.timer.start();

			this.state = STATE_UNLEASHED;
		}

		private function onEvent(e:Event):void
		{
			releaseHero();
		}

		private function set state(value:int):void
		{
			if (this._state == value)
				return;

			this._state = value;

			switch (value)
			{
				case STATE_OPENED:
					addChildStarlingAt(this.view, 0);
					this.view.scaleXY(1);
					this.view.gotoAndStop(0);
					this.view.y = 0;
					this.ropeView.visible = false;
					this.ropeEndPoint.visible = false;
					this.position = this.ropeDefinition.localAnchorA.Copy();
					break;
				case STATE_CLOSED:
					if (this.jointToWorld == null)
						this.jointToWorld = this.body.GetWorld().CreateJoint(this.ropeDefinition);

					if (this.hero.heroView is IStarlingAdapter)
					{
						this.view.y = this.hero.height / 2 - this.view.height / 2;
						this.hero.addChildStarling(this.view);
						this.view.scaleXY(1);
					}

					this.view.play();
					this.view.addEventListener(Event.COMPLETE, onAnimation);
					this.hero.isStoped = true;

					this.ropeView.visible = true;
					this.ropeEndPoint.visible = true;
					break;
				case STATE_UNLEASHED:
					if (this.jointToWorld)
					{
						this.body.GetWorld().DestroyJoint(this.jointToWorld);
						this.jointToWorld = null;
					}

					this.ropeView.visible = false;
					this.ropeEndPoint.visible = false;
					break;
			}
		}

		private function get state():int
		{
			return this._state;
		}

		private function onAnimation(e:Event):void
		{
			this.hero.isStoped = false;
			this.view.removeEventListener(Event.COMPLETE, onAnimation);
		}

		private function onComplete(e:TimerEvent):void
		{
			commandReleaseHero();
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('trapSquirrel' in data)
			{
				if (data['trapSquirrel'][0] != this.id)
					return;

				captureHero(data['trapSquirrel'][1]);
			}

			if ('trapRemove' in data)
			{
				if (data['trapRemove'][0] != this.id)
					return;

				releaseHero();
			}

			if ('trapUnleash' in data)
			{
				if (data['trapUnleash'][0] != this.id)
					return;

				unleashSquirrel();
			}
		}
	}
}