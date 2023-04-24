package chat
{
	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.PacketClient;

	import utils.BanUtil;
	import utils.DateUtil;

	public class CommonBanMessage extends CommonMessage
	{
		private var banned:Player;
		private var moderator:Player;

		private var banType:int;
		private var banTime:int;
		private var banReason:int;

		private var bannedLoaded:Boolean = false;
		private var moderatorLoaded:Boolean = false;

		public function CommonBanMessage(banned:Player, moderator:Player, banTime:int, banType:int, banReason:int)
		{
			this.banned = banned;
			this.moderator = moderator;

			this.banTime = banTime;
			this.banType = banType;
			this.banReason = banReason;

			var requestIds:Array = [this.banned['id']];
			if (moderator != null)
				requestIds.push(this.moderator['id']);
			else
				this.moderatorLoaded = true;

			super(Game.self, "");

			Game.listen(onLoadedPlayer);
			Game.request(requestIds, PlayerInfoParser.NAME);
		}

		override public function get canAdd():Boolean
		{
			return this.bannedLoaded && this.moderatorLoaded;
		}

		override public function get text():String
		{
			switch(this.banType)
			{
				case PacketClient.BAN_TYPE_GAG:
					this.message = gls("Игроку {0} заблокирован чат{1}{2}", this.banned.name, ((this.banTime > 0) ? (gls(" на {0}", DateUtil.durationString(this.banTime))) : ""), (!this.moderator ? "" : gls(" модератором c ID{0}. Причина: {1}", this.moderator.id, BanUtil.getReasonById(this.banReason))));
					break;
				case PacketClient.BAN_TYPE_BAN:
					this.message = gls("Игрок {0} заблокирован{1} модератором c ID{2}. Причина: {3}", this.banned.name, ((this.banTime > 0) ? (gls(" на {0}", DateUtil.durationString(this.banTime))) : ""), this.moderator.id, BanUtil.getReasonById(this.banReason));
					break;
			}
			return "<body><span class = 'service_message'>" + this.message + "</span></body>";
		}

		private function onLoadedPlayer(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (!player.isLoaded(PlayerInfoParser.NAME))
				return;

			if (this.banned['id'] == player['id'])
			{
				this.bannedLoaded = true;
				this.banned = player;
			}
			if (this.moderator && this.moderator['id'] == player['id'])
			{
				this.moderatorLoaded = true;
				this.moderator = player;
			}

			if (!this.bannedLoaded || !this.moderatorLoaded)
				return;

			Game.forget(onLoadedPlayer);
		}
	}
}