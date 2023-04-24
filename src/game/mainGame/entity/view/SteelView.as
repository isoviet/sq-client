package game.mainGame.entity.view
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;

	import utils.GeomUtil;
	import utils.ImageUtil;
	import utils.starling.StarlingAdapterSprite;

	public class SteelView extends StarlingAdapterSprite
	{
		private var _start:Point = new Point();
		private var _end:Point = new Point();
		private var bmpData: BitmapData;

		public function SteelView():void
		{
			bmpData = ImageUtil.getBitmapData(new Steel());
		}

		public function set start(value:Point):void
		{
			this._start = value;
			this.x = value.x;
			this.y = value.y;
		}

		public function set end(value:Point):void
		{
			if (this._end.equals(value))
				return;

			this._end = value;
			calcRotation();
			draw();
		}

		public function get length():Number
		{
			return _start.clone().subtract(_end).length;
		}

		private function calcRotation():void
		{
			this.rotation = GeomUtil.getAngle(_start, _end) - 90;
		}

		private function draw():void
		{
			while (numChildren > 0)
				removeChildStarlingAt(0);

			if (!this.length || !bmpData.height)
				return;

			var coverImage:Shape = new Shape();

			coverImage.graphics.beginBitmapFill(bmpData, null, true, false);

			coverImage.graphics.drawRect(0, 0, this.length, bmpData.height);
			coverImage.graphics.endFill();
			var graph: StarlingAdapterSprite = new StarlingAdapterSprite(coverImage);
			this.pivotY = bmpData.height / 2;
			addChildStarling(graph);
		}
	}

}