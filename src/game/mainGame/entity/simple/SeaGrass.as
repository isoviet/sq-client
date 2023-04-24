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
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IJumpable;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterSprite;

	public class SeaGrass extends GameBody implements ISensor, IJumpable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(79 / 2 / Game.PIXELS_TO_METRE, 75 / 2 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		public function SeaGrass():void
		{
			addChildStarling(new StarlingAdapterSprite(new SeaGrassView));
			this.fixed = true;
			this.alignPivot();
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);

			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);

			if (contact.GetFixtureA().GetUserData() == this)
				slowDown(contact.GetFixtureB().GetBody(), worldManifold.m_points[0]);
			else
				slowDown(contact.GetFixtureA().GetBody(), worldManifold.m_points[1]);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function slowDown(body:b2Body, position:b2Vec2):void
		{
			if (body == this.body || (position.x == 0 && position.y == 0))
				return;

			var velocity:b2Vec2 = body.GetLinearVelocity();
			var torque:Number = body.GetAngularVelocity();

			velocity.x *= 0.8;
			velocity.y *= 0.8;

			torque *= 0.8;

			body.SetLinearVelocity(velocity);
			body.SetAngularVelocity(torque);
		}
	}
}