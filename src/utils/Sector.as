package utils
{
	import flash.display.Graphics;
	import flash.display.Sprite;

	public class Sector extends Sprite
	{
		private var maskSprite:Sprite = new Sprite();

		private var _start:Number = 0;
		private var _end:Number = 0;
		private var _color:int = 0;
		private var _radius:Number = 10;

		public function Sector():void
		{
			this.mask = this.maskSprite;
			addChild(this.mask);
		}

		public function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(this.color, 1);
			this.graphics.drawCircle(0, 0, this.radius);

			this.maskSprite.graphics.clear();
			this.maskSprite.graphics.beginFill(0, 1);
			this.maskSprite.graphics.moveTo(0, 0);
			drawLine(this.maskSprite.graphics, start);
			drawLine(this.maskSprite.graphics, (start + end) * 0.25);
			drawLine(this.maskSprite.graphics, (start + end) * 0.5);
			drawLine(this.maskSprite.graphics, (start + end) * 0.75);
			drawLine(this.maskSprite.graphics, end);
			this.maskSprite.graphics.lineTo(0, 0);
		}

		public function drawLine(graphics:Graphics, angle:Number):void
		{
			graphics.lineTo(Math.sin(angle) * this.radius * 2, Math.cos(angle) * this.radius * 2);
		}

		public function get start():Number
		{
			return this._start;
		}

		public function set start(value:Number):void
		{
			this._start = value;
			draw();
		}

		public function get end():Number
		{
			return this._end;
		}

		public function set end(value:Number):void
		{
			this._end = value;
			draw();
		}

		public function get color():int
		{
			return this._color;
		}

		public function set color(value:int):void
		{
			this._color = value;
			draw();
		}

		public function get radius():Number
		{
			return this._radius;
		}

		public function set radius(value:Number):void
		{
			this._radius = value;
			draw();
		}
	}

}