package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import fl.controls.CheckBox;

	import buttons.ButtonBase;
	import clans.Clan;
	import clans.ClanManager;
	import dialogs.Dialog;
	import dialogs.clan.DialogClanDonate;
	import dialogs.clan.DialogClanPrivateRoom;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.TextFieldUtil;

	public class DialogSelectMode extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #000000;
			}
		]]>).toString();

		private var style:StyleSheet = new StyleSheet();
		private var checkBoxes:Array = [];

		private var dialogNoSelectedMode:DialogInfo;
		private var locationId:int;

		public function DialogSelectMode(locationId:int):void
		{
			super(gls("Выбор режима"));

			this.locationId = locationId;

			init();
		}

		private function init():void
		{
			this.style.parseCSS(CSS);

			var description:GameField = new GameField(gls("<body>Выбери режимы, доступные\nдля частного района:</body>"), 0, 0, this.style);
			description.x = 20;
			description.y = 15;
			addChild(description);

			var modes:Array = Locations.getLocation(this.locationId).modes;

			for each (var index:int in modes)
			{
				if (index == Locations.BLACK_SHAMAN_MODE)
					continue;

				var checkBox:CheckBox = new CheckBox();
				TextFieldUtil.setStyleCheckBox(checkBox);
				checkBox.selected = true;
				checkBox.x = 20;
				checkBox.y = 55 + 23 * this.checkBoxes.length;
				checkBox.name = String(index);
				checkBox.label = Locations.MODES[index].name;
				checkBox.width = 400;
				addChild(checkBox);
				this.checkBoxes.push(checkBox);
			}

			var button:ButtonBase = new ButtonBase(gls("Купить"));
			button.x = 75;
			button.y = 30 + this.checkBoxes[this.checkBoxes.length - 1].y;
			button.addEventListener(MouseEvent.CLICK, buyRoom);
			addChild(button);

			place();
			this.width += 40;
			this.height += 15;
		}

		private function buyRoom(e:MouseEvent):void
		{
			var mask:int = 0;

			for each (var checkBox:CheckBox in this.checkBoxes)
			{
				if (!checkBox.selected)
					continue;

				var index:uint = 1 << int(checkBox.name);
				mask |= index;
			}

			if (mask == 0)
			{
				if (!this.dialogNoSelectedMode)
					this.dialogNoSelectedMode = new DialogInfo(gls("Выбор режима"), gls("Для того, чтобы купить частный район,\nнеобходимо выбрать хотя бы один режим."));

				this.dialogNoSelectedMode.show();
				return;
			}

			if (ClanManager.getClan(Game.self['clan_id']).coins < DialogClanPrivateRoom.PRIVATE_ROOM_COST && (Game.self['clan_duty'] == Clan.DUTY_LEADER || Game.self['clan_duty'] == Clan.DUTY_SUBLEADER))
			{
				new DialogClanDonate(gls("Недостаточно монет"), gls("У вашего клана недостаточно денег      \nдля покупки частного района.\nПополните бюджет вашего клана.")).show();
				return;
			}

			if (Game.self['clan_duty'] == Clan.DUTY_LEADER || Game.self['clan_duty'] == Clan.DUTY_SUBLEADER)
				Connection.sendData(PacketClient.BUY, PacketClient.BUY_CLAN_ROOM, DialogClanPrivateRoom.PRIVATE_ROOM_COST, 0, this.locationId << 8, mask);
			else
				Game.buy(PacketClient.BUY_CLAN_ROOM, DialogClanPrivateRoom.PRIVATE_ROOM_COST, 0, this.locationId << 8, mask);

			if (this.dialogNoSelectedMode && this.dialogNoSelectedMode.visible)
				this.dialogNoSelectedMode.hide();

			hide();
		}
	}
}