package utils
{
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class EditField extends TextField
	{
		static public const MAX_CHARS:int = 32;

		private var focusInFormat:TextFormat;
		private var focusOutFormat:TextFormat;

		private var focusOutText:String;

		public function EditField(valueFocusOut:String, x:Number, y:Number, width:Number, height:Number, formatFocusOut:TextFormat, formatFocusIn:TextFormat = null, maxChars:int = MAX_CHARS):void
		{
			super();

			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.type = TextFieldType.INPUT;
			this.border = true;
			this.borderColor = 0x1E0000;
			this.background = true;
			this.backgroundColor = 0xFFFFFF;
			this.defaultTextFormat = formatFocusOut;
			this.maxChars = maxChars;
			TextFieldUtil.embedFonts(this);

			this.focusOutFormat = formatFocusOut;

			if (formatFocusIn == null)
				this.focusInFormat = formatFocusOut;
			else
				this.focusInFormat = formatFocusIn;

			this.focusOutText = valueFocusOut;

			FocusOut();

			addEventListener(FocusEvent.FOCUS_IN, FocusIn);
			addEventListener(FocusEvent.FOCUS_OUT, FocusOut);
		}

		private function FocusIn(e:FocusEvent):void
		{
			if (this.type != TextFieldType.INPUT)
				return;

			if (this.text == this.focusOutText)
				this.text = "";

			this.defaultTextFormat = this.focusInFormat;
		}

		private function FocusOut(e:FocusEvent = null):void
		{
			if (this.type != TextFieldType.INPUT)
				return;

			if (this.text == "")
			{
				this.defaultTextFormat = this.focusOutFormat;
				this.text = this.focusOutText;
			}
		}
	}
}