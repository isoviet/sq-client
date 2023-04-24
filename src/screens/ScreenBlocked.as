package screens
{
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.gameData.GameConfig;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketBan;

	import utils.BanUtil;
	import utils.StringUtil;

	public class ScreenBlocked extends Screen
	{
		private var timeField:GameField;
		private var reasonField:GameField;
		private var moderatorField:GameField;

		private var squirrelPolice:BackgroundBlocked = new BackgroundBlocked();

		public function ScreenBlocked():void
		{
			super();

			init();

			Connection.listen(onPacket, PacketBan.PACKET_ID);
		}

		private function init():void
		{
			GameConfig.loadAll = false;
			GameConfig.load();

			var timeFormat:TextFormat = new TextFormat(null, 28, 0xff0000, true);
			var infoFormat:TextFormat = new TextFormat(null, 14, 0x000000);

			var titleFormat:TextFormat = new TextFormat(null, 20, 0x000000, true);
			titleFormat.align = TextFormatAlign.CENTER;

			this.squirrelPolice.y = 10;
			this.squirrelPolice.x = 258;
			addChild(this.squirrelPolice);

			var tittleField:GameField = new GameField(gls("Ты заблокирован\n за нарушение правил\n игры!"), 323, 34, titleFormat);
			addChild(tittleField);

			var subTittleField:GameField = new GameField(gls("Оставшееся время блокировки:"), 0, 510, new TextFormat(null, 17, 0x000000, true));
			subTittleField.x = int((Config.GAME_WIDTH - subTittleField.textWidth) * 0.5);
			addChild(subTittleField);

			this.timeField = new GameField("", 0, 530, timeFormat);
			this.timeField.autoSize = TextFieldAutoSize.CENTER;
			this.timeField.width = Config.GAME_WIDTH;
			this.timeField.height = 200;
			addChild(this.timeField);

			this.reasonField = new GameField("", 0, 568, infoFormat);
			this.reasonField.autoSize = TextFieldAutoSize.CENTER;
			this.reasonField.width = Config.GAME_WIDTH;
			this.reasonField.height = 200;
			addChild(this.reasonField);

			this.moderatorField = new GameField("", 0, 590, infoFormat);
			this.moderatorField.autoSize = TextFieldAutoSize.CENTER;
			this.moderatorField.width = Config.GAME_WIDTH;
			this.moderatorField.height = 200;
			addChild(this.moderatorField);
		}

		private function getValue(time:int, mod:int, postfix:String):String
		{
			var value:int = time % mod;

			var text:String = String(value) + postfix;
			if (value < 10)
				text = "0" + text;

			return text;
		}

		private function onPacket(packet: PacketBan):void
		{
			var duration:int = packet.duration;

			if (packet.type != PacketClient.BAN_TYPE_BAN)
				return;
			if (packet.targetId != Game.selfId)
				return;

			var text:String = "";

			duration /= 60;
			text = getValue(duration, 60, "") + gls("мин.") + text;

			duration /= 60;
			text = getValue(duration, 24, gls("ч. ")) + text;

			duration /= 24;
			if (duration != 0)
				text = duration + " " + StringUtil.word("день", duration) + " " + text;

			this.timeField.text = text;

			this.reasonField.text = gls("Причина бана: {0}", BanUtil.getReasonById(packet.reason));

			this.moderatorField.text = (packet.moderatorId == 0 ? gls("Автоматическая система бана") : gls("Модератор: №{0}", packet.moderatorId));

			Screens.show(this);
		}
	}
}