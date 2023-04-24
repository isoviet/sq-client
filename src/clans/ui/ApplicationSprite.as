package clans.ui
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	public class ApplicationSprite extends Sprite
	{
		static private const FORMAT_NAME:TextFormat = new TextFormat(null, 13, 0x0074F3, true);
		static private const FORMAT_LEVEL:TextFormat = new TextFormat(null, 13, 0x000000, true, null, null, null, null, "center");
		static private const FORMAT_DATA:TextFormat = new TextFormat(null, 11, 0x623F07, false, null, null, null, null, "right");

		public var fieldName:GameField = null;
		public var fieldLevel:GameField = null;
		public var fieldData:GameField = null;

		public function ApplicationSprite():void
		{
			this.fieldName = new GameField("", 22, 0, FORMAT_NAME);
			addChild(this.fieldName);

			this.fieldLevel = new GameField("", 149, 0, FORMAT_LEVEL);
			this.fieldLevel.width = 35;
			addChild(this.fieldLevel);

			this.fieldData = new GameField("", 187, 2, FORMAT_DATA);
			this.fieldData.width = 85;
			addChild(this.fieldData);
		}
	}
}