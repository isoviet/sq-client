package
{
	import flash.text.TextFormat;

	import fl.controls.listClasses.CellRenderer;

	public class ListStyleRendererLocation extends CellRenderer
	{
		public function ListStyleRendererLocation():void
		{
			setStyle("skin", ListSkin);
			setStyle("upSkin", ListItemUpSkin);
			setStyle("downSkin", ListItemDownSkin);
			setStyle("overSkin", ListItemDownSkin);
			setStyle("selectedUpSkin", ListItemDownSkin);
			setStyle("selectedDownSkin", ListItemDownSkin);
			setStyle("selectedOverSkin", ListItemDownSkin);
			setStyle("textFormat", new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000, true));
			setStyle("embedFonts", true);
			setStyle("textFormat", new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000, true));
			setSharedStyle("textFormat", new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000, true));
		}

		override public function set data(arg0:Object):void
		{
			super.data = arg0;

			setStyle("textFormat", new TextFormat(GameField.DEFAULT_FONT, 12, arg0['marked']? 0xFF0000 : 0x000000, true));
		}
	}
}