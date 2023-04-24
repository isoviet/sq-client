package views
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	public class ElementShopInfoDesk extends Sprite
	{
		static  private const FORMAT_TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 12, 0xFFFFFF);
		static  private const FORMAT_VALUE:TextFormat = new TextFormat(null, 12, 0xFF4A27, true);

		private var fieldText:GameField;
		private var fieldValue:GameField;

		public function ElementShopInfoDesk():void
		{
			this.graphics.beginFill(0xFF4A27);
			this.graphics.drawRoundRectComplex(0, 0, 64, 18, 5, 0, 5, 0);
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRoundRectComplex(64, 0, 106, 18, 0, 5, 0, 5);

			this.fieldText = new GameField("", 0, 0, FORMAT_TEXT);
			addChild(this.fieldText);
			this.fieldValue = new GameField("", 0, 0, FORMAT_VALUE);
			addChild(this.fieldValue);

			this.mouseEnabled = false;
		}

		public function set text(value:String):void
		{
			this.fieldText.text = value;
			this.fieldText.x = 30 - int(this.fieldText.textWidth * 0.5);
		}

		public function set value(value:String):void
		{
			this.fieldValue.text = value;
			this.fieldValue.x = 115 - int(this.fieldValue.textWidth * 0.5);
		}
	}
}