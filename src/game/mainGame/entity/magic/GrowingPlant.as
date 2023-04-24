package game.mainGame.entity.magic
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.setTimeout;

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
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;

	import utils.IntUtil;

	public class GrowingPlant extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_NINJA_CLOUD;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_NINJA;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(1, 0.1);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0, 200, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		static private const GROWTH_DURATION_MAX:int = 35;
		static private const GROWTH_DURATION_MIN:int = 30;

		private var framesCount:int;
		private var startPoint:Point;
		private var direction:b2Vec2;
		private var view:MovieClip;

		private var isStoped:Boolean = false;

		public function GrowingPlant():void
		{
			super();

			init();
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

			this.fixed = true;

			this.direction = this.body.GetTransform().R.col2.Copy();
			this.direction.Multiply(-1);

			this.startPoint = new Point(this.x, this.y);
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.body == null)
				return;

			super.update(timeStep);

			if (timeStep == 0 || this.isStoped)
				return;

			if ((this.view.currentFrame + 1) == this.framesCount)
			{
				destroy();
				this.isStoped = true;
				return;
			}

			this.view.nextFrame();

			var destination:b2Vec2 = this.direction.Copy();
			destination.Multiply(Math.abs(this.view.top.y) / Game.PIXELS_TO_METRE);
			destination.Add(new b2Vec2(this.startPoint.x / Game.PIXELS_TO_METRE, this.startPoint.y / Game.PIXELS_TO_METRE));

			this.position = destination.Copy();

			var viewPoint:Point = new Point(this.x, this.y).subtract(this.startPoint);
			this.view.y = viewPoint.length - 5;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId, this.framesCount]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
			this.framesCount = data[1][1];
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
				contact.SetEnabled(hero.getLocalVector(maniFold.m_normal).y >= 0 && this.playerId == hero.id);
			else
				contact.SetEnabled(!(hero.getLocalVector(maniFold.m_normal).y >= 0) && this.playerId == hero.id);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		override protected function get categoriesBits():uint
		{
			return CATEGORIES_BITS;
		}

		private function init():void
		{
			this.view = new GrowingPlantAnimation();
			this.view.x = -int(this.view.width / 2) - 10;
			this.view.y = -5;
			this.view.stop();
			addChild(this.view);

			this.framesCount = IntUtil.randomInt(GROWTH_DURATION_MIN, GROWTH_DURATION_MAX);
		}

		private function destroy():void
		{
			if (this.body == null)
				return;

			setTimeout(this.gameInst.map.destroyObjectSync, 700, this, true);
		}
	}
}