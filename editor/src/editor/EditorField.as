package editor
{
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class EditorField extends TextField
	{
		private var maxWidth:Number;

		public function EditorField(value:String, x:Number, y:Number, type:* = null, maxWidth:Number = 0):void
		{
			super();

			this.x = x;
			this.y = y;
			this.maxWidth = maxWidth;

			this.multiline = true;
			this.selectable = false;
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
			this.defaultTextFormat = format;

			this.text = value;
		}

		private function setHtmlValue(value:String, style:StyleSheet):void
		{
			this.styleSheet = style;

			var styleData:Object = this.styleSheet.getStyle("body");
			if (styleData == null)
				styleData = {};

			this.styleSheet.setStyle("body", styleData);

			var styleAHover:Object = this.styleSheet.getStyle("a:hover");
			if (styleAHover == null)
				styleAHover = {};
			if (!("textDecoration" in styleAHover))
				styleAHover['textDecoration'] = "none";
			this.styleSheet.setStyle("a:hover", styleAHover);

			super.htmlText = value;
		}
	}
}