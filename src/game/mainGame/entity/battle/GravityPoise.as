package game.mainGame.entity.battle
{
	import flash.utils.getTimer;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.controllers.PlanetController;
	import game.mainGame.gameBattleNet.HeroBattle;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterSprite;

	public class GravityPoise extends BattlePoise
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(12 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static public const MAX_VELOCITY:int = 120;
		static public const RELOAD_TIME:int = 1200;

		private var targets:Array = [];

		private var controller:PlanetController;

		public function GravityPoise():void
		{
			this.view = new StarlingAdapterSprite(new GravityPoiseImage());
			this.view.x = -15;
			this.view.y = -15;
			addChildStarling(this.view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetBullet(true);

			this.controller = new PlanetController();
			this.controller.body = this.body;
			this.controller.affectObjects = false;
			this.controller.affectHero = false;
			this.controller.G = 0;
			this.controller.maxDistance = 0;
			world.AddController(this.controller);

			super.build(world);

			TweenMax.to(this, 1, {'onComplete': activate});
		}

		override public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (hero == null)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (hero == null)
				return;

			if ((this.playerId == hero.id) && ((getTimer() - this.creationTime) <= HeroBattle.SELF_INVULNERABLE_TIME))
			{
				contact.SetEnabled(false);
				return;
			}
			if (!(hero is HeroBattle))
			{
				hero.dieReason = Hero.DIE_BULLET;
				hero.kill(this.playerId);
				return;
			}
			if ((hero as HeroBattle).godMode)
				return;

			if (this.targets.indexOf(hero) != -1)
				return;
			this.targets.push(hero);

			var creator:Hero = this.gameInst.squirrels.get(this.playerId);
			if ((creator != null) && (creator.team != Hero.TEAM_NONE) && (creator.team == hero.team))
				return;

			var damage:int = 3 * (((creator as HeroBattle) == null || !(creator as HeroBattle).extraDamage) ? 1 : 2);
			if (creator != null)
				(hero as HeroBattle).assist(creator.player.id, damage);
			(hero as HeroBattle).health -= damage;
			if ((hero as HeroBattle).health == 0)
			{
				hero.dieReason = Hero.DIE_BULLET;
				hero.kill(this.playerId);
			}
		}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (contact.GetFixtureA().GetBody().GetUserData() is IShoot && contact.GetFixtureB().GetBody().GetUserData() is IShoot)
				contact.SetEnabled(false);

			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (hero == null)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (hero == null || (this.controller && this.controller.affectHero))
				return;

			var creator:Hero = this.gameInst.squirrels.get(this.playerId);
			if (creator != null && creator.team == hero.team && this.playerId != hero.id)
				contact.SetEnabled(false);
		}

		override public function dispose():void
		{
			super.dispose();
			if (!this.controller || !this.controller.GetWorld())
				return;

			this.controller.body = null;
			this.controller.GetWorld().RemoveController(this.controller);
		}

		override public function get maxVelocity():Number
		{
			return MAX_VELOCITY;
		}

		override public function get reloadTime():int
		{
			return RELOAD_TIME;
		}

		private function activate():void
		{
			if (this.body == null)
				return;
			this.controller.affectHero = true;
			this.controller.G = 300;
			this.controller.maxDistance = 10;
		}
	}
}