package views.dialogEvents
{
	import flash.events.MouseEvent;

	import buttons.ButtonBase;
	import clans.Clan;
	import clans.ClanManager;
	import dialogs.DialogInfo;
	import events.ClanEvent;
	import events.PostEvent;
	import menu.MenuProfile;
	import views.ClanEmblemLoader;
	import views.ClanPhotoLoader;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketClanState;

	import utils.HtmlTool;

	public class PostClanInviteView extends PostElementView implements IPostClanView
	{
		static private var _dialogAlreadyInClan:DialogInfo = null;
		static private var _dialogJoinToClan:DialogInfo = null;
		static private var _dialogJoinLeaderClan:DialogInfo = null;

		static public var inviteClanId:int = 0;

		private var caption:GameField = null;
		private var clanName:GameField = null;

		private var emblem:ClanEmblemLoader = null;
		private var photo:ClanPhotoLoader = null;

		private var playerId:int = -1;
		private var _clanId:int = -1;

		public function PostClanInviteView(id:int, type:int, playerId:int, clanId:int, time:int):void
		{
			super(id, type, time);

			this.clanId = clanId;
			this.playerId = playerId;

			Connection.listen(onPacket, [PacketClanState.PACKET_ID]);
		}

		static private function get dialogAlreadyInClan():DialogInfo
		{
			if (_dialogAlreadyInClan == null)
				_dialogAlreadyInClan = new DialogInfo(gls("Ты уже в клане"), gls("Чтобы вступить в этот клан, ты должен выйти из своего."));

			return _dialogAlreadyInClan;
		}

		static private function get dialogJoinToClan():DialogInfo
		{
			if (_dialogJoinToClan == null)
				_dialogJoinToClan = new DialogInfo(gls("Вступление в клан"), gls("Ты точно хочешь вступить в клан?"), true, joinToClan);

			return _dialogJoinToClan;
		}

		static private function get dialogJoinLeaderClan():DialogInfo
		{
			if (_dialogJoinLeaderClan == null)
				_dialogJoinLeaderClan = new DialogInfo(gls("Вступление в клан"), gls("Чтобы перейти в другой клан,\nвождь должен сначала распустить\nсвой."));

			return _dialogJoinLeaderClan;
		}

		static private function joinToClan():void
		{
			if (inviteClanId == 0)
				return;

			if (Game.self['clan_id'] != 0)
			{
				dialogAlreadyInClan.show();
				return;
			}

			Game.clanApplication = inviteClanId;
			Connection.sendData(PacketClient.CLAN_JOIN, inviteClanId);
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
			if (this.caption != null)
				return;

			super.onShow();

			this.photo = new ClanPhotoLoader("", 0, 0, 80);
			addChild(this.photo);

			this.caption = new GameField("", 85, 10, style);
			this.caption.addEventListener(MouseEvent.MOUSE_DOWN, onLink);
			addChild(this.caption);

			var description:GameField = new GameField("", 85, 28, style);
			addChild(description);

			switch (this.type)
			{
				case PacketServer.CLAN_INVITE:
					description.htmlText = "<body>" + gls("приглашает тебя в клан") + "<body>";

					var button:ButtonBase = new ButtonBase(gls("Вступить"));
					button.x = 660 - int(button.width * 0.5);
					button.y = 35;
					button.addEventListener(MouseEvent.CLICK, onJoinToClan);
					addChild(button);
					break;
				case PacketServer.CLAN_KICK:
					description.htmlText = gls("<body>выгнал тебя из клана<body>");
					break;
			}

			this.emblem = new ClanEmblemLoader("", 90, 50);
			addChild(this.emblem);

			this.clanName = new GameField("", 100, 45, style);
			addChild(this.clanName);

			var player:Player = Game.getPlayer(this.playerId);

			player.addEventListener(PlayerInfoParser.NAME, onPlayerLoad);
			ClanManager.listen(onLoadClan);

			Game.request(this.playerId, PlayerInfoParser.NAME);
			ClanManager.request(this.clanId);
		}

		private function onLink(e:MouseEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function onJoinToClan(e:MouseEvent):void
		{
			inviteClanId = this.clanId;

			if (Game.self['clan_id'] != 0)
			{
				if (Game.self['clan_duty'] == Clan.DUTY_LEADER)
					dialogJoinLeaderClan.show();
				else
					dialogAlreadyInClan.show();
			}
			else
				dialogJoinToClan.show();
		}

		private function onPlayerLoad(player:Player):void
		{
			player.removeEventListener(onPlayerLoad);

			this.caption.htmlText = "<body><b>" + HtmlTool.anchor(player.name, "event:" + player.id) + "</b><body>";
		}

		private function onLoadClan(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if (clan.id != this.clanId)
				return;

			ClanManager.forget(onLoadClan);

			this.photo.load(clan.photoLink);
			this.emblem.load(clan.emblemLink);

			this.clanName.htmlText = "<body>" + clan.name + "<body>";
		}

		private function onPacket(packet:PacketClanState):void
		{
			if (packet.status != PacketServer.CLAN_STATE_CLOSED &&
				packet.status != PacketServer.CLAN_STATE_BLOCKED &&
				packet.status != PacketServer.CLAN_STATE_BANNED)
				return;

			if (packet.clanId != this.clanId)
				return;

			dispatchEvent(new PostEvent(this.eventId));
		}
	}
}