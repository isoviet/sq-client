package dialogs
{
	import flash.text.TextFormat;

	import game.gameData.DialogOfferManager;
	import loaders.RuntimeLoader;
	import views.VIPComboBoxView;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DialogRebuyVIP extends Dialog
	{
		static private var _instance:DialogRebuyVIP = null;

		public function DialogRebuyVIP():void
		{
			super(gls("Продлить VIP-статус"));

			init();
		}

		static public function show():void
		{
			if (Experience.selfLevel <= Game.LEVEL_TO_INVITE)
				return;
			RuntimeLoader.load(function():void
			{
				if (!_instance)
					_instance = new DialogRebuyVIP();
				_instance.show();

				DialogOfferManager.showed(DialogOfferManager.VIP_REBUY);
			}, true);
		}

		override public function showDialog():void
		{
			super.showDialog();

			Connection.sendData(PacketClient.CLEAR_TEMPORARY, PacketClient.BUY_VIP);
		}

		private function init():void
		{
			var field:GameField = new GameField(gls("VIP статус даёт огромное превосходство в игре. Продли его\nдействие, чтобы не потерять преимущества VIP игрока."), 10, 0, new TextFormat(null, 14, 0x63421B, true, null, null, null, null, "center"));
			field.wordWrap = true;
			field.width = 550;
			addChild(field);

			var image:DialogVIPView = new DialogVIPView();
			image.x = 10;
			image.y = 40;
			image.olympicView.visible = false;
			addChild(image);

			var comboView:VIPComboBoxView = new VIPComboBoxView();
			comboView.x = image.x;
			comboView.y = image.y + 295;
			comboView.callback = countBuying;
			addChild(comboView);

			var names:Array = [gls("Одно бесплатное воскрешение на раунде"), gls("Макс. энергия 300\nВосполнение 2 эн./мин."), gls("х2 скорость получения опыта белкой и шаманом"),
				gls("+100 маны ежедневно"), gls("Золотые крылья рядом с именем"), gls("Уникальный предмет одежды - корона"),
				gls("Доступ к чату VIP игроков")];

			for (var i:int = 0; i < names.length; i++)
			{
				field = new GameField(names[i], image.x + 310, image.y + 42 * i + 5, new TextFormat(null, 12, 0x673401, true, null, null, null, null, "center"));
				field.wordWrap = true;
				field.width = 230;
				addChild(field);
			}

			place();
		}

		private function countBuying():void
		{
			DialogOfferManager.used(DialogOfferManager.VIP_REBUY);
		}
	}
}