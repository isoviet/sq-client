package game.mainGame.entity.shaman
{
	import flash.display.DisplayObject;

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
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;

	import com.greensock.TweenMax;

	public class DeathCloud extends GameBody implements ISensor, IPinFree, ILifeTime
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(2, 0.05);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_kinematicBody);

		static private const FLOW_SPEED:Number = 4;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 0;
		private var disposed:Boolean = false;

		private var viewCloud:DisplayObject = null;

		public var perkLevel:int = 0;

		public function DeathCloud():void
		{
			super();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.perkLevel, this.aging, this.lifeTime]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.perkLevel = data[1][0];
			this.aging = Boolean(data[1][1]);
			this.lifeTime = data[1][2];
		}

		override public function build(world:b2World):void
		{
			this.viewCloud = this.perkLevel != 0 ? new DeathCloudImg() : new DeathCloudGhostImg();
			addChild(this.viewCloud);

			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10000, this.categoriesBits, MASK_BITS, 0)).SetUserData(this);

			super.build(world);

			this.linearVelocity = this.body.GetWorldVector(new b2Vec2(0, -FLOW_SPEED * (this.perkLevel >= 2 ? 0.5 : 1)));
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
			{
				if (!this.aging || this.disposed)
					return;

				this._lifeTime -= timeStep * 1000;

				if (lifeTime <= 0)
					destroy();
			}
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

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			var hero:Hero = null;
			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			else if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (contact.GetFixtureB().GetUserData() == this)
				contact.SetEnabled(hero.getLocalVector(maniFold.m_normal).y >= 0 && this.perkLevel != 0);
			else
				contact.SetEnabled(!(hero.getLocalVector(maniFold.m_normal).y >= 0) && this.perkLevel != 0);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		override protected function get categoriesBits():uint
		{
			return this.perkLevel != 0 ? CATEGORIES_BITS : CollisionGroup.OBJECT_NONE_CATEGORY;
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			TweenMax.to(this, 0.1, {'alpha': 0, 'onComplete': death});
		}

		private function death():void
		{
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}