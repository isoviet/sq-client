package utils
{
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import fl.controls.CheckBox;

	public class TextFieldUtil
	{
		static private const DEFAULT_TEXT_FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000, false);

		static public function embedFonts(field:TextField):void
		{
			field.embedFonts = true;
			field.antiAliasType = AntiAliasType.ADVANCED;
			field.gridFitType = GridFitType.PIXEL;
			field.thickness = 100;
			field.sharpness = 0;
		}

		static public function formatField(field:TextField, name:String, width:int, isHtml:Boolean = false, isLink:Boolean = true, id:int = 0):void
		{
			do
			{
				if (!isHtml)
					field.text = name;
				else
				{
					if (isLink)
						field.htmlText = "<body><a class='name' href='event:" + id + "'>" + name + "</a></body>";
					else
						field.htmlText = "<body><a class='name'>" + name + "</a></body>";
				}
				name = name.substr(0, name.length - 1);
			}
			while (field.textWidth > width);
		}

		static public function setStyleCheckBox(checkBox:CheckBox, textFormat:TextFormat = null):void
		{
			if (textFormat == null)
				textFormat = DEFAULT_TEXT_FORMAT;

			checkBox.setStyle("textFormat", textFormat);
			checkBox.setStyle("embedFonts", true);
			checkBox.setStyle("antiAliasType", AntiAliasType.ADVANCED);
			checkBox.setStyle("gridFitType", GridFitType.PIXEL);
			checkBox.setStyle("thickness", 100);
			checkBox.setStyle("sharpness", 0);
		}
	}
}