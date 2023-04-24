package views.shop
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.CloseoutManager;
	import game.gameData.HotWeekendManager;
	import game.gameData.OutfitData;

	import utils.FiltersUtil;

	public class CloseoutShopView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "a_PlakatTitul";
				font-size: 24px;
				color: #ffffff;
			}
			.red {
				color: #F3FF8C;
				font-size: 34px;
			}
				]]>).toString();

		static public const FILTERS_CAPTION:Array = [new GlowFilter(0x663300, 1.0, 4, 4, 8),
			new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];

		private var items:Array = [];
		private var fieldTimer:GameField = null;

		private var bundleView:OutfitBundleView = null;
		private var hotWeekendView:HotWeekendView = null;

		public function CloseoutShopView():void
		{
			this.y = 95;

			var back:ImageShopCloseoutCaption = new ImageShopCloseoutCaption();
			back.x = 450;
			back.y = 36;
			addChild(back);

			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var field:GameField = new GameField(gls("<body>Купи костюм со скидкой <span class='red'>{0}%</span>!</body>", CloseoutManager.DISCOUNT_TEXT), 50, 0, style);
			field.filters = FILTERS_CAPTION;
			addChild(field);

			addChild(new GameField(gls("*Весь ассортимент костюмов в каталоге."), 50, 35, new TextFormat(null, 14, 0xFFFFFF)));
			addChild(new GameField(gls("Новые предложения через:"), 660, 10, new TextFormat(null, 14, 0x857653, true)));

			this.fieldTimer = new GameField("", 660, 30, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFFFFF));
			this.fieldTimer.filters = FILTERS_CAPTION;
			addChild(this.fieldTimer);

			this.bundleView = new OutfitBundleView();
			this.bundleView.x = 675;
			this.bundleView.y = 70;
			this.bundleView.filters = FiltersUtil.GREY_FILTER;
			addChild(this.bundleView);

			EnterFrameManager.addPerSecondTimer(onTime);
			HotWeekendManager.addEventListener(GameEvent.HOT_WEEKEND_CHANGED, onChange);

			updateItems();
			onChange();
		}

		private function updateItems():void
		{
			while (this.items.length > 0)
				removeChild(this.items.shift());

			for (var i:int = 0; i < CloseoutManager.ids.length; i++)
			{
				var item:Sprite = new OutfitElementView(OutfitData.packageToOutfit(CloseoutManager.ids[i]));
				item.x = 15 + i * 220;
				item.y = 70;
				addChild(item);

				this.items.push(item);
			}
		}

		private function onTime():void
		{
			this.fieldTimer.text = CloseoutManager.timeString;
			this.fieldTimer.x = 760 - int(this.fieldTimer.textWidth * 0.5);
		}

		private function onChange(e:GameEvent = null):void
		{
			if (HotWeekendManager.isWeekend && !HotWeekendManager.isActive)
			{
				if (!this.hotWeekendView)
					this.hotWeekendView = new HotWeekendView();
				this.hotWeekendView.x = 675;
				this.hotWeekendView.y = 70;
				addChild(this.hotWeekendView);

				this.bundleView.visible = false;
			}
			else
			{
				if (this.hotWeekendView)
					this.hotWeekendView.visible = false;
				this.bundleView.visible = true;
			}
		}
	}
}