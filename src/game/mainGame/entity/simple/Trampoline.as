package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.PinUtil;
	import screens.ScreenGame;
	import screens.Screens;
	import sensors.ISensor;
	import sounds.GameSounds;

	import protocol.PacketClient;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Trampoline extends CacheVolatileBody implements IPinable, ISensor, IPersonalObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(29 / Game.PIXELS_TO_METRE, 7 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const SHAPE2:b2PolygonShape = b2PolygonShape.AsOrientedBox(22 / Game.PIXELS_TO_METRE, 3 / Game.PIXELS_TO_METRE, new b2Vec2(0, -5 / Game.PIXELS_TO_METRE));

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const FIXTURE_DEF2:b2FixtureDef = new b2FixtureDef(SHAPE2, null, 0.8, 1.5, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
		static private const PINS:Array = [[0, 0]];

		static private const EXTRA_IMPULSE:int = -100;

		private var sensorFixture:b2Fixture;
		private var view:StarlingAdapterSprite;

		public function Trampoline():void
		{
			this.view = new StarlingAdapterMovie(new TrampolineView());
			addChildStarling(view);
			this.view.stop();
			this.view.loop = false;
		}

		public function get personalId():int
		{
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId != playerId && this.castType == PacketClient.CAST_SQUIRREL && Screens.active is ScreenGame;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			if (breakContact(Game.selfId))
				this.alpha = 0.2;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			this.sensorFixture = this.body.CreateFixture(FIXTURE_DEF2);
			this.sensorFixture.SetUserData(this);

			super.build(world);

			if (breakContact(Game.selfId))
				this.alpha = 0.2;
		}

		public function beginContact(contact:b2Contact):void
		{
			this.view.gotoAndPlay(0);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			var hero:Hero = null;
			if (contact.GetFixtureA().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetUserData() as Hero;

			if (contact.GetFixtureB().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetUserData() as Hero;

			if (!hero)
				return;

			var imp:Number = contact.GetManifold().m_points[0].m_normalImpulse;

			if (hero.id != Game.selfId)
				return;

			if (imp < 400)
				GameSounds.playUnrepeatable("batut_light");
			else if (imp < 550)
				GameSounds.playUnrepeatable("batut_medium");
			else
				GameSounds.playUnrepeatable("batut_heavy");
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}
	}
}