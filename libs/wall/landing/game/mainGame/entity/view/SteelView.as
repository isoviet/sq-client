package landing.game.mainGame.entity.view
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;

	import utils.GeomUtil;

	public class SteelView extends Sprite
	{
		static private const BITMAP:BitmapData = new RopeSegmentRastr();
		private var _start:Point = new Point();
		private var _end:Point = new Point();
		private var steel:Steel = new Steel();

		public function SteelView()
		{
			addChild(steel);
		}

		public function set start(value:Point):void
		{
			this._start = value;
			this.x = value.x;
			this.y = value.y;
			draw();
			calcRotation();
		}

		public function set end(value:Point):void
		{
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
			steel.width = this.length;
		}
	}

}