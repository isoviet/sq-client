package game.mainGame.entity.editor
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FixtureDef;

	public class IslandSmall extends Island
	{
		static private const WIDTH:int = 60;
		static private const HEIGHT:int = 20;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(WIDTH / Game.PIXELS_TO_METRE, HEIGHT / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.0, 200, Island.CATEGORIES_BITS, Island.MASK_BITS, 0);

		public function IslandSmall():void
		{
			super(WIDTH, HEIGHT, Island3, FIXTURE_DEF, SHAPE);
		}
	}
}