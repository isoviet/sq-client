package game.mainGame.entity.simple
{
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.Cast;
	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.cast.ICastChange;
	import sensors.ISensor;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterSprite;

	public class GunPoise extends GameBody implements ILifeTime, ICastChange, IShoot, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(11 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const MAX_LENGTH:int = 200;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 5 * 1000;
		private var disposed:Boolean = false;

		private var _cast:Cast = null;
		private var oldCastTime:Number;

		private var _aimCursor:StarlingAdapterSprite = null;

		public var velocity:Number;

		public function GunPoise():void
		{
			addChildStarling(new StarlingAdapterSprite(new GunPoiseImg));
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetBullet(true);
			super.build(world);
			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(this.velocity, 0)));
		}

		override public function dispose():void
		{
			this._cast = null;

			if (this._aimCursor)
				this._aimCursor = null;

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;

			this.body.SetBullet(this.body.GetLinearVelocity().Length() > 100);

			if (!this.aging || this.disposed)
				return;

			this.lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.lifeTime, this.velocity, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.lifeTime = data[1][0];
			this.velocity = data[1][1];
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

		public function set cast(cast:Cast):void
		{
			this._cast = cast;
		}

		public function setCastParams():void
		{
			this.oldCastTime = this._cast.castTime;

			this._cast.castTime = 0;
		}

		public function resetCastParams():void
		{
			if (!this._cast)
				return;

			this._cast.castTime = this.oldCastTime;
		}

		public function get maxVelocity():Number
		{
			return this.velocity;
		}

		public function get aimCursor(): StarlingAdapterSprite
		{
			if (this._aimCursor == null)
				this._aimCursor = new StarlingAdapterSprite(new PoiseArrow());

			return this._aimCursor;
		}

		public function onAim(point: Point):void
		{
			var mousePosition:b2Vec2 = new b2Vec2(point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE);
			var weaponAngle:Number = Math.atan2(mousePosition.y - this.position.y, mousePosition.x - this.position.x);

			point = point.subtract(new Point(this.x, this.y));

			this._aimCursor.x = this.x;
			this._aimCursor.y = this.y;
			this._aimCursor.rotation = 0;
			this._aimCursor.scaleX = 1;
			this.velocity = Math.min(int(point.length), MAX_LENGTH);
			this._aimCursor.scaleX = this.velocity / this._aimCursor.width;
			this._aimCursor.rotation = weaponAngle * Game.R2D;
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (hero == null)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (hero == null || hero.id != this.playerId)
				return;
			if (this.lifeTime <= 4500)
				return;

			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

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