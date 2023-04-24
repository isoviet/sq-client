package dialogs
{
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.BundleManager;

	import com.api.Services;

	import utils.FieldUtils;

	public class DialogHolidayBooster extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #7E5836;
				text-align: center;
			}
				]]>).toString();

		static public const FILTER_GLOW:GlowFilter = new GlowFilter(0x081F3A, 1, 4, 4);

		static public const FORMAT_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 27, 0xFFFFFF, null, null, null, null, null, "center");
		static public const FORMAT_TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0x857653, null, null, null, null, null, "center");
		static public const FORMAT_BIG:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xF2FFC4, null, null, null, null, null, "center");

		static private var _instance:DialogHolidayBooster = null;

		private var buttonBuy:ButtonBase = null;

		public function DialogHolidayBooster()
		{
			super("", false, true, null, false);

			init();
		}

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogHolidayBooster();
			_instance.show();
		}

		static public function hide():void
		{
			if (_instance)
				_instance.hide();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var back:DialogHolidayBoosterBack = new DialogHolidayBoosterBack();
			addChild(back);

			addChild(new GameField(gls("Супер предложение!"), 0, 150, FORMAT_CAPTION, back.width)).filters = [FILTER_GLOW];
			addChild(new GameField(gls("Горшочек плодородия"), 0, 195, FORMAT_TEXT, back.width));

			addChild(new GameField("<body>" + gls("<b>10 семян каждый день\nв течение 14 дней</b>") + "</body>", 0, 215, style, back.width));
			addChild(new GameField(gls("140 семян"), 0, 330, FORMAT_BIG, back.width)).filters = [new GlowFilter(0x660000, 1, 4, 4, 8)];
			//addChild(new GameField("<body>" + gls("Один из <b>уникальных аксессуаров</b> для твоей белочки:") + "</body>", 120, 310, style, back.width - 240));

			this.buttonBuy = new ButtonBase(BundleManager.getBundleById(BundleManager.HOLIDAY_BOOSTER).price.toString() + (Config.isRus? "  -" : " $"));
			this.buttonBuy.x = int((back.width - this.buttonBuy.width) * 0.5);
			this.buttonBuy.y = 385;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buy);
			addChild(this.buttonBuy);

			if (Config.isRus)
				FieldUtils.replaceSign(this.buttonBuy.field, "-", RusSignImage, 1, 1, -this.buttonBuy.field.x  + 5, -6, false, true);

			place();

			this.buttonClose.x -= 65;
			this.buttonClose.y += 100;

			this.y -= 10;
		}

		private function buy(e:MouseEvent):void
		{
			(Services.bank as DialogBank).bundleBuy(BundleManager.HOLIDAY_BOOSTER);

			hide();
		}
	}
}