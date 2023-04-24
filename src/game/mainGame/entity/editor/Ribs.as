package game.mainGame.entity.editor
{
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Math;
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

	import utils.starling.StarlingAdapterSprite;

	public class Ribs extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(1.5, 1);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0, 500, CATEGORIES_BITS, MASK_BITS);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		public function Ribs():void
		{
			super();
			var spriteView: StarlingAdapterSprite = new StarlingAdapterSprite(new this.viewClass());
			spriteView.alignPivot();

			addChildStarling(spriteView);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetUserData(this);
			super.build(world);

			this.fixed = true;
		}

		public function beginContact(contact:b2Contact):void
		{
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			var normal:b2Vec2 = maniFold.m_normal.Copy();

			if (contact.GetFixtureB().GetUserData() == this)
				normal = normal.GetNegative();

			var upVector:b2Vec2 = ((this.body != null) ? new b2Vec2(Math.cos(this.body.GetAngle() - Math.PI / 2), Math.sin(this.body.GetAngle() - Math.PI / 2)) : new b2Vec2(0, 0));

			if (b2Math.Dot(normal, upVector) < 0.5)
				return;
			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (!hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);
			if ((hero != null) && checkHeroVulnerable(hero))
			{
				hero.dispatchEvent(new Event(Hero.EVENT_DEADLY_CONTACT));
				hero.dieReason = Hero.DIE_SPIKES;
				hero.kill();
			}
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			beginContact(contact);
		}

		protected function get viewClass():Class
		{
			return RibsView;
		}

		private function checkHeroVulnerable(hero:Hero):Boolean
		{
			return !(hero.heroView.hareView && (hero.heroView.hareView as HareView).rock || hero.persian || hero.armadillo || hero.inHollow);
		}
	}
}