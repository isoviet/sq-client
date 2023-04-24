package dialogs
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonFooterTab;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import dialogs.bank.BankTabView;
	import events.DiscountEvent;
	import game.gameData.BundleManager;
	import game.gameData.HolidayManager;
	import screens.ScreenRating;
	import views.BankBundleView;
	import views.DailyBonusTapeView;

	import com.IBank;
	import com.api.Services;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.ColorMatrix;
	import utils.FieldUtils;
	import utils.HtmlTool;
	import utils.StringUtil;

	public class DialogBank extends Dialog implements IBank
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 17px;
				color: #000000;
				font-weight: bold;
			}
			.red {
				font-family: "a_PlakatTitul";
				color: #FF7E3F;
				font-size: 25px;
			}
			.small {
				font-family: "a_PlakatTitul";
				color: #FF7E3F;
				font-size: 10px;
			}
			.brown
			{
				font-size: 15px;
				color: #62411A;
			}
			.brownBig
			{
				text-align: center;
				font-size: 18px;
				color: #62411A;
				font-weight: bold;
			}
		]]>).toString();

		static public const TAB_COINS:int = 1;
		static public const TAB_INGREDIENTS:int = 2;

		static public const TYPE_COINS:int = 1;
		static public const COINS_COUNT:Object = {
			'ru': [700, 350, 175, 49, 14],
			'en': [900, 375, 150, 45, 30]
		};

		static public const COINS_PRICES:Object = {
			'ru': [700, 350, 175, 49, 14],
			'en': [29.99, 12.49, 4.99, 1.49, 0.99]
		};

		static public const INGREDIENT_COUNT:Object = {
			'ru': [2000, 1500, 1000, 500, 100],
			'en': [2000, 1500, 1000, 500, 100]
		};

		static public const INGREDIENT_PRICE:Object = {
			'ru': [595, 497, 350, 196, 49],
			'en': [8.99, 6.99, 4.99, 2.99, 0.99]
		};

		static public const FILTERS_BONUS:Array = [new BevelFilter(1.0, 45, 0xFFFF66, 1.0, 0xCC0000, 1.0, 1, 1),
			new GlowFilter(0x663300, 1.0, 3, 3, 8),
			new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];

		static private var instance:DialogBank;

		private var style:StyleSheet = null;

		private var spriteButtons:Sprite = null;

		private var bundleView:BankBundleView = null;
		private var buttonsGroup:ButtonTabGroup = null;

		private var tabCoins:BankTabView = null;
		private var tabIngredients:BankTabView = null;

		private var inited:Boolean = false;

		public function DialogBank():void
		{
			super(gls("Банк"), true, true, null, false);

			instance = this;
			this.sound = "bank";

			DiscountManager.addEventListener(DiscountEvent.END, onDiscountEnd);
		}

		static public function setTab(index:int):void
		{
			DialogBank.instance.buttonsGroup.setSelectedByIndex(index-1);
		}

		static public function getPriceString(price:Number):String
		{
			if (Config.isEng)
				return "$" + price;
			return int(price) + " " + StringUtil.word("рубль", int(price));
		}

		override public function show():void
		{
			if (!this.inited)
				init();

			super.show();

			this.bundleView.visible = true;

			Connection.sendData(PacketClient.COUNT, PacketClient.COUNT_BANK_OPENS);
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			this.bundleView.visible = false;

			Game.stage.focus = Game.stage;
		}

		public function open(fromType:int = -1):void
		{
			if (fromType) {}

			show();
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 29, 0xFFCC00, null, null, null, null, null, "center");
		}

		override protected function effectOpen():void
		{}

		protected function getPayment(coins:int):Number
		{
			return coins;
		}

		private function init():void
		{
			this.inited = true;

			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.spriteButtons = new Sprite();
			addChild(this.spriteButtons);

			addBundle();

			var field:GameField = new GameField("<body>" + HtmlTool.span(gls("Заходи каждый день, чтобы цепочка бонусов не прервалась!"), "brown") + "</body>", 0, 360, this.style);
			field.x = int((865 - field.textWidth) * 0.5);
			addChild(field);

			place();

			this.width = 885;
			this.height = 590;

			var dailyBonusTape:DailyBonusTapeView = new DailyBonusTapeView();
			dailyBonusTape.y = 445;
			addChild(dailyBonusTape);

			this.buttonsGroup = new ButtonTabGroup();
			var button:ButtonTab = new ButtonTab(new ButtonFooterTab(gls("монеты"), ScreenRating.FORMATS, ButtonBankTabCoins, 13, 14));
			this.tabCoins = new BankTabView(COINS_COUNT, COINS_PRICES, ImageIconCoins, onBuyCoins);
			this.spriteButtons.addChild(this.tabCoins);
			this.buttonsGroup.insert(button, this.tabCoins);

			if (!HolidayManager.isHolidayEnd)
			{
				var lastX:int = button.x + button.width + 5;
				button = new ButtonTab(new ButtonFooterTab(HolidayManager.elementsBankName, ScreenRating.FORMATS, ButtonBankTabIngredients, 13, 14));
				button.x = lastX;
				var icon:ImageIconHoliday = new ImageIconHoliday();
				icon.mouseChildren = icon.mouseEnabled = false;
				icon.scaleX = icon.scaleY = 1.2;
				icon.x = 50; icon.y = 10;
				button.addChild(icon);
				this.tabIngredients = new BankTabView(INGREDIENT_COUNT, INGREDIENT_PRICE, ImageIconHoliday, onBuyIngredients);
				this.spriteButtons.addChild(this.tabIngredients);
				this.buttonsGroup.insert(button, this.tabIngredients);
			}
			this.spriteButtons.addChild(this.buttonsGroup);
			this.buttonsGroup.setSelectedByIndex(0);

			tabBoxPosition(new Point(16, 0));

			for (var i:int = 0; i < COINS_COUNT[Config.LOCALE].length; i++)
				addButton(i, TAB_COINS);
			if (!HolidayManager.isHolidayEnd)
				for (i = 0; i < INGREDIENT_COUNT[Config.LOCALE].length; i++)
					addButton(i, TAB_INGREDIENTS);

			if(Game.isGameOffer == true)
				addButtonOffer();
		}

		private function addButtonOffer():void
		{
			var buttonOffer:Sprite = new Sprite();
			var bg:ButtonBankLong = new ButtonBankLong();

			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(0, 0, 100, 9);
			bg.filters = [new ColorMatrixFilter(colorMatrix)];

			buttonOffer.addChild(bg);
			bg.width = 394;
			bg.height = 45;
			buttonOffer.x = 25;
			buttonOffer.y = 299;
			buttonOffer.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void
			{
				Services.showOffers("squirrels",Game.selfId);
			});
			this.spriteButtons.addChild(buttonOffer);

			var field:GameField = new GameField("<body>" + HtmlTool.span(gls("Получи -  бесплатно!"), "brownBig")  + "</body>", 0, 10, this.style, 392);
			field.mouseEnabled = false;
			buttonOffer.addChild(field);

			FieldUtils.replaceSign(field, "-", ImageIconCoins, 0.9, 0.9, field.x + 5, -10, true);
		}

		private function tabBoxPosition(pos:Point):void
		{
			this.spriteButtons.graphics.clear();
			this.spriteButtons.graphics.lineStyle(3, 0xECD9BC);
			this.spriteButtons.graphics.beginFill(0xFFF6E5, 1);
			this.spriteButtons.graphics.drawRect(pos.x + 4, pos.y + 50, 406, 298);
			this.spriteButtons.graphics.endFill();

			this.buttonsGroup.y = pos.y + 9;
			this.buttonsGroup.x = pos.x;

			this.tabCoins.x = pos.x + 9;
			this.tabCoins.y = pos.y + 79 - (Game.isGameOffer ? 24 : 0);

			if (this.tabIngredients)
			{
				this.tabIngredients.x = this.tabCoins.x = pos.x + 9;
				this.tabIngredients.y = this.tabCoins.y = pos.y + 79 - (Game.isGameOffer ? 24 : 0);
			}
		}

		private function onBuyCoins(index:int):void
		{
			buy(COINS_COUNT[Config.LOCALE][index]);
			hide();
			Connection.sendData(PacketClient.COUNT, PacketClient.COUNT_BANK_PURCHASE);
		}

		private function onBuyIngredients(index:int):void
		{
			var adapterBundle:Array = [
				BundleManager.HOLIDAY_2000,
				BundleManager.HOLIDAY_1500,
				BundleManager.HOLIDAY_1000,
				BundleManager.HOLIDAY_500,
				BundleManager.HOLIDAY_100
			];

			bundleBuy(adapterBundle[index]);
			hide();
		}

		public function buy(coins:int):void
		{
			if (coins) {}
			FullScreenManager.instance().fullScreen = false;
		}

		private function addButton(index:int, tab:int):void
		{
			if(tab == TAB_COINS)
				this.tabCoins.add(index, true);
			else
				this.tabIngredients.add(index, false);
		}

		private function addBundle():void
		{
			this.bundleView = new BankBundleView(bundleBuy);
			this.bundleView.x = 445;
			this.bundleView.y = 10;
			this.bundleView.visible = false;
			this.spriteButtons.addChild(this.bundleView);
		}

		public function bundleBuy(id:int):void
		{}

		private function onDiscountEnd(e:DiscountEvent):void
		{
			switch (e.id)
			{
				case DiscountManager.DOUBLE_COINS_SMALL:
				case DiscountManager.DOUBLE_COINS_ALL_NP:
					removeDoubleBonus();
					break;
			}
		}

		private function removeDoubleBonus():void
		{
			for (var i:int = 0; i < COINS_COUNT[Config.LOCALE].length; i++)
				addButton(i, TAB_COINS);
			for (i = 0; i < INGREDIENT_COUNT[Config.LOCALE].length; i++)
				addButton(i, TAB_INGREDIENTS);
		}
	}
}