package landing.game.mainGame.entity.editor
{
	import flash.display.DisplayObject;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FixtureDef;

	import landing.game.mainGame.entity.editor.Mount;

	public class MountSliced extends Mount
	{
		static private const DEFAULT_WIDTH:Number = 300 / WallShadow.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 217.55 / WallShadow.PIXELS_TO_METRE;
		static private const DEFAULT_SLICE:Number = 82 / WallShadow.PIXELS_TO_METRE;
		static private const SLICE_RATIO:Number = DEFAULT_SLICE / DEFAULT_WIDTH;

		public function MountSliced(view:DisplayObject=null, fixtureDef:b2FixtureDef = null, defaultWidth:Number = NaN, defaultHeight:Number = NaN)
		{
			view = view ? view : new MountSlicedView;
			defaultWidth = !isNaN(defaultWidth) ? defaultWidth : DEFAULT_WIDTH;
			defaultHeight = !isNaN(defaultHeight) ? defaultHeight : DEFAULT_HEIGHT;
			super(view, fixtureDef, defaultWidth, defaultHeight);
		}

		override protected function get points():Vector.<b2Vec2>
		{
			var result:Vector.<b2Vec2> = new Vector.<b2Vec2>;
			result.push(new b2Vec2(-(size.x * SLICE_RATIO) / 2 , -size.y / 2));
			result.push(new b2Vec2((size.x * SLICE_RATIO) / 2, -size.y / 2));

			result.push(new b2Vec2(size.x / 2, size.y / 2));
			result.push(new b2Vec2( -size.x / 2 , size.y / 2));
			return result;
		}
	}
}