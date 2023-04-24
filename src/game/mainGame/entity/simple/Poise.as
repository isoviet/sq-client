package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.PinUtil;

	import utils.starling.StarlingAdapterSprite;

	public class Poise extends CacheVolatileBody implements IPinable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(13.5 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const PINS:Array = [[0, 0]];

		protected var view:StarlingAdapterSprite;

		public function Poise():void
		{
			this.view = new StarlingAdapterSprite(new PoiseL());
			this.view.x = -13.5;
			this.view.y = -13.5;
			addChildStarling(this.view);
		}

		override public function build(world:b2World):void
		{
			if (!world)
				return;

			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			this.body.SetBullet(true);
			super.build(world);
			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(-200, 0)));
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
				this.body.SetBullet(this.body.GetLinearVelocity().Length() > 100);
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}
	}
}