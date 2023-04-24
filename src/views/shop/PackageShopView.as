package views.shop
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import buttons.ButtonFooterTab;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;

	import utils.FiltersUtil;

	public class PackageShopView extends Sprite
	{
		static private const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653)];

		private var buttonsGroup:ButtonTabGroup = null;

		public function PackageShopView()
		{
			addChild(new ImageShopPackageBack).y = 105;

			this.buttonsGroup = new ButtonTabGroup();
			this.buttonsGroup.x = 15;
			this.buttonsGroup.y = 105;
			addChild(this.buttonsGroup);

			this.buttonsGroup.insert(new ButtonTab(new ButtonFooterTab(gls("Белка"), FORMATS, ButtonTabShopLarge, 15)), addChild(new SquirrelShopView));
			var button:ButtonTab = new ButtonTab(new ButtonFooterTab(gls("Шаман"), FORMATS, ButtonTabShopLarge, 15));
			button.x = 220;
			this.buttonsGroup.insert(button, addChild(new ShamanShopView));

			button = new ButtonTab(new ButtonFooterTab(gls("Дракоша"), FORMATS, ButtonTabShopLarge, 15));
			button.filters = FiltersUtil.GREY_FILTER;
			button.block = true;
			button.x = 440;
			this.buttonsGroup.insert(button);

			button = new ButtonTab(new ButtonFooterTab(gls("Заяц неСудьбы"), FORMATS, ButtonTabShopLarge, 15));
			button.filters = FiltersUtil.GREY_FILTER;
			button.block = true;
			button.x = 660;
			this.buttonsGroup.insert(button);
		}
	}
}