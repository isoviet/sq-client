package game.mainGame.entity.magic
{
	import flash.display.MovieClip;

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
	import game.mainGame.entity.IGhost;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import sensors.ISensor;

	public class Blizzard extends GameBody implements ISensor, ILifeTime, IGhost
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(80 / 2 / Game.PIXELS_TO_METRE, 75 / 2 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 5000;

		private var disposed:Boolean = false;

		public function Blizzard():void
		{
			var view:MovieClip = new BlizzardView();
			view.x = 5;
			view.y = 10;
			addChild(view);
			this.fixed = true;
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;
			if (!this.aging || this.disposed)
				return;

			this.lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
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

			var hero:Hero = (contact.GetFixtureA().GetUserData() as Hero);
			if (!hero)
				hero = (contact.GetFixtureB().GetUserData() as Hero);

			if (!hero || hero.id == this.playerId || hero.shaman)
				return;
			if (hero.perkController.getPerkLevel(PerkClothesFactory.WOLF_BLIZZARD) != -1 && hero.isSquirrel)
				return;

			if (contact.GetFixtureA().GetUserData() == this)
				slowDown(contact.GetFixtureB().GetBody(), worldManifold.m_points[0]);
			else
				slowDown(contact.GetFixtureA().GetBody(), worldManifold.m_points[1]);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			contact.SetEnabled(false);
		}

		private function slowDown(body:b2Body, position:b2Vec2):void
		{
			if (body == this.body || (position.x == 0 && position.y == 0))
				return;

			var velocity:b2Vec2 = body.GetLinearVelocity();
			velocity.x *= 0.5;
			body.SetLinearVelocity(velocity);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.playerId = data[1][2];
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}