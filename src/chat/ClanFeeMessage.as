package chat
{
	import clans.ClanRoom;

	import com.api.Player;

	import protocol.PacketServer;

	import utils.HtmlTool;

	public class ClanFeeMessage extends ClanMessage
	{
		static public const CURRENCY_NUTS:String = "#Ac";
		static public const CURRENCY_COINS:String = "#Co";

		public var date:Date;

		private var coinsCount:int;
		private var acornsCount:int;
		private var type:int;
		private var info:int;

		private var messageText:String;

		public function ClanFeeMessage(player:Player, type:int, coinsCount:int, acornsCount:int, info:int, date:Date):void
		{
			this.coinsCount = Math.abs(coinsCount);
			this.acornsCount = Math.abs(acornsCount);
			this.date = date;
			this.type = type;
			this.info = info;

			if (this.coinsCount > 0)
				this.messageText = " " + this.coinsCount + " " + CURRENCY_COINS;
			else
				this.messageText = " " + this.acornsCount + " " + CURRENCY_NUTS;
			super(player, this.messageText);
		}

		override public function get text():String
		{
			var message:String = null;
			switch (this.type)
			{
				case PacketServer.CLAN_TRANSACTION_DONATION:
					if (this.player['id'] == Game.selfId)
						return HtmlTool.span(gls("Ты внёс {0}", this.messageText), "message");
					else
						return formatName() + HtmlTool.span(gls(" внёс {0}", this.messageText), "message");
				case PacketServer.CLAN_TRANSACTION_RENAME:
					return HtmlTool.span(gls("Имя клана изменено за {0}", this.messageText), "message");
				case PacketServer.CLAN_TRANSACTION_ROOM:
					message = this.player['id'] == Game.selfId ? gls("Ты ") : formatName();
					message += gls("{0}{1} за {2}", (ClanRoom.getLocation(this.info) ? gls(" купил район №") : gls(" покупал район №")), this.info, this.messageText);
					return HtmlTool.span(message, "message");
				case PacketServer.CLAN_TRANSACTION_PLACES:
					message = this.player['id'] == Game.selfId ? gls("Ты ") : formatName();
					message += gls("купил 5 мест за {0}", this.messageText);
					return HtmlTool.span(message, "message");
				case PacketServer.CLAN_TRANSACTION_BOOSTER:
					message = this.player['id'] == Game.selfId ? gls("Ты ") : formatName();
					message += gls("купил ускоренную прокачку за {0}", this.messageText);
					return HtmlTool.span(message, "message");
				case PacketServer.CLAN_TRANSACTION_TOTEM:
					message = this.player['id'] == Game.selfId ? gls("Ты ") : formatName();
					message += gls("купил слот для тотема на 24 часа за {0}", this.messageText);
					return HtmlTool.span(message, "message");
			}
			return HtmlTool.span(gls("С вашего клана снята дань в размере {0}", this.messageText), "message");
		}
	}
}