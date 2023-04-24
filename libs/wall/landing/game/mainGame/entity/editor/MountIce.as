package landing.game.mainGame.entity.editor
{
	import flash.display.DisplayObject;

	import Box2D.Dynamics.b2FixtureDef;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.entity.editor.Mount;

	public class MountIce extends Mount
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY ;
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.1, 0.1, 500, CATEGORIES_BITS, MASK_BITS, 0);

		static private const DEFAULT_WIDTH:Number = 300 / WallShadow.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 300 / WallShadow.PIXELS_TO_METRE;

		public function MountIce(view:DisplayObject=null, fixtureDef:b2FixtureDef = null, defaultWidth:Number = NaN, defaultHeight:Number = NaN)
		{
			view = view ? view : new MountIcedView;
			fixtureDef = fixtureDef ? fixtureDef : FIXTURE_DEF;
			defaultWidth = !isNaN(defaultWidth) ? defaultWidth : DEFAULT_WIDTH;
			defaultHeight = !isNaN(defaultHeight) ? defaultHeight : DEFAULT_HEIGHT;
			super(view, fixtureDef, defaultWidth, defaultHeight);
		}
	}
}