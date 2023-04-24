package landing.game.mainGame.entity.view
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;

	import utils.GeomUtil;

	public class RopeView extends Sprite
	{
		static private const BITMAP:BitmapData = new RopeSegmentRastr();
		private var _start:Point = new Point();
		private var _end:Point = new Point();
		private var _offset:Number = 0;
		private var drawSprite:Sprite = new Sprite();

		public function RopeView()
		{
			addChild(drawSprite);
			drawSprite.y = -BITMAP.height / 2;
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

		public function set offset(value:Number):void
		{
			this._offset = value;
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
			this.drawSprite.graphics.clear();
			this.drawSprite.graphics.beginBitmapFill(BITMAP, new Matrix(1, 0, 0, 1, _offset, 0));
			this.drawSprite.graphics.drawRect(0, 0, this.length, BITMAP.height);
			this.drawSprite.graphics.endFill();
		}
	}

}