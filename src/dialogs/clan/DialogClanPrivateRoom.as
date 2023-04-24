package dialogs.clan
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	import buttons.ButtonBase;
	import clans.Clan;
	import clans.ClanManager;
	import dialogs.Dialog;
	import dialogs.DialogInfo;
	import dialogs.DialogSelectMode;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;

	import utils.FieldUtils;

	public class DialogClanPrivateRoom extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #000000;
			}
			.bold {
				font-weight: bold;
			}
			a {
				text-decoration: underline;
			}
			a:hover {
				text-decoration: none;
			}
			.red {
				color: #FF0000;
				font-size: 13px;
			}
			.green {
				color: #26A30A;
				font-weight: bold;
			}
		]]>).toString();

		static public const PRIVATE_ROOM_COST:int = 5;

		private var style:StyleSheet = new StyleSheet();

		private var comboBox:ComboBox = new ComboBox();

		private var dialogClanBlocked:DialogInfo;

		public function DialogClanPrivateRoom():void
		{
			super(gls("Частные районы для клана"));

			init();
		}

		override public function show():void
		{
			var typeProvider:DataProvider = new DataProvider();
			for each (var location:Location in Locations.list)
			{
				if (location.level > Experience.selfLevel || !location.game)
					continue;
				typeProvider.addItem({'label': location.name, 'value': location.id});
			}

			this.comboBox.dataProvider = typeProvider;

			super.show();
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			Game.stage.focus = Game.stage;
		}

		private function init():void
		{
			this.style.parseCSS(CSS);

			this.dialogClanBlocked = new DialogInfo(gls("Клан заблокирован"), gls("Ты не можешь купить комнату,\nт.к. твой клан заблокирован."));

			var frame:DialogRoomFrame = new DialogRoomFrame();
			frame.x = 5;
			frame.y = 47;
			frame.height = 76;
			addChild(frame);

			var description:GameField = new GameField(gls("<body><span class = 'bold'>Частные районы</span> для клана доступны всем его участникам.\nПокупать районы за деньги клана может вождь и Опора.</body>"), 0, 2, this.style);
			description.x = int((frame.width - description.width) * 0.5) + 5;
			addChild(description);

			var fieldBuy:GameField = new GameField(gls("<body>Стоимость частного района <span class = 'bold'>{0}</span> #Co . Время жизни: <span class = 'bold'>1 сутки</span></body>);", PRIVATE_ROOM_COST), 15, 57, this.style);
			addChild(fieldBuy);
			FieldUtils.replaceSign(fieldBuy, "#Co", ImageIconCoins, 0.6, 0.6, -fieldBuy.x, -fieldBuy.y, true);

			var fieldType:GameField = new GameField(gls("<body>Территория:</body>"), 15, 88, this.style);
			addChild(fieldType);

			this.comboBox.x = 105;
			this.comboBox.y = 86;
			this.comboBox.width = 160;
			addChild(this.comboBox);

			var button:ButtonBase = new ButtonBase(gls("Купить"));
			button.x = 290;
			button.y = 83;
			button.addEventListener(MouseEvent.CLICK, buyRoom);
			addChild(button);

			place();
		}

		private function buyRoom(e:MouseEvent):void
		{
			if (ClanManager.getClan(Game.self['clan_id']).state == PacketServer.CLAN_STATE_BANNED)
			{
				this.dialogClanBlocked.show();
				return;
			}

			if (Locations.getLocation(this.comboBox.selectedItem['value']).multiMode)
			{
				new DialogSelectMode(this.comboBox.selectedItem['value']).show();
				return;
			}

			if (ClanManager.getClan(Game.self['clan_id']).coins < PRIVATE_ROOM_COST && (Game.self['clan_duty'] == Clan.DUTY_LEADER || Game.self['clan_duty'] == Clan.DUTY_SUBLEADER))
			{
				new DialogClanDonate(gls("Недостаточно монет"), gls("У вашего клана недостаточно денег      \nдля покупки частного района.\nПополните бюджет вашего клана.")).show();
				return;
			}

			if (Game.self['clan_duty'] == Clan.DUTY_LEADER || Game.self['clan_duty'] == Clan.DUTY_SUBLEADER)
				Connection.sendData(PacketClient.BUY, PacketClient.BUY_CLAN_ROOM, PRIVATE_ROOM_COST, 0, this.comboBox.selectedItem['value'] << 8);
			else
				Game.buy(PacketClient.BUY_CLAN_ROOM, PRIVATE_ROOM_COST, 0, this.comboBox.selectedItem['value'] << 8);

			hide();
		}
	}
}