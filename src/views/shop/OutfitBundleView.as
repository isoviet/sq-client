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
	import views.widgets.DiscountWidget;

	import com.api.Services;

	public class OutfitBundleView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "a_PlakatTitul";
				font-size: 16px;
				color: #9A4C0F;
				text-align: center;
			}
			.red {
				color: #FF5515;
				font-size: 30px;
			}
				]]>).toString();

		static public const FILTERS_CAPTION:Array = [new GlowFilter(0xFFFFFF, 1.0, 4, 4, 8),
								new GlowFilter(0x867754, 1.0, 4, 4, 1)];

		static private const FORMAT_TITLE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0x663300, null, null, null, null, null, "center");

		public function OutfitBundleView():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var back:ElementPackageBack = new ElementPackageBack();
			back.height = 400;
			addChild(back);

			var fieldTitle:GameField = new GameField(gls("Испытай\nудачу!"), 0, 3, FORMAT_TITLE);
			fieldTitle.x = int((back.width - fieldTitle.textWidth) * 0.5);
			addChild(fieldTitle);

			var view:ImageBundleOutfit = new ImageBundleOutfit();
			view.x = int((back.width - view.width) * 0.5);
			view.y = 85;
			addChild(view);

			var discount:DiscountWidget = new DiscountWidget();
			discount.scaleX = discount.scaleY = 0.8;
			discount.discount = 250;
			discount.x = 2;
			discount.y = 45;
			addChild(discount);

			var field:GameField = new GameField(gls("<body>Получи\nслучайный или\n<span class='red'>эпический</span>\nкостюм или образ</body>"), 0, 280, style);
			field.filters = FILTERS_CAPTION;
			field.x = int((back.width - field.textWidth) * 0.5);
			addChild(field);

			/*var button:ButtonBase = new ButtonBase(DialogBank.getPriceString(BundleManager.getBundleById(BundleManager.CLOSEOUT).price));
			button.x = int((back.width - button.width) * 0.5);
			button.y = back.height - int(button.height * 0.5);
			button.addEventListener(MouseEvent.CLICK, buyBundle);
			addChild(button);*/
		}

		private function buyBundle(e:MouseEvent):void
		{
			(Services.bank as DialogBank).bundleBuy(BundleManager.CLOSEOUT);
		}
	}
}