package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.PinUtil;
	import sensors.ISensor;
	import sounds.GameSounds;

	import utils.starling.StarlingAdapterMovie;

	public class Bouncer extends GameBody implements IPinable, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(29 / Game.PIXELS_TO_METRE, 8 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const SHAPE2:b2PolygonShape = b2PolygonShape.AsOrientedBox(22 / Game.PIXELS_TO_METRE, 2 / Game.PIXELS_TO_METRE, new b2Vec2(0, -8 / Game.PIXELS_TO_METRE));

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const FIXTURE_DEF2:b2FixtureDef = new b2FixtureDef(SHAPE2, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
		static private const PINS:Array = [[0, 0]];

		protected var sensorFixture:b2Fixture;
		protected var view:StarlingAdapterMovie;

		public var bouncingFactor:Number = 250;

		public function Bouncer():void
		{
			this.view = new StarlingAdapterMovie(new BouncerView());
			this.view.stop();
			this.view.loop = false;
			addChildStarling(this.view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			this.sensorFixture = this.body.CreateFixture(FIXTURE_DEF2);
			this.sensorFixture.SetUserData(this);

			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.bouncingFactor]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.bouncingFactor = data[1][0];
		}

		public function beginContact(contact:b2Contact):void
		{
			view.gotoAndPlay(0);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			if (contact.GetFixtureB().GetUserData() == this)
				contact.SetEnabled(this.body.GetTransform().R.col2.y * maniFold.m_normal.y >= 0);
			else
				contact.SetEnabled(!(this.body.GetTransform().R.col2.y * maniFold.m_normal.y >= 0));
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			var hero:Hero = null;
			if (contact.GetFixtureA().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetUserData() as Hero;

			if (contact.GetFixtureB().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetUserData() as Hero;

			if (!hero)
				return;

			GameSounds.play("batut_light");

			hero.velocity = new b2Vec2();
			var bounce:b2Vec2 = this.body.GetTransform().R.col2.Copy();
			bounce.Multiply(-this.bouncingFactor);
			hero.applyImpulse(bounce);

			if (hero.id == Game.selfId)
				GameSounds.playUnrepeatable("batut_medium");
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}
	}
}