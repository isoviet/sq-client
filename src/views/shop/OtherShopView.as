package views.shop
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import buttons.ButtonFooterTab;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import tape.TapeDataSelectable;
	import tape.shopTapes.TapeShopCast;
	import tape.shopTapes.TapeShopCastElement;
	import tape.shopTapes.TapeShopDrink;
	import tape.shopTapes.TapeShopDrinkElement;
	import tape.shopTapes.TapeShopEmotionElement;
	import tape.shopTapes.TapeShopEmotions;

	public class OtherShopView extends Sprite
	{
		static private const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653)];

		private var buttonsGroup:ButtonTabGroup = null;

		public function OtherShopView()
		{
			this.y = 105;

			this.buttonsGroup = new ButtonTabGroup();
			this.buttonsGroup.x = 15;

			var tapeDrink:TapeShopDrink = new TapeShopDrink();
			var data:TapeDataSelectable = new TapeDataSelectable(TapeShopDrinkElement);
			data.setData(DrinkItemsData.items);
			tapeDrink.setData(data);
			addChild(tapeDrink);

			this.buttonsGroup.insert(new ButtonTab(new ButtonFooterTab(gls("Эликсиры"), FORMATS, ButtonTabShopLarge, 15)), tapeDrink);

			var tapeCast:TapeShopCast = new TapeShopCast();
			data = new TapeDataSelectable(TapeShopCastElement);
			data.setData(CastItemsData.items);
			tapeCast.setData(data);
			addChild(tapeCast);

			var button:ButtonTab = new ButtonTab(new ButtonFooterTab(gls("Предметы шамана"), FORMATS, ButtonTabShopLarge, 15));
			button.x = 220;

			this.buttonsGroup.insert(button, tapeCast);
			addChild(this.buttonsGroup);

			var tapeEmotions:TapeShopEmotions = new TapeShopEmotions();
			data = new TapeDataSelectable(TapeShopEmotionElement);
			data.setData([0]);
			tapeEmotions.setData(data);
			addChild(tapeEmotions);

			button = new ButtonTab(new ButtonFooterTab(gls("Эмоции"), FORMATS, ButtonTabShopLarge, 15));
			button.x = 440;

			this.buttonsGroup.insert(button, tapeEmotions);
			addChild(this.buttonsGroup);
		}
	}
}