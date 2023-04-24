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
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.perks.PerkController;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterMovie;

	public class AntimagicBody extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(65 / Game.PIXELS_TO_METRE, 5 / Game.PIXELS_TO_METRE, new b2Vec2(0, -0.5));
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var view:StarlingAdapterMovie = null;

		private var hero:Hero = null;

		public function AntimagicBody():void
		{
			this.view = new StarlingAdapterMovie(new AntimagicImg);
			this.view.loop = true;
			this.view.stop();
			addChildStarling(this.view);

			this.fixed = true;
		}

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

			releaseHero();

			super.dispose();
		}

		public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero || hero.inHollow || hero.isHare || hero.isDead)
				return;

			if (hero.id > 0 && hero.id != Game.selfId)
				return;

			var manifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(manifold);

			var normal:b2Vec2 = manifold.m_normal.Copy();

			if (contact.GetFixtureB().GetUserData() == this)
				normal = normal.GetNegative();

			var upVector:b2Vec2 = ((this.body != null) ? new b2Vec2(Math.cos(this.body.GetAngle() - Math.PI / 2), Math.sin(this.body.GetAngle() - Math.PI / 2)) : new b2Vec2(0, 0));

			if (b2Math.Dot(normal, upVector) < 0.5)
				return;

			antimagicSquirrel(hero);
		}

		public function endContact(contact:b2Contact):void
		{
			if (!this.hero)
				return;

			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero || this.hero != hero)
				return;

			releaseHero();
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function antimagicSquirrel(hero:Hero):void
		{
			this.hero = hero;

			hero.perksAvailable = false;
			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			hero.perkController.deactivateClothesPerks();
			hero.perkController.deactivateManaPerks();

			var controller:PerkController = hero.perkController;
			for (var i:int = controller.perksCharacter.length - 1; i >= 0; i--)
			{
				if (!(controller.perksCharacter[i].active))
					continue;
				controller.perksCharacter[i].active = false;
				hero.sendLocation(-controller.perksCharacter[i].code);
			}
		}

		private function onEvent(e:Event):void
		{
			releaseHero();
		}

		private function releaseHero():void
		{
			if (!this.hero)
				return;

			this.hero.perksAvailable = true;
			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
			this.hero = null;
		}
	}
}