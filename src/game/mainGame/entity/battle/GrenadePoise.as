package game.mainGame.entity.battle
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.editor.Sensor;

	import utils.starling.StarlingAdapterSprite;

	public class GrenadePoise extends BattlePoise
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(5 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 0.1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static public const MAX_VELOCITY:int = 50;
		static public const RELOAD_TIME:int = 800;

		public function GrenadePoise():void
		{
			this.view = new StarlingAdapterSprite(new GrenadePoiseImage());
			this.view.x = -15;
			this.view.y = -15;
			addChildStarling(this.view);

			this._lifeTime = 1000;
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
			var objectA:* = contact.GetFixtureA().GetBody().GetUserData();
			var objectB:* = contact.GetFixtureB().GetBody().GetUserData();
			var hero:Hero = (objectA as Hero);
			if (!hero)
				hero = (objectB as Hero);

			if (objectA is Sensor || objectB is Sensor)
				return;

			if (hero == null)
				destroy();
		}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (contact.GetFixtureA().GetBody().GetUserData() is IShoot && contact.GetFixtureB().GetBody().GetUserData() is IShoot)
				contact.SetEnabled(false);
		}

		override public function get maxVelocity():Number
		{
			return MAX_VELOCITY;
		}

		override public function get reloadTime():int
		{
			return RELOAD_TIME;
		}

		override protected function death():void
		{
			if (this.body == null)
				return;

			if (Game.selfId == this.playerId)
				for (var i:int = 0; i < 8; i++)
				{
					var poise:GrenadePartPoise = new GrenadePartPoise();
					poise.playerId = this.playerId;
					poise.angle = this.body.GetAngle() + Math.PI * i / 4;
					poise.position = this.position.Copy();
					this.gameInst.map.createObjectSync(poise, true);
				}
			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}