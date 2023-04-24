package dialogs
{
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	public class DialogShopNotify extends Dialog
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

		public function DialogShopNotify():void
		{
			super("", false, false, null, false);

			init();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var back:DialogShopNotifyBack = new DialogShopNotifyBack();
			addChild(back);

			var image:ImageSmilePack0 = new ImageSmilePack0();
			image.x = int(220 - image.width * 0.5);
			image.y = int(80 - image.height * 0.5);
			addChild(image);

			addChild(new GameField(gls("Поздравляем!"), 0, 150, FORMAT_CAPTION, back.width)).filters = [FILTER_GLOW];
			addChild(new GameField(gls("Ты приобрёл смайлы"), 0, 200, FORMAT_TEXT, back.width));

			addChild(new GameField("<body>" + gls("Ты можешь отображать свои эмоции в игре,\nнажав на кнопку в нижней части экрана.") + "</body>", 0, 225, style, back.width));

			var button:ButtonBase = new ButtonBase("Ок");
			button.x = int((back.width - button.width) * 0.5);
			button.y = 275;
			button.addEventListener(MouseEvent.CLICK, hide);
			addChild(button);

			place();
		}
	}
}