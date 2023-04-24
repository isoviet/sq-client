package dialogs
{
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import sounds.SoundConstants;
	import views.ClothesImageSmallLoader;

	public class DialogHotWeekendBonus extends Dialog
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


		public function DialogHotWeekendBonus(clothesId:int)
		{
			super("", false, false, null, false);

			this.topOffset = 100;

			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var back:DialogHotWeekendBonusBack = new DialogHotWeekendBonusBack();
			addChild(back);

			addChild(new GameField(gls("Поздравляем!"), 0, 150, FORMAT_CAPTION, back.width)).filters = [FILTER_GLOW];
			addChild(new GameField(gls("Ты получил:"), 0, 195, FORMAT_TEXT, back.width));

			addChild(new GameField("<body>" + gls("<b>Бесконечную энергию</b> на все выходные (суббота и воскресенье)") + "</body>", 120, 230, style, back.width - 240));
			addChild(new GameField("<body>" + gls("<b>Уникальный аксессуар</b> в подарок!") + "</body>", 120, 285, style, back.width - 240));

			var image:ClothesImageSmallLoader = new ClothesImageSmallLoader(clothesId);
			image.x = 222;
			image.y = 350;
			addChild(image);

			var buttonBuy:ButtonBase = new ButtonBase(gls("Ок"));
			buttonBuy.x = 219;
			buttonBuy.y = 455;
			buttonBuy.addEventListener(MouseEvent.CLICK, hide);
			addChild(buttonBuy);

			place();

			this.sound = SoundConstants.REWARD;
			this.y += 50;
		}
	}
}