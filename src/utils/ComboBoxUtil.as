package utils
{
	import flash.text.TextFormat;

	import fl.controls.ComboBox;

	public class ComboBoxUtil
	{
		static public function style(comboBox:ComboBox, dropDownStyle: TextFormat, fieldStyle:TextFormat):void
		{
			comboBox.setStyle("embedFonts", true);
			comboBox.setStyle('textPadding', 0);
			comboBox.dropdown.setRendererStyle("embedFonts", true);
			comboBox.dropdown.setRendererStyle("textFormat", dropDownStyle);
			comboBox.textField.setStyle("embedFonts", true);
			comboBox.textField.setStyle("textFormat", fieldStyle);
		}

		static public function selectValue(combobox:ComboBox, value:Object):void
		{
			for (var i:int = 0; i < combobox.length; i++)
			{
				var item:Object = combobox.getItemAt(i);
				if (item['value'] != value)
					continue;

				combobox.selectedIndex = i;
				break;
			}
		}
	}
}