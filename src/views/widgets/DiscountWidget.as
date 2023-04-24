package views.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	public class DiscountWidget extends Sprite
	{
		static public const FORMAT_DISCOUNT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 24, 0xFFFFFF);

		private var fieldDiscount:GameField = null;

		public function DiscountWidget(text:String = "", imageFilters:Array = null):void
		{
			this.rotation = -15;

			var image:DisplayObject = new DiscountImage();
			image.scaleX = image.scaleY = 2.0;
			image.rotation = 15;
			if (imageFilters != null)
				image.filters = imageFilters;
			addChild(image);

			var field:GameField = new GameField(text== "" ? gls("Выгода") : text, 0, 40, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF));
			field.x = int((image.width - field.textWidth) * 0.5) - 5;
			addChild(field);

			this.fieldDiscount = new GameField("", 0, 60, FORMAT_DISCOUNT);
			addChild(this.fieldDiscount);
		}

		public function set discount(value:int):void
		{
			this.fieldDiscount.text = value + "%";
			this.fieldDiscount.x = (value > 999 ? 39 : 43) - int(this.fieldDiscount.textWidth * 0.5);
		}
	}
}