package  
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class LabledInput extends Sprite 
	{
		public var labelField:TextField = new TextField();
		public var inputField:TextField = new TextField();

		public function LabledInput(labelText:String = "") 
		{
			this.labelField.text = labelText;
			this.labelField.width = this.labelField.textWidth + 10;
			this.labelField.height = 20;
			addChild(this.labelField);

			this.inputField.x = this.labelField.width;
			this.inputField.width = 150;
			this.inputField.height = 20;
			this.inputField.background = true;
			this.inputField.type = TextFieldType.INPUT;
			this.inputField.backgroundColor = 0xC0C0C0;
			addChild(this.inputField);
		}
	}
}