package game.mainGame.entity.magic
{
	import flash.events.Event;
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
	import game.mainGame.entity.joints.JointSticky;
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;
	import sounds.GameSounds;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class StickyBomb extends GameBody implements ILifeTime, ICastChange, IShoot, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_GHOST_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(9 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, true, b2Body.b2_dynamicBody);

		static private const MAX_LENGTH:int = 100;

		static private const RADIUS:Number = 80 / Game.PIXELS_TO_METRE;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 15 * 1000;
		private var disposed:Boolean = false;

		private var _cast:Cast = null;
		private var oldCastTime:Number;

		private var radius:Number = RADIUS;

		private var _aimCursor:StarlingAdapterSprite = null;

		private var view:StarlingAdapterMovie;
		private var viewStick:StarlingAdapterSprite;

		public var velocity:Number;

		public function StickyBomb():void
		{
			this.view = new StarlingAdapterMovie(new StickyBombExplode());
			this.view.loop = false;
			this.view.gotoAndStop(1);
			addChildStarling(this.view);

			this.viewStick = new StarlingAdapterSprite(new StickyStart());
			this.viewStick.visible = false;
			addChildStarling(this.viewStick);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);
			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(this.velocity, 0)));
		}

		override public function dispose():void
		{
			this._cast = null;

			if (this._aimCursor)
				this._aimCursor = null;

			this.view.stop();
			this.view.removeFromParent(true);

			this.viewStick.removeFromParent(true);

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

			this._lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.lifeTime, this.velocity]);
			result.push([this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.lifeTime = data[1][0];
			this.velocity = data[1][1];

			this.playerId = data[2][0];
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

		public function get aimCursor():StarlingAdapterSprite
		{
			if (this._aimCursor == null)
				this._aimCursor = new StarlingAdapterSprite(new PoiseArrow());

			return this._aimCursor;
		}

		public function onAim(point:Point):void
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
		{
			if (this.fixed || this.disposed)
				return;

			this.fixed = true;

			GameSounds.play("adhesion");

			/*var manifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(manifold);

			var normal:b2Vec2 = manifold.m_normal.GetNegative();

			var angle:Number = Math.abs(Math.atan2(normal.y, normal.x));
			trace("ANGLE = ", angle, this.angle);

			if (this.angle != angle)
				this.angle = angle;

			trace("ROT = ", this.angle);*/

			this.view.addEventListener(Event.COMPLETE, onExplode);
			this.view.play();
		}

		private function onExplode(e:Event):void
		{
			this.view.removeEventListener(Event.COMPLETE, onExplode);

			this.view.visible = false;
			this.viewStick.visible = true;

			if (this.playerId != Game.selfId)
				return;

			for (var body:b2Body = this.gameInst.world.GetBodyList(); body != null; body = body.GetNext())
			{
				var pos:b2Vec2 = body.GetPosition().Copy();
				pos.Subtract(this.position);

				if (!(body.GetUserData() is Hero) || pos.Length() > this.radius || pos.Length() == 0)
					continue;

				body.SetAwake(true);

				var joint:JointSticky = new JointSticky();
				joint.body = this;
				joint.hero = body.GetUserData() as Hero;
				this.gameInst.map.createObjectSync(joint, true);
			}
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}