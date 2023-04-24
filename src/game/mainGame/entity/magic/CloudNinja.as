package game.mainGame.entity.magic
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;

	import com.greensock.TweenMax;

	public class CloudNinja extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_NINJA_CLOUD;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_NINJA;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(2, 0.05);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10000, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var viewCloud:MovieClip;
		private var timer:Timer = new Timer(6 * 1000, 1);

		public function CloudNinja(body:b2Body = null):void
		{
			this.viewCloud = new NinjaCloud();
			addChild(this.viewCloud);

			this.fixed = true;

			this.timer.start();
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onRemove);

			super(body);
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

		private function onRemove(e:TimerEvent):void
		{
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onRemove);
			TweenMax.to(this, 1, {'alpha': 0, 'onComplete': death});
		}

		private function death():void
		{
			if (this.body == null)
				return;

			dispose();
		}
	}
}