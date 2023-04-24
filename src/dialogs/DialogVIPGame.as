package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.DialogOfferManager;
	import game.gameData.GameConfig;
	import game.gameData.VIPManager;

	import utils.FieldUtils;

	public class DialogVIPGame extends Dialog
	{
		static private var _instance:DialogVIPGame = null;

		public function DialogVIPGame():void
		{
			super(gls("Играй с VIP-статусом"));

			init();
		}

		static public function hide():void
		{
			if (_instance)
				_instance.hide();
		}

		static public function show():void
		{
			if (VIPManager.haveVIP || Experience.selfLevel < Game.LEVEL_TO_SHOW_TV)
				return;
			if (!DialogOfferManager.getAllow(DialogOfferManager.VIP_GAME))
				return;

			if (!_instance)
				_instance = new DialogVIPGame();
			_instance.show();
			_instance.x = 30;
			_instance.y = 90;

			DialogOfferManager.showed(DialogOfferManager.VIP_GAME);
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 23, 0xFFCC00, null, null, null, null, null, "center");
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 15;
			this.rightOffset = 20;
			this.topOffset = 5;
			this.bottomOffset = 0;
		}

		private function init():void
		{
			addChild(new DialogVIPPart1()).x = 15;
			var vipViewPart2:DialogVIPPart2 = new DialogVIPPart2();
			addChild(vipViewPart2).x = 15;
			vipViewPart2.y = 72;

			addChild(new GameField(gls("и много других преимуществ"), 70, 110, new TextFormat(null, 12, 0x673401)));
			addChild(new GameField(gls("1 день"), 87, 130, new TextFormat(null, 14, 0x673401, true)));

			var names:Array = [gls("Одно бесплатное воскрешение на раунде"),
				gls("Макс. энергия 300\nВосполнение 2 эн./мин."),
				gls("х2 скорость получения опыта\nбелкой и шаманом")];

			for (var i:int = 0; i < names.length; i++)
			{
				var field:GameField = new GameField(names[i], 75, 37 * i, new TextFormat(null, 12, 0x673401, true, null, null, null, null, "center"));
				field.wordWrap = true;
				field.width = 230;
				addChild(field);
			}

			var button:ButtonBase = new ButtonBase(" -   " + GameConfig.getVIPCoinsPrice(VIPManager.VIP_DAY));
			button.x = 143;
			button.y = 130;
			button.addEventListener(MouseEvent.CLICK, buy);
			addChild(button);

			FieldUtils.replaceSign(button.field, "-", ImageIconCoins, 0.7, 0.7, -button.field.x + 5, -3, false, false);

			place();

			this.width = 350;
			this.height = 210;
		}

		private function buy(e:MouseEvent):void
		{
			VIPManager.buy(VIPManager.VIP_DAY);

			DialogOfferManager.used(DialogOfferManager.VIP_GAME);

			hide();
		}
	}
}