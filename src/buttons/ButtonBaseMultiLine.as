package buttons
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;

	import utils.ColorMatrix;

	public class ButtonBaseMultiLine extends ButtonBase
	{
		static private const SCALE_MAX:Number = 2.0;

		static private var LEFT_BITMAP:BitmapData = null;
		static private var MIDDLE_BITMAP:BitmapData = null;
		static private var RIGHT_BITMAP:BitmapData = null;

		static private var inited:Boolean = false;

		private var scale:Number = 1.0;

		static private function init():void
		{
			if (inited)
				return;
			inited = true;

			var matrix:Matrix = new Matrix(SCALE_MAX, 0, 0, SCALE_MAX);
			if (!LEFT_BITMAP)
			{
				LEFT_BITMAP = new BitmapData(PART_SIZE * SCALE_MAX, 28 * SCALE_MAX, true, 0x000000FF);
				LEFT_BITMAP.draw(new ButtonBaseLeft, matrix);
			}
			if (!MIDDLE_BITMAP)
			{
				MIDDLE_BITMAP = new BitmapData(4 * SCALE_MAX, 28 * SCALE_MAX, true, 0x000000FF);
				MIDDLE_BITMAP.draw(new ButtonBaseMiddle, matrix);
			}
			if (!RIGHT_BITMAP)
			{
				RIGHT_BITMAP = new BitmapData(PART_SIZE * SCALE_MAX, 28 * SCALE_MAX, true, 0x000000FF);
				RIGHT_BITMAP.draw(new ButtonBaseRight, matrix);
			}
		}

		public function ButtonBaseMultiLine(text:String = "", width:int = 0, textSize:int = 14, callback:Function = null, scale:Number = 1.0):void
		{
			init();

			this.scale = scale;

			super(text, width, textSize, callback);
		}

		override protected function draw(redraw:Boolean = false):void
		{
			if (this._width == 0 || redraw)
				this._width = OFFSET_X * 2 + this.field.textWidth;
			this._width = Math.max(MIN_SIZE * this.scale, this._width);

			var states:Array = [];
			for (var i:int = 0; i < 4; i++)
			{
				var state:Sprite = new Sprite();
				state.graphics.beginBitmapFill(LEFT_BITMAP, new Matrix(this.scale / SCALE_MAX, 0, 0, this.scale / SCALE_MAX));
				state.graphics.drawRect(0, 0, PART_SIZE * this.scale, 28 * this.scale);

				state.graphics.beginBitmapFill(RIGHT_BITMAP, new Matrix(this.scale / SCALE_MAX, 0, 0, this.scale / SCALE_MAX, this._width - PART_SIZE * this.scale));
				state.graphics.drawRect(this._width - PART_SIZE * this.scale, 0, PART_SIZE * this.scale, 28 * this.scale);

				if (this._width > MIN_SIZE * this.scale)
				{
					state.graphics.beginBitmapFill(MIDDLE_BITMAP, new Matrix((this._width - MIN_SIZE * this.scale + 2) / SCALE_MAX, 0, 0, this.scale / SCALE_MAX));
					state.graphics.drawRect(PART_SIZE * this.scale - 1, 0, (this._width - MIN_SIZE * this.scale + 2), 28 * this.scale);
				}

				if (FILTERS[i] != null)
				{
					var colorMatrix:ColorMatrix = new ColorMatrix();
					colorMatrix.adjustColor(FILTERS[i][0], FILTERS[i][1], FILTERS[i][2], FILTERS[i][3]);
					state.filters = [new ColorMatrixFilter(colorMatrix)];
				}
				states.push(state);
			}

			this.button.upState = states[0];
			this.button.overState = states[1];
			this.button.downState = states[2];
			this.button.hitTestState = states[3];

			this.field.x = int((this._width - this.field.textWidth) * 0.5) - 3;
			this.field.y = int((this.button.height - this.field.textHeight) * 0.5) - 2;
		}
	}
}