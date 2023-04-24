package landing.game.mainGame.entity.simple
{
	import flash.display.DisplayObject;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.entity.IPinable;
	import landing.game.mainGame.entity.PinUtil;

	public class BoxIce extends GameBody implements IPinable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY ;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(20 / WallShadow.PIXELS_TO_METRE, 20 / WallShadow.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.1, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
		static private const PINS:Array = [[-20 / WallShadow.PIXELS_TO_METRE, 0], [0, 0], [20 / WallShadow.PIXELS_TO_METRE, 0]];

		public function BoxIce():void
		{
			var view:DisplayObject = new IceBox1();
			view.x = -20;
			view.y = -20;
			addChild(view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}
	}
}