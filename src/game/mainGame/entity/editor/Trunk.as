package game.mainGame.entity.editor
{
	import flash.display.DisplayObject;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FixtureDef;

	import game.mainGame.entity.editor.Mount;

	public class Trunk extends Mount
	{
		static private const DEFAULT_WIDTH:Number = 60 / Game.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 300 / Game.PIXELS_TO_METRE;
		static private const DEFAULT_SLICE:Number = 32 / Game.PIXELS_TO_METRE;
		static private const SLICE_RATIO:Number = DEFAULT_SLICE / DEFAULT_WIDTH;

		public function Trunk(view:DisplayObject=null, fixtureDef:b2FixtureDef = null, defaultWidth:Number = NaN, defaultHeight:Number = NaN):void
		{
			view = view ? view : new TrunkView();
			defaultWidth = !isNaN(defaultWidth) ? defaultWidth : DEFAULT_WIDTH;
			defaultHeight = !isNaN(defaultHeight) ? defaultHeight : DEFAULT_HEIGHT;
			super(view, fixtureDef, defaultWidth, defaultHeight);
		}

		override public function get landSound():String
		{
			return "land_wood";
		}

		override protected function get points():Vector.<b2Vec2>
		{
			var result:Vector.<b2Vec2> = new Vector.<b2Vec2>;
			result.push(new b2Vec2(-(size.x * SLICE_RATIO) / 2, -size.y / 2));
			result.push(new b2Vec2((size.x * SLICE_RATIO) / 2, -size.y / 2));

			result.push(new b2Vec2(size.x / 2, size.y / 2));
			result.push(new b2Vec2(-size.x / 2, size.y / 2));
			return result;
		}
	}
}