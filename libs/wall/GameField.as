package
{
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class GameField extends TextField
	{
		static public const DEFAULT_FONT:String = "Droid Sans";
		static public const DEFAULT_COLOR_TEXT:int = 0x383c3d;
		static public const DEFAULT_COLOR_HTML:int = "#383c3d";

		private var maxWidth:Number;

		public function GameField(value:String, x:Number, y:Number, type:* = null, maxWidth:Number = 0):void
		{
			super();

			this.x = x;
			this.y = y;
			this.maxWidth = maxWidth;

			this.multiline = true;
			this.selectable = false;
			this.embedFonts = true;
			this.antiAliasType = AntiAliasType.ADVANCED;
			this.gridFitType = GridFitType.PIXEL;
			this.thickness = 100;
			this.sharpness = 0;
			this.autoSize = TextFieldAutoSize.LEFT;

			if (type == null)
				type = new StyleSheet();

			if (type is TextFormat)
				setTextValue(value, type);
			else if (type is StyleSheet)
				setHtmlValue(value, type);

			update(this.maxWidth);
		}

		public function centerField():void
		{
			update(this.maxWidth);
		}

		override public function setTextFormat(format:TextFormat, beginIndex:int = -1, endIndex:int = -1):void
		{
			var oldWidth:Number = this.width;

			super.setTextFormat(format, beginIndex, endIndex);

			update(oldWidth);
		}

		override public function set text(value:String):void
		{
			var oldWidth:Number = this.width;

			super.text = value;

			update(oldWidth);
		}

		override public function set htmlText(value:String):void
		{
			var oldWidth:Number = this.width;

			super.htmlText = value;

			update(oldWidth);
		}

		private function update(oldWidth:Number):void
		{
			if (this.maxWidth == 0)
				return;

			this.wordWrap = false;
			this.autoSize = TextFieldAutoSize.LEFT;

			if (this.width > this.maxWidth)
			{
				this.wordWrap = true;
				this.autoSize = TextFieldAutoSize.NONE;
				this.width = this.maxWidth;
			}

			this.x += int((oldWidth - this.width) / 2);
		}

		private function setTextValue(value:String, format:TextFormat):void
		{
			if (format.font == null)
				format.font = DEFAULT_FONT;
			if (format.color == null)
				format.color = DEFAULT_COLOR_TEXT;

			this.defaultTextFormat = format;

			this.text = value;
		}

		private function setHtmlValue(value:String, style:StyleSheet):void
		{
			this.styleSheet = style;

			var styleData:Object = this.styleSheet.getStyle("body");
			if (styleData == null)
				styleData = new Object();
			if (!("fontFamily" in styleData))
				styleData['fontFamily'] = DEFAULT_FONT;
			if (!("color" in styleData))
				styleData['color'] = DEFAULT_COLOR_HTML;
			if (!("fontSize" in styleData))
				styleData['fontSize'] = "11px";

			this.styleSheet.setStyle("body", styleData);

			var styleA:Object = this.styleSheet.getStyle("a");
			if (styleA == null)
				styleA = new Object();
			if (!("textDecoration" in styleA))
				styleA['textDecoration'] = "underline";
			this.styleSheet.setStyle("a", styleA);

			var styleAHover:Object = this.styleSheet.getStyle("a:hover");
			if (styleAHover == null)
				styleAHover = new Object();
			if (!("textDecoration" in styleAHover))
				styleAHover['textDecoration'] = "none";
			this.styleSheet.setStyle("a:hover", styleAHover);

			super.htmlText = value;
		}
	}
}