package views.dialogEvents
{
	import clans.Clan;
	import clans.ClanManager;
	import events.ClanEvent;
	import views.ClanEmblemLoader;
	import views.ClanPhotoLoader;

	import protocol.PacketServer;

	public class PostClanAcceptView extends PostElementView implements IPostClanView
	{
		private var clanName:GameField = null;

		private var emblem:ClanEmblemLoader = null;
		private var photo:ClanPhotoLoader = null;

		private var _clanId:int = -1;

		public function PostClanAcceptView(id:int, type:int, clanId:int, time:int):void
		{
			super(id, type, time);

			this.clanId = clanId;
		}

		public function get clanId():int
		{
			return this._clanId;
		}

		public function set clanId(value:int):void
		{
			this._clanId = value;
		}

		override public function onShow():void
		{
			if (this.photo != null)
				return;

			super.onShow();

			this.photo = new ClanPhotoLoader("", 0, 0, 80);
			addChild(this.photo);

			var description:GameField = new GameField("", 0, 0, style);
			description.x = 85;
			description.y = 10;
			addChild(description);

			this.emblem = new ClanEmblemLoader("", 90, 33);
			addChild(this.emblem);

			this.clanName = new GameField("", 100, 29, style);
			addChild(this.clanName);

			switch (this.type)
			{
				case PacketServer.CLAN_ACCEPT:
				case PacketServer.CLAN_REJECT:
					description.htmlText = "<body>" + gls("Твоя заявка на вступление в клан") + "<body>";
					break;
				case PacketServer.CLAN_BLOCK_EVENT:
				case PacketServer.CLAN_CLOSE_EVENT:
					description.htmlText = "<body>" + gls("Клан") + "<body>";
					this.emblem.x = 122;
					this.emblem.y = 14;
					this.clanName.x = 85;
					this.clanName.y = 10;
					break;
				case PacketServer.CLAN_NEWS_EVENT:
					description.htmlText = "<body>" + gls("В клане") + "<body>";
					this.emblem.visible = false;
					this.clanName.x = 85;
					this.clanName.y = 10;
					break;
			}

			ClanManager.listen(onLoadClan);
			ClanManager.request(this.clanId);
		}

		private function onLoadClan(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if (clan.id != this.clanId)
				return;

			ClanManager.forget(onLoadClan);

			this.photo.load(clan.photoLink);
			this.emblem.load(clan.emblemLink);

			switch(this.type)
			{
				case PacketServer.CLAN_BLOCK_EVENT:
					this.clanName.htmlText = gls("<body><textformat leading='4'>              {0}<br/>заблокирован за неуплату.</textformat><body>", clan.name);
					break;
				case PacketServer.CLAN_CLOSE_EVENT:
					this.clanName.htmlText = gls("<body><textformat leading='4'>              {0}<br/>удален.</textformat><body>", clan.name);
					break;
				case PacketServer.CLAN_REJECT:
					this.clanName.htmlText = gls("<body>{0} отклонена.<body>", clan.name);
					break;
				case PacketServer.CLAN_ACCEPT:
					this.clanName.htmlText = gls("<body>{0} одобрена.<body>", clan.name);
					break;
				case PacketServer.CLAN_NEWS_EVENT:
					this.clanName.width = 350;
					this.clanName.multiline = true;
					this.clanName.wordWrap = true;
					this.clanName.mouseEnabled = false;

					var clanNews:String = (ClanManager.selfClanNews == null ? "" : ClanManager.selfClanNews.slice().replace(/\r/g, " "));
					if (clanNews.length > 100)
						clanNews = clanNews.substr(0, 100).concat("...");

					this.clanName.htmlText = gls("<body>               изменилась новость дня:<span class='blackSmall'><br/>{0}</span><body>", clanNews);
					break;
			}
		}
	}
}