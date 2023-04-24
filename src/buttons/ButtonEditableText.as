package buttons
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class ButtonEditableText extends Sprite
	{
		private var button:SimpleButton;

		public var textField:GameField = null;

		public function ButtonEditableText(button:SimpleButton, format:TextFormat, x:int = 0, y:int = 0, textWidth:int = 0):void
		{
			this.button = button;
			addChild(this.button);

			format.align = TextFormatAlign.CENTER;

			this.textField = new GameField("", x, y, format, textWidth);
			this.textField.width = (textWidth == 0 ? this.width : textWidth);
			this.textField.wordWrap = false;
			this.textField.multiline = false;
			this.textField.mouseEnabled = false;
			addChild(this.textField);
		}

		public function centerField():void
		{
			//this.textField.x = int((this.button.width - this.textField.textWidth) * 0.5) - 3;
			this.textField.y = int((this.button.height - this.textField.textHeight) * 0.5) - 2;
		}

		public function get back():SimpleButton
		{
			return this.button;
		}

		public function clear():void
		{
			while (this.numChildren > 0)
				removeChildAt(0);
			addChild(this.button);
			addChild(this.textField);
		}

		public function set enabled(value:Boolean):void
		{
			this.mouseChildren = value;
			this.button.enabled = value;
		}

		public function get enabled():Boolean
		{
			return this.button.enabled;
		}
	}

}