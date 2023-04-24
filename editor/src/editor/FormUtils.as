package editor
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	public class FormUtils
	{
		static public function setComboBox(owner:ComboBox, parent:Sprite, data:DataProvider, x:int, y:int, width:int):void
		{
			owner.x = x;
			owner.y = y;
			owner.dataProvider = data;
			owner.width = width;
			owner.height = 20;
			owner.rowCount = 10;
			owner.textField.setStyle("textFormat", Formats.FORMAT_EDIT);
			owner.dropdown.setRendererStyle("textFormat", Formats.FORMAT_EDIT);

			parent.addChild(owner);
		}

		static public function setTextField(owner:TextField, parent:Sprite, x:int, y:int, width:int, height:int = 18, maxchars:int = 32, isEdit:Boolean = false):void
		{
			owner.x = x;
			owner.y = y;
			owner.width = width;
			owner.height = height;
			owner.borderColor = 0xb3b3b3;
			owner.defaultTextFormat = Formats.FORMAT_EDIT;
			owner.maxChars = maxchars;

			parent.addChild(owner);

			if (isEdit)
			{
				owner.type = TextFieldType.INPUT;
				owner.border = true;
			}
		}

		static public function switchField(owner:TextField, isEdit:Boolean):void
		{
			if (isEdit)
			{
				owner.type = TextFieldType.INPUT;
				owner.border = true;
			}
			else
			{
				owner.type = TextFieldType.DYNAMIC;
				owner.border = false;
			}
		}
	}
}