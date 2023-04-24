package dialogs
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.BundleManager;
	import game.gameData.HotWeekendManager;
	import statuses.Status;
	import views.ClothesImageSmallLoader;

	import com.api.Services;

	import utils.FieldUtils;

	public class DialogHotWeekend extends Dialog
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

		static private var _instance:DialogHotWeekend = null;

		private var buttonBuy:ButtonBase = null;

		public function DialogHotWeekend()
		{
			super("", false, true, null, false);

			init();
		}

		static public function show():void
		{
			if (HotWeekendManager.isActive)
				return;
			if (!_instance)
				_instance = new DialogHotWeekend();
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

			this.topOffset = 100;

			var back:DialogHotWeekendBack = new DialogHotWeekendBack();
			addChild(back);

			addChild(new GameField(HotWeekendManager.caption, 0, 140, FORMAT_CAPTION, back.width)).filters = [FILTER_GLOW];
			addChild(new GameField(gls("Не теряй времени на раздумья"), 0, 195, FORMAT_TEXT, back.width));

			addChild(new GameField("<body>" + gls("Участвуй в акции <b>«{0}»</b> и получай:", HotWeekendManager.caption) + "</body>", 0, 215, style, back.width));
			addChild(new GameField("<body>" + gls("<b>Бесконечную энергию</b> на все выходные (суббота и воскресенье)") + "</body>", 120, 245, style, back.width - 240));
			addChild(new GameField("<body>" + gls("Один из <b>уникальных аксессуаров</b> для твоей белочки:") + "</body>", 120, 310, style, back.width - 240));

			var sprite:Sprite = new Sprite();
			for (var i:int = 0; i < HotWeekendManager.accessoriesIds.length; i++)
			{
				var slot:Sprite = new Sprite();
				slot.x = 75 * i;

				var frame:ElementSlotBack = new ElementSlotBack();
				frame.width = frame.height = 65;
				slot.addChild(frame);

				var image:ClothesImageSmallLoader = new ClothesImageSmallLoader(HotWeekendManager.accessoriesIds[i]);
				image.x = int((slot.width - image.width) * 0.5);
				image.y = int((slot.height - image.height) * 0.5);
				slot.addChild(image);

				new Status(slot, ClothesData.getTitleById(HotWeekendManager.accessoriesIds[i]));
				sprite.addChild(slot);
			}
			sprite.x = int((back.width - sprite.width) * 0.5);
			sprite.y = 355;
			addChild(sprite);

			this.buttonBuy = new ButtonBase(BundleManager.getBundleById(BundleManager.HOT_WEEKEND).price.toString() + (Config.isRus? "  -" : " $"));
			this.buttonBuy.x = int((back.width - this.buttonBuy.width) * 0.5);
			this.buttonBuy.y = 435;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buy);
			addChild(this.buttonBuy);

			if (Config.isRus)
				FieldUtils.replaceSign(this.buttonBuy.field, "-", RusSignImage, 1, 1, -this.buttonBuy.field.x  + 5, -6, false, true);

			place();

			this.buttonClose.x -= 60;
			this.buttonClose.y += 190;

			//this.y -= 10;
		}

		private function buy(e:MouseEvent):void
		{
			(Services.bank as DialogBank).bundleBuy(BundleManager.HOT_WEEKEND);

			hide();
		}
	}
}