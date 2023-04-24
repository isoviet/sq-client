package views
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	public class LabledInput extends Sprite
	{
		public var label:TextField = new TextField();
		public var input:TextField = new TextField();

		public function LabledInput(labelText:String):void
		{
			addChild(this.label);

			this.input.width = 100;
			this.input.height = 20;
			this.input.type = TextFieldType.INPUT;
			this.input.background = true;
			this.input.backgroundColor = 0xFFFFFF;
			this.input.border = true;
			this.input.borderColor = 0x000000;
			addChild(this.input);

			this.labelText = labelText;
			update();
		}

		public function set labelText(value:String):void
		{
			this.label.text = value;
			update();
		}

		private function update():void
		{
			this.label.width = this.label.textWidth + 10;
			this.label.height = this.label.textHeight + 10;

			this.input.x = label.textWidth + 10;
		}
	}
}