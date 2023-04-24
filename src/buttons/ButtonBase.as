package buttons
{
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	import sounds.GameSounds;
	import sounds.SoundConstants;

	import utils.ColorMatrix;

	public class ButtonBase extends Sprite
	{
		static private const DEFAULT_FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF);

		static protected const MIN_SIZE:int = 80;
		static protected const PART_SIZE:int = MIN_SIZE * 0.5;
		static protected const OFFSET_X:int = 16;

		static protected const FILTERS:Array = [null, [10, 0, 10, -20], [10, 0, -4, -103], null];
		static protected const TEXT_FILTER:Array = [new DropShadowFilter(0.5, 45, 0x147A3F, 1.0, 1.0, 1.0), new BevelFilter(0.5, 45, 0xFFFFFF, 1.0, 0x06643C, 1.0, 1.0, 1.0)];

		static private var LEFT_BITMAP:BitmapData = null;
		static private var MIDDLE_BITMAP:BitmapData = null;
		static private var RIGHT_BITMAP:BitmapData = null;

		static private var filterBlue:ColorMatrixFilter = null;
		static private var filterRed:ColorMatrixFilter = null;

		static private var inited:Boolean = false;

		protected var _width:int = 0;

		protected var _enabled:Boolean = true;
		protected var callback:Function = null;

		public var button:SimpleButton = null;
		public var field:GameField = null;

		static private function init():void
		{
			if (inited)
				return;
			inited = true;

			if (!LEFT_BITMAP)
			{
				LEFT_BITMAP = new BitmapData(PART_SIZE, 28, true, 0x000000FF);
				LEFT_BITMAP.draw(new ButtonBaseLeft);
			}
			if (!MIDDLE_BITMAP)
			{
				MIDDLE_BITMAP = new BitmapData(4, 28, true, 0x000000FF);
				MIDDLE_BITMAP.draw(new ButtonBaseMiddle);
			}
			if (!RIGHT_BITMAP)
			{
				RIGHT_BITMAP = new BitmapData(PART_SIZE, 28, true, 0x000000FF);
				RIGHT_BITMAP.draw(new ButtonBaseRight);
			}
		}

		public function ButtonBase(text:String = "", width:int = 0, textSize:int = 14, callback:Function = null):void
		{
			this._width = width;

			init();

			this.callback = callback;

			this.button = new SimpleButton();
			this.button.addEventListener(MouseEvent.CLICK, click);

			addChild(this.button);

			this.field = new GameField(text, 0, 0, textSize == 14 ? DEFAULT_FORMAT : new TextFormat(GameField.PLAKAT_FONT, textSize, 0xFFFFFF));
			this.field.mouseEnabled = false;
			this.field.filters = TEXT_FILTER;
			addChild(this.field);

			draw();
		}

		public function click(e:Event = null):void
		{
			if(this._enabled)
			{
				GameSounds.play(SoundConstants.BUTTON_CLICK, true);
				if (this.callback != null)
					this.callback(e);
			}
			else
			{
				GameSounds.play("error", true);
			}
		}

		public function setBlue():void
		{
			if (!filterBlue)
			{
				var colorMatrix:ColorMatrix = new ColorMatrix();
				colorMatrix.adjustColor(0, 0, 0, 70);
				filterBlue = new ColorMatrixFilter(colorMatrix);
			}
			this.button.filters = [filterBlue];
			this.button.downState.filters = [];
		}

		public function setRed():void
		{
			if (!filterRed)
			{
				var colorMatrix:ColorMatrix = new ColorMatrix();
				colorMatrix.adjustColor(-50, 20, 0, -110);
				filterRed = new ColorMatrixFilter(colorMatrix);
			}
			this.button.filters = [filterRed];
			this.button.downState.filters = [];
		}

		public function get enabled():Boolean
		{
			return this._enabled;
		}

		public function set enabled(value:Boolean):void
		{
			if(this.callback == null)
				this.mouseEnabled = this.mouseChildren = value;

			this._enabled = value;
		}

		public function redraw():void
		{
			draw(true);
		}

		public function centerField():void
		{
			this.field.x = int((this._width - this.field.textWidth) * 0.5) - 3;
			this.field.y = int((this.button.height - this.field.textHeight) * 0.5) - 2;
		}

		public function clear():void
		{
			while (this.numChildren > 0)
				removeChildAt(0);
			addChild(this.button);
			addChild(this.field);
		}

		protected function draw(redraw:Boolean = false):void
		{
			if (this._width == 0 || redraw)
				this._width = OFFSET_X * 2 + this.field.textWidth;
			this._width = Math.max(MIN_SIZE, this._width);

			var states:Array = [];
			for (var i:int = 0; i < 4; i++)
			{
				var state:Sprite = new Sprite();
				state.graphics.beginBitmapFill(LEFT_BITMAP);
				state.graphics.drawRect(0, 0, PART_SIZE, 28);
				state.graphics.beginBitmapFill(RIGHT_BITMAP, new Matrix(1, 0, 0, 1, this._width - PART_SIZE));
				state.graphics.drawRect(this._width - PART_SIZE, 0, PART_SIZE, 28);
				if (this._width > MIN_SIZE)
				{
					state.graphics.beginBitmapFill(MIDDLE_BITMAP, new Matrix(this._width - MIN_SIZE + 2, 0, 0, 1));
					state.graphics.drawRect(PART_SIZE - 1, 0, this._width - MIN_SIZE + 2, 28);
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

			centerField();
		}
	}
}