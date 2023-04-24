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
	import game.mainGame.entity.IPinFree;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterMovie;

	public class Conveyor extends GameBody implements IPinFree, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsVector(vertices, 0);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const MAX_ANGLE:Number = 0;
		static private const MIN_ANGLE:Number = -Math.PI;

		private var view:StarlingAdapterMovie = null;

		private var timeCounter:Number = 0;
		private var _working:Boolean = false;

		private var bodies:Array = [];

		public var velocity:Number = -5;
		public var delayTime:Number = 2 * 1000;
		public var workTime:Number = 5 * 1000;

		public function Conveyor():void
		{
			this.view = new StarlingAdapterMovie(new ConveyorView);
			this.view.loop = true;
			this.view.stop();
			this.view.x = 0;
			this.view.y = 0;
			addChildStarling(this.view);

			this.fixed = true;
		}

		static private function get vertices():Vector.<b2Vec2>
		{
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			vertices.push(new b2Vec2(-7, -1.25));
			vertices.push(new b2Vec2(7, -1.25));
			vertices.push(new b2Vec2(7.9, 0));
			vertices.push(new b2Vec2(7, 1.25));
			vertices.push(new b2Vec2(-7, 1.25));
			vertices.push(new b2Vec2(-7.9, 0));
			return vertices;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		override public function set angle(value:Number):void
		{}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);

			this.view.play();
		}

		override public function dispose():void
		{
			if (this.view)
				this.view.removeFromParent();
			this.view = null;

			this.bodies = null;

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.timeCounter <= 0)
			{
				this.working = !this.working;
				this.timeCounter = this.working ? this.workTime : this.delayTime;
			}
			else
				this.timeCounter -= timeStep * 1000;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.velocity, this.workTime, this.delayTime, this.working, this.timeCounter]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.velocity = data[1][0];
			this.workTime = data[1][1];
			this.delayTime = data[1][2];
			this.working = Boolean(data[1][3]);
			this.timeCounter = data[1][4];
		}

		public function beginContact(contact:b2Contact):void
		{
			var body:b2Body = null;

			if (contact.GetFixtureA().GetUserData() == this)
				body = contact.GetFixtureB().GetBody();
			else
				body = contact.GetFixtureA().GetBody();

			this.bodies.push(body);
		}

		public function endContact(contact:b2Contact):void
		{
			var body:b2Body = null;

			if (contact.GetFixtureA().GetUserData() == this)
				body = contact.GetFixtureB().GetBody();
			else
				body = contact.GetFixtureA().GetBody();

			var index:int = this.bodies.indexOf(body);
			if (index == -1)
				return;

			this.bodies.push(body);
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (!this.working)
				return;

			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);
			var localPoint:b2Vec2 = this.body.GetLocalPoint(worldManifold.m_points[0]);

			var angle:Number = Math.atan2(localPoint.y, localPoint.x);
			if (MIN_ANGLE > angle || MAX_ANGLE < angle)
				return;

			contact.SetTangentSpeed(this.velocity);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function set working(value:Boolean):void
		{
			if (this._working == value)
				return;

			if (!value && this.delayTime == 0)
				return;

			this._working = value;
			value ? this.view.play() : this.view.stop();

			if (!(value))
				return;

			for (var i:int = this.bodies.length - 1; i >= 0; i--)
				(this.bodies[i] as b2Body).ApplyImpulse(this.body.GetWorldVector(new b2Vec2(0, 0.1)), (this.bodies[i] as b2Body).GetWorldCenter());
		}

		private function get working():Boolean
		{
			return this._working;
		}
	}
}