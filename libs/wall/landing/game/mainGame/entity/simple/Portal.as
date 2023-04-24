package landing.game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.SquirrelGame;
	import landing.sensors.PortalSensor;

	public class Portal extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(20 / WallShadow.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_staticBody);

		public var sensor:PortalSensor;
		public var game:SquirrelGame;

		public function Portal():void
		{

		}

		override public function get ghost():Boolean
		{
			return false;
		}

		override public function set ghost(value:Boolean):void
		{
			super.ghost = false;
		}

		override public function get angle():Number
		{
			return 0;
		}

		override public function set angle(value:Number):void
		{
			super.angle = 0;
		}

		override public function build(world:b2World):void
		{
			this.game = world.userData;
			this.body = world.CreateBody(BODY_DEF);
			sensor = new PortalSensor(this.body.CreateFixture(FIXTURE_DEF));
			super.build(world);
		}

		override public function dispose():void
		{
			super.dispose();
			sensor = null;
		}
	}
}