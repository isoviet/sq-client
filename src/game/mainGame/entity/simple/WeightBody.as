package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.PinUtil;
	import sensors.ISensor;
	import sounds.GameSounds;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterSprite;

	public class WeightBody extends CacheVolatileBody implements ISensor, IPinable, ILifeTime
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE1:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const SHAPE2:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 15, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
		static private const PINS:Array = [[0, -20 / Game.PIXELS_TO_METRE], [0, 0]];

		private var contacted:Boolean = false;

		private var _aging:Boolean = false;
		private var _lifeTime:Number = 0;
		private var disposed:Boolean = false;

		public function WeightBody():void
		{
			var view: StarlingAdapterSprite = new StarlingAdapterSprite(new Weight);
			view.alignPivot();
			view.y = -10;
			addChildStarling(view);
			view = null;
		}

		override public function build(world:b2World):void
		{
			FIXTURE_DEF.shape = SHAPE1;
			SHAPE1.SetLocalPosition(new b2Vec2(0, 0));
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);

			FIXTURE_DEF.shape = SHAPE2;
			SHAPE2.SetLocalPosition(new b2Vec2(0, -18 / Game.PIXELS_TO_METRE));
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);

			this.contacted = false;

			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime, this.mass]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			if (!('1' in data))
				return;

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.mass = data[1][2];
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
		{
			if ((contact.GetFixtureA().GetUserData() is Hero) || (contact.GetFixtureB().GetUserData() is Hero))
				return;

			this.contacted = true;
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (!this.contacted)
				return;

			this.contacted = false;

			var imp:Number = contact.GetManifold().m_points[0].m_normalImpulse + contact.GetManifold().m_points[1].m_normalImpulse;

			if (imp > 1000)
				GameSounds.playUnrepeatable("girya");
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}

		public function set mass(value:Number):void
		{
			if (!this.body)
				return;

			var massData:b2MassData = new b2MassData();
			this.body.GetMassData(massData);
			massData.mass = value;
			this.body.SetMassData(massData);
		}

		public function get mass():Number
		{
			if (!this.body)
				return 0;

			var massData:b2MassData = new b2MassData();
			this.body.GetMassData(massData);
			return massData.mass;
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
			this.removeFromParent();

			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}