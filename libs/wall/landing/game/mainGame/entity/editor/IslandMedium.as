package landing.game.mainGame.entity.editor
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FixtureDef;

	public class IslandMedium extends Island
	{
		static private const WIDTH:int = 95;
		static private const HEIGHT:int = 20;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(WIDTH / WallShadow.PIXELS_TO_METRE, HEIGHT / WallShadow.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.0, 500, Island.CATEGORIES_BITS, Island.MASK_BITS, 0);

		public function IslandMedium():void
		{
			super(WIDTH, HEIGHT, Island2, FIXTURE_DEF, SHAPE);
		}
	}
}