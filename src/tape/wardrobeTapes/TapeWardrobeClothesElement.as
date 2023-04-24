package tape.wardrobeTapes
{
	import flash.text.TextFormat;

	import tape.TapeSelectableObject;
	import views.ClothesImageLoader;

	public class TapeWardrobeClothesElement extends TapeSelectableObject
	{
		static private const BUTTON_WIDTH:int = 110;
		static private const BUTTON_HEIGHT:int = 115;

		static private const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 10, 0x663300, true, null, null, null, null, "center");

		protected var icon:ClothesImageLoader;

		public function TapeWardrobeClothesElement(itemId:int):void
		{
			super(itemId);
		}

		override protected function init():void
		{
			super.init();

			this.backSelected = new ElementPackageBackSelected();
			this.backSelected.width = BUTTON_WIDTH;
			this.backSelected.height = BUTTON_HEIGHT;
			addChild(this.backSelected);

			this.back = new ElementPackageBack();
			this.back.width = BUTTON_WIDTH;
			this.back.height = BUTTON_HEIGHT;
			addChild(this.back);

			this.icon = new ClothesImageLoader(this.id);
			this.icon.scaleX = this.icon.scaleY = 0.4;
			this.icon.x = int((BUTTON_WIDTH - this.icon.width) * 0.5);
			this.icon.y = BUTTON_HEIGHT - this.icon.height - 5;
			addChild(this.icon);

			var field:GameField = new GameField(ClothesData.getTitleById(this.id), 0, 5, FORMAT);
			field.width = BUTTON_WIDTH;
			field.wordWrap = true;
			addChild(field);
		}
	}
}