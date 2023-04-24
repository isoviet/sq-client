package views.shop
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.DialogBank;
	import game.gameData.BundleManager;
	import game.gameData.HotWeekendManager;
	import views.ClothesImageSmallLoader;

	import com.api.Services;

	import utils.FieldUtils;

	public class HotWeekendView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "a_PlakatTitul";
				font-size: 15px;
				color: #9A4C0F;
				text-align: center;
			}
			.green {
				color: #1CA81A;
			}
			.red {
				color: #D01A1A;
			}
				]]>).toString();

		static public const FILTERS_CAPTION:Array = [new GlowFilter(0xFFFFFF, 1.0, 4, 4, 8),
								new GlowFilter(0x867754, 1.0, 4, 4, 1)];

		static private const FORMAT_TITLE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0x663300, null, null, null, null, null, "center");

		private var buttonBuy:ButtonBase = null;

		public function HotWeekendView():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var back:ElementPackageBack = new ElementPackageBack();
			back.height = 400;
			addChild(back);

			var view:HotWeekendShopImage = new HotWeekendShopImage();
			view.y = 5;
			addChild(view);

			var fieldTitle:GameField = new GameField(gls("Горячие\nвыходные"), 0, 3, FORMAT_TITLE);
			fieldTitle.x = int((back.width - fieldTitle.textWidth) * 0.5);
			addChild(fieldTitle);

			var field:GameField = new GameField(gls("<body>Бесконечная энергия\n<span class='green'>на все выходные</span></body>"), 0, 60, style);
			field.x = int((back.width - field.textWidth) * 0.5) - 2;
			field.filters = FILTERS_CAPTION;
			addChild(field);

			field = new GameField(gls("<body>и один из уникальных\nаксессуаров\n<span class='red'>в подарок!</span></body>"), 0, 315, style);
			field.x = int((back.width - field.textWidth) * 0.5) - 3;
			field.filters = FILTERS_CAPTION;
			addChild(field);

			for (var i:int = 0; i < 4 && i < HotWeekendManager.accessoriesIds.length; i++)
			{
				var image:ClothesImageSmallLoader = new ClothesImageSmallLoader(HotWeekendManager.accessoriesIds[i]);
				image.scaleX = image.scaleY = 0.8;
				image.x = 10 + 135 * (i % 2);
				image.y = 101 + 153 * int(i / 2);
				addChild(image);
			}

			this.buttonBuy = new ButtonBase(BundleManager.getBundleById(BundleManager.HOT_WEEKEND).price.toString() + (Config.isRus? "  -" : " $"));
			this.buttonBuy.x = int((back.width - this.buttonBuy.width) * 0.5);
			this.buttonBuy.y = back.height - int(this.buttonBuy.height * 0.5);
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buyBundle);
			addChild(this.buttonBuy);

			if(Config.isRus)
				FieldUtils.replaceSign(this.buttonBuy.field, "-", RusSignImage, 1, 1, -this.buttonBuy.field.x  + 5, -6, false, true);
		}

		private function buyBundle(e:MouseEvent):void
		{
			(Services.bank as DialogBank).bundleBuy(BundleManager.HOT_WEEKEND);
		}
	}
}