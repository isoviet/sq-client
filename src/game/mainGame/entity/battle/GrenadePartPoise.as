package game.mainGame.entity.battle
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.PinUtil;
	import game.mainGame.gameBattleNet.HeroBattle;

	import utils.starling.StarlingAdapterSprite;

	public class GrenadePartPoise extends BattlePoise implements IPinable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(5 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 0.1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const PINS:Array = [[0, 0]];

		static public const MAX_VELOCITY:int = 80;
		static public const RELOAD_TIME:int = 200;

		private var targets:Array = [];

		public function GrenadePartPoise():void
		{
			this.view = new StarlingAdapterSprite(new SpikePoiseImage());
			this.view.x = -15;
			this.view.y = -15;
			addChildStarling(this.view);

			this._lifeTime = 500;
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
		}

		override public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (hero == null)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (hero == null || (hero.heroView.hareView && (hero.heroView.hareView as HareView).rock))
				return;
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
			var friendlyFire:Boolean = (creator != null) && (creator.team != Hero.TEAM_NONE) && (creator.team == hero.team);

			var damage:int = ((creator as HeroBattle) == null || !(creator as HeroBattle).extraDamage) ? 1 : 2;
			if (!friendlyFire && creator != null)
				(hero as HeroBattle).assist(creator.player.id, damage);
			(hero as HeroBattle).health -= damage;
			if ((hero as HeroBattle).health == 0)
				if (friendlyFire)
					(hero as HeroBattle).health = 1;
				else
				{
					hero.dieReason = Hero.DIE_BULLET;
					hero.kill(this.playerId);
				}
		}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (contact.GetFixtureA().GetBody().GetUserData() is IShoot && contact.GetFixtureB().GetBody().GetUserData() is IShoot)
				contact.SetEnabled(false);
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result[1].push(this.playerId);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.playerId = data[1][2];
		}

		override public function get maxVelocity():Number
		{
			return MAX_VELOCITY;
		}

		override public function get reloadTime():int
		{
			return RELOAD_TIME;
		}
	}
}