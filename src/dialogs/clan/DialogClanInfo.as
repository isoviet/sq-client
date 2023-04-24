package dialogs.clan
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import clans.Clan;
	import clans.ClanManager;
	import dialogs.Dialog;
	import dialogs.DialogInfo;
	import events.ClanEvent;
	import menu.MenuProfile;
	import views.ClanPhotoLoader;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;

	import utils.StringUtil;
	import utils.TextFieldUtil;

	public class DialogClanInfo extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
			}
			a {
				color: #017ACC;
				text-decoration: none;
				margin-right: 0px;
				font-weight: bold;
			}
			a:hover {
				text-decoration: underline;
			}
			.black {
				color: #000000;
				text-align: center;
				font-weight: regular;
			}
		]]>).toString();

		static private const WIDTH:int = 210;

		static private var _instance:DialogClanInfo = null;

		private var dialogAlreadyInClan:DialogInfo = null;
		private var dialogApplicationClan:DialogInfo = null;
		private var dialogRetireClan:DialogInfo = null;

		private var nameField:GameField = null;
		private var ratingField:GameField = null;
		private var leaderField:GameField = null;
		private var membersField:GameField = null;
		private var applicationField:GameField = null;
		private var applicationBlockField:GameField = null;

		private var clanId:int = NaN;
		private var leaderId:int = NaN;

		private var photo:ClanPhotoLoader = null;

		private var buttonApplication:ButtonBase = null;
		private var buttonLeave:ButtonBase = null;

		private var leaderSprite:Sprite;

		public function DialogClanInfo():void
		{
			super();

			init();

			ClanManager.listen(onClanLoaded);
			Game.listen(onPlayerLoaded);
		}

		static public function show(id:int):void
		{
			if (_instance == null)
				_instance = new DialogClanInfo();

			var clansOpened:Boolean = (Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS);

			if (!clansOpened || (Game.self['clan_id'] != 0 && (Game.self['clan_duty'] == Clan.DUTY_LEADER)))
				_instance.height = 160;
			else
				_instance.height = 200;

			_instance.clear();
			_instance.place();
			_instance.clanId = id;
			ClanManager.request(id, true);

			_instance.show();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.dialogAlreadyInClan = new DialogInfo(gls("Ты уже в клане"), gls("Чтобы подать заявку в этот клан, ты должен выйти из своего."));
			this.dialogApplicationClan = new DialogInfo(gls("Попроситься в клан"), gls("Ты уверен, что хочешь\nподать заявку на вступление в клан?"), true, applicationToClan);
			this.dialogRetireClan = new DialogInfo(gls("Покинуть клан"), gls("Ты уверен, что хочешь\nвыйти из клана?"), true, retireClan);

			this.clanId = -1;

			this.photo = new ClanPhotoLoader("", 0, 45);
			this.photo.x = int((WIDTH - 50) / 2);
			this.photo.mouseEnabled = false;
			this.photo.mouseChildren = false;
			addChild(this.photo);

			var nameFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0x663C0D, true);
			nameFormat.align = TextFormatAlign.CENTER;

			var applicationFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 14, 0x000000, true);
			applicationFormat.align = TextFormatAlign.CENTER;

			var applicationBlockedFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000, true);
			applicationBlockedFormat.align = TextFormatAlign.CENTER;

			var ratingFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x177B2B, true);
			ratingFormat.align = TextFormatAlign.CENTER;

			this.nameField = new GameField("", 0, 3, nameFormat);
			this.nameField.width = WIDTH;
			this.nameField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.nameField);

			this.ratingField = new GameField("", 0, 24, ratingFormat);
			this.ratingField.width = WIDTH;
			this.ratingField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.ratingField);

			this.leaderSprite = new Sprite();
			this.leaderSprite.y = 98;
			addChild(this.leaderSprite);

			this.leaderSprite.addChild(new GameField(gls("<body><span class='black'><b>Вождь:</b></body>"), 0, 0, style));

			this.leaderField = new GameField("", 54, 0, style);
			this.leaderField.addEventListener(MouseEvent.MOUSE_UP, onClick);
			this.leaderSprite.addChild(this.leaderField);

			this.leaderSprite.x = int((WIDTH - this.leaderSprite.width) / 2);

			this.membersField = new GameField("", 0, 114, style);
			this.membersField.width = WIDTH;
			this.membersField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.membersField);

			this.applicationField = new GameField(gls("Заявка отправлена"), 0, 145, applicationFormat);
			this.applicationField.width = WIDTH;
			this.applicationField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.applicationField);

			this.applicationBlockField = new GameField(gls("Чтобы вступить в этот клан, ты должен выйти из своего."), 0, 145, applicationBlockedFormat);
			this.applicationBlockField.width = WIDTH;
			this.applicationBlockField.autoSize = TextFieldAutoSize.CENTER;
			this.applicationBlockField.multiline = true;
			this.applicationBlockField.wordWrap = true;
			addChild(this.applicationBlockField);

			this.buttonApplication = new ButtonBase(gls("Подать заявку"));
			this.buttonApplication.x = int((WIDTH - this.buttonApplication.width) / 2);
			this.buttonApplication.y = 140;
			this.buttonApplication.addEventListener(MouseEvent.CLICK, sendApplication);
			addChild(this.buttonApplication);

			this.buttonLeave = new ButtonBase(gls("Выйти из клана"));
			this.buttonLeave.x = int((WIDTH - this.buttonLeave.width) / 2) + 8;
			this.buttonLeave.y = 138;
			this.buttonLeave.addEventListener(MouseEvent.CLICK, showLeave);
			addChild(this.buttonLeave);

			place();
		}

		override public function clear():void
		{
			super.clear();

			this.photo.reset();

			this.nameField.text = "";
			this.ratingField.text = "";
			this.leaderField.htmlText = "";
			this.membersField.htmlText = "";

			this.leaderId = 0;

			this.buttonApplication.visible = false;
			this.buttonLeave.visible = false;
		}

		private function showLeave(e:MouseEvent):void
		{
			this.dialogRetireClan.show();
		}

		private function sendApplication(e:MouseEvent):void
		{
			this.dialogApplicationClan.show();
		}

		private function applicationToClan():void
		{
			if (Game.self['clan_id'] != 0)
			{
				this.dialogAlreadyInClan.show();
				return;
			}

			Game.clanApplication = this.clanId;
			this.buttonApplication.visible = false;
			//this.applicationField.visible = true;

			ClanManager.request(this.clanId, true);

			Connection.sendData(PacketClient.CLAN_JOIN, this.clanId);
		}

		private function retireClan():void
		{
			Connection.sendData(PacketClient.CLAN_LEAVE);
		}

		private function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.target.name);
		}

		private function onClanLoaded(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if (clan.id != this.clanId)
				return;

			this.photo.load(clan.photoLink);

			var clansOpened:Boolean = (Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS);
			var inBlacklist:Boolean = (clan.blacklist.indexOf(Game.selfId) != -1);
			var isLowLevel:Boolean = (Experience.selfLevel < clan.levelLimiter);

			this.buttonApplication.visible = (!inBlacklist && !isLowLevel && clansOpened && Game.clanApplication != this.clanId && Game.self['clan_id'] == 0 && (clan.state == PacketServer.CLAN_STATE_SUCCESS || clan.state == PacketServer.CLAN_STATE_BLOCKED));

			this.buttonLeave.visible = (clansOpened && clan.id == Game.self['clan_id'] && (Game.self['clan_duty'] != Clan.DUTY_LEADER));

			this.applicationField.visible = ((clansOpened && !this.buttonLeave.visible && (Game.self['clan_duty'] != Clan.DUTY_LEADER) && (inBlacklist || isLowLevel || (clan.state != PacketServer.CLAN_STATE_SUCCESS && clan.state != PacketServer.CLAN_STATE_BLOCKED)) || (Game.clanApplication == this.clanId && Game.self['clan_id'] == 0)));
			if (this.applicationField.visible)
			{
				this.height = 240;
				var state:String = "";
				if (clan.state == PacketServer.CLAN_STATE_CLOSED)
					state = gls("Клан закрыт");
				else if (clan.state == PacketServer.CLAN_STATE_BANNED)
					state = gls("Клан заблокирован");
				else
					state = gls("Заявка отправлена");

				if (inBlacklist)
					this.applicationField.text = gls("Вы не можете подать заявку в\nданный клан, так как вы\nв черном списке этого клана");
				else if (isLowLevel)
					this.applicationField.text = gls("Для вступления в клан\nнеобходим {0} уровень", clan.levelLimiter);
				else
					this.applicationField.text = state;
			}

			this.applicationBlockField.visible = !this.applicationField.visible && (clansOpened && clan.id != Game.self['clan_id'] && Game.self['clan_id'] != 0 && (Game.self['clan_duty'] != Clan.DUTY_LEADER) && clan.state != PacketServer.CLAN_STATE_CLOSED && (clan.state == PacketServer.CLAN_STATE_SUCCESS));

			TextFieldUtil.formatField(this.nameField, clan.name, 208);

			if (clan.ratingPlace != 0)
				this.ratingField.text =  gls("{0}{1} место в рейтинге", clan.ratingPlace, ((clan.ratingPlace % 10 == 3) ? gls("-e") : gls("-ое")));	//TODO call numeral method

			this.membersField.htmlText = gls("<body><span class='black'>В клане <b>{0}</b> {1}</span><body>", clan.size, StringUtil.word("белка", clan.size));

			if (this.leaderId == clan.leaderId)
				return;

			this.leaderId = clan.leaderId;
			Game.request(this.leaderId, PlayerInfoParser.NAME | PlayerInfoParser.CLAN);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player['id'] != this.leaderId)
				return;

			this.leaderField.name = this.leaderId.toString();
			TextFieldUtil.formatField(this.leaderField, player.name, 240, true, (this.leaderId != Game.selfId));
			this.leaderSprite.x = int((WIDTH - this.leaderSprite.width) / 2);
		}
	}
}