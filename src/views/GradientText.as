package views
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	public class GradientText extends Sprite
	{
		private var fieldMask:GameField;
		private var fieldFilters:GameField;

		private var spriteText:Sprite= new Sprite();
		public var colors:Array;

		public function GradientText(text:String = "", format:TextFormat = null, colors:Array = null, filters:Array = null):void
		{
			this.fieldMask = new GameField("", 0, 0, format);
			addChild(this.fieldMask);

			this.fieldFilters = new GameField("", 0, 0, format);
			if (filters != null)
			{
				this.fieldFilters.filters = filters;
				addChild(this.fieldFilters);
			}
			addChild(this.spriteText);

			this.colors = colors == null ? [0x000000, 0xFFFFFF] : colors;
			this.text = text;
		}

		public function get textWidth():Number
		{
			return this.fieldMask.textWidth;
		}

		override public function set width(value:Number):void
		{
			this.fieldMask.width = value;
			this.fieldMask.multiline = true;
			this.fieldMask.wordWrap = true;

			this.fieldFilters.width = value;
			this.fieldFilters.multiline = true;
			this.fieldFilters.wordWrap = true;
		}

		public function set text(value:String):void
		{
			this.fieldMask.text = value;
			this.fieldFilters.text = value;

			this.spriteText.graphics.clear();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(this.fieldMask.width, this.fieldMask.height / this.fieldMask.numLines + 3, Math.PI / 2, 0, 0);
			this.spriteText.graphics.beginGradientFill(GradientType.LINEAR, this.colors, [1, 1], [0x00, 0xBB], matrix, "repeat");
			this.spriteText.graphics.drawRect(0, 0, this.fieldMask.width, this.fieldMask.height + 10);
			this.spriteText.graphics.endFill();
			this.spriteText.mask = this.fieldMask;
		}

		override public function set filters(value:Array):void
		{
			this.fieldFilters.filters = value;
			addChild(this.fieldFilters);
		}
	}
}