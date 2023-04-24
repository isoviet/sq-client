package game.mainGame.entity.simple
{
	import flash.filters.GlowFilter;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPersonalObject;
	import sensors.ISensor;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.starling.StarlingAdapterSprite;

	public class BalanceWheel extends GameBody implements ISensor, IPersonalObject
	{
		static private const filter:GlowFilter = new GlowFilter(0xFF3333, 1.0, 6.0, 6.0, 2, 1, true);

		static private const START_SPEED:int = 2;
		static private const END_SPEED:int = 7;
		static private const TIME:Number = 5.0;
		static private const TIME_UPDATE:Number = 3.0;

		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const SHAPE1:b2CircleShape = new b2CircleShape(32 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF1:b2FixtureDef = new b2FixtureDef(SHAPE1, null, 0.8, 0.1, 0.5, CollisionGroup.OBJECT_GHOST_CATEGORY, CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY, 0);

		static private const SHAPE2:b2CircleShape = new b2CircleShape(32 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF2:b2FixtureDef = new b2FixtureDef(SHAPE2, null, 100, 0.1, 1, CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY, CollisionGroup.HERO_CATEGORY, 0);

		private var view:StarlingAdapterSprite = null;
		private var disc:b2Body = null;
		private var joint:b2RevoluteJoint = null;

		private var timeUpdate:Number;

		public var motorSpeed:Number = 0;

		public function BalanceWheel():void
		{
			this.motorSpeed = START_SPEED;
			this.timeUpdate = TIME_UPDATE;

			this.view = new StarlingAdapterSprite(new WheelImg());
			addChildStarling(this.view);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.motorSpeed = Math.min(this.motorSpeed + timeStep * (END_SPEED - START_SPEED) / TIME, END_SPEED);
			if (this.joint)
				this.joint.SetMotorSpeed(this.motorSpeed);
			if (this.disc && this.view)
				this.view.rotation = this.disc.GetAngle() * Game.R2D;

			if (this.personalId != Game.selfId)
				return;
			this.timeUpdate -= timeStep;
			if (this.timeUpdate > 0)
				return;
			this.timeUpdate = TIME_UPDATE;
			Connection.sendData(PacketClient.ROUND_SYNC, PacketClient.SYNC_PLAYER, [this.id, this.position.x, this.position.y, this.angle, this.linearVelocity.x, this.linearVelocity.y, this.angularVelocity]);
		}

		override public function build(world:b2World):void
		{
			this.filters = this.personalId == Game.selfId ? [filter] : [];

			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF2);
			super.build(world);

			this.disc = world.CreateBody(BODY_DEF);
			this.disc.CreateFixture(FIXTURE_DEF1);
			this.disc.SetPositionAndAngle(this.position, this.angle);
			this.body.SetFixedRotation(true);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(this.body, this.disc, this.disc.GetWorldCenter());
			jointDef.collideConnected = false;
			jointDef.enableMotor = true;
			jointDef.motorSpeed = this.motorSpeed;
			jointDef.maxMotorTorque = 100000000;
			this.joint = this.body.GetWorld().CreateJoint(jointDef) as b2RevoluteJoint;
		}

		override public function dispose():void
		{
			if (this.joint)
			{
				this.body.GetWorld().DestroyJoint(this.joint);
				this.joint = null;
			}
			if (this.disc)
			{
				for (var fixture:b2Fixture = this.disc.GetFixtureList(); fixture; fixture = fixture.GetNext())
					fixture.SetUserData(null);
				this.disc.SetUserData(null);
				this.disc.GetWorld().DestroyBody(this.disc);
				this.disc = null;
			}
			this.view = null;
			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.playerId]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (impulse) {/*unused*/}

			var otherObject:* = contact.GetFixtureA().GetBody().GetUserData();
			if (otherObject == this)
				otherObject = contact.GetFixtureB().GetBody().GetUserData();

			if (otherObject is BalanceWheel)
				contact.SetEnabled(false);
		}

		public function get personalId():int
		{
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId != playerId;
		}
	}
}