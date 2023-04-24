package clans
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	import buttons.ButtonBase;
	import chat.ClanChat;
	import chat.ClanChatData;
	import chat.ClanFeeChatData;
	import dialogs.Dialog;
	import dialogs.DialogApplications;
	import dialogs.DialogInfo;
	import dialogs.clan.DialogClanDailyRating;
	import dialogs.clan.DialogClanDonate;
	import dialogs.clan.DialogClanEdit;
	import dialogs.clan.DialogClanPrivateRoom;
	import events.ApplicationsUpdateEvent;
	import events.ClanEvent;
	import screens.ScreenClan;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import tape.TapeData;
	import tape.TapePrivateRoomData;
	import tape.TapePrivateRoomView;
	import tape.TapeView;
	import views.ClanExpirienceView;
	import views.ClanPhotoLoader;
	import views.NewNotice;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBuy;
	import protocol.packages.server.PacketClanPrivateRooms;
	import protocol.packages.server.PacketRoomPrivate;
	import protocol.packages.server.structs.PacketClanPrivateRoomsItems;

	import utils.EditField;
	import utils.FiltersUtil;
	import utils.StringUtil;
	import utils.TextFieldUtil;

	public class ClanRoom extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #363636;
			}
			a {
				text-decoration: underline;
				margin-right: 0px;
			}
			a:hover {
				text-decoration: underline;
				color: #FF1B00;
			}
			.blackSmall {
				color: #0B0B0A;
				font-size: 10px;
			}
			.whiteSmall {
				color: #FFFFFF;
				font-size: 10px;
			}
			.red {
				color: #FF0909;
				font-size: 11px;
				font-weight: bold
			}
			.black {
				color: #000000;
				font-size: 11px;
				font-weight: bold
			}
		]]>).toString();

		static private const CSS2:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 15px;
				color: #FFFFFF;
				font-weight: bold;
				text-align: center;
			}
			a {
				margin-right: 0px;
			}
			a:hover {
				text-decoration: underline;
			}
		]]>).toString();

		static private const ROOM_REFRESH_INTERVAL:int = 5 * 1000;
		static private const ROOM_UPDATE_INTERVAL:int = 60 * 1000;

		static private var _instance:ClanRoom = null;

		private var photoLoader:ClanPhotoLoader = null;

		private var lastRefreshRoomsTime:Number = 0;
		private var roomUpdateInterval:Number = -1;

		private var view:MovieClip;

		private var playerLeader:Player = null;
		private var clan:Clan = null;

		private var _clanId:int = 0;
		private var _leaderId:int = -1;
		private var _applicationCount:int = 0;
		private var _memberCount:int;

		private var style:StyleSheet = new StyleSheet();

		private var acornsBalanceStatus:Status = null;
		private var coinsBalanceStatus:Status = null;

		private var changeNameLabel:GameField = null;
		private var fieldClanName:GameField = null;
		private var fieldClanMembers:GameField = null;

		private var fieldCoinsBalance:GameField = null;
		private var fieldNutsBalance:GameField = null;

		private var fieldClanWarning:GameField = null;

		private var newsLabel:EditField = null;

		private var dialogApplications:Dialog = null;

		private var clanChat:Sprite;

		private var dialogRetireClan:DialogInfo = null;
		private var dialogCloseClan:DialogInfo = null;

		private var dialogPrivateRoom:Dialog = null;
		private var dialogClanEdit:Dialog = null;
		private var dialogDailyRating:Dialog = null;

		private var requestApplication:Boolean = false;

		private var privateRoomsView:TapeView = null;
		private var privateRoomsData:TapeData = null;

		private var clanExpirience:Sprite = null;
		private var imageClanBoard:MovieClip = null;

		private var totemsSlot:Sprite = null;
		private var applicationNotice:Sprite = null;

		private var noPrivateRoomField:GameField = null;

		public function ClanRoom():void
		{
			init();

			_instance = this;

			var button:ButtonBase = new ButtonBase(gls("Отправить"));
			button.x = 768 + this.view.x;
			button.y = 458 + this.view.y;
			button.scaleX = button.scaleY = 0.7;
			addChild(button);

			var field:TextField = new TextField();
			field.x = 540;
			field.y = 458;
			field.defaultTextFormat = new TextFormat(GameField.DEFAULT_FONT, 13, 0x000000);
			field.selectable = true;
			field.type = TextFieldType.INPUT;
			field.width = 215;
			field.height = 18;
			this.view.addChild(field);

			this.clanChat = new ClanChat(field, this.view.chatInputBG, button, new Rectangle(603, 340, 305, 155), this.view.ChatBG, this.newsLabel);
			(this.clanChat as ClanChat).add(new ClanChatData());
			(this.clanChat as ClanChat).add(new ClanFeeChatData());
			addChild(this.clanChat);

			this.nutsCount = 0;
			this.coinsCount = 0;
			Game.listen(onPlayerLoaded);
			ClanManager.listen(onClanLoaded);
			Connection.listen(onPacket, [PacketClanPrivateRooms.PACKET_ID, PacketBuy.PACKET_ID, PacketRoomPrivate.PACKET_ID]);
		}

		static public function get inited():Boolean
		{
			return (_instance != null);
		}

		static public function set applicationCount(value:int):void
		{
			_instance.applicationCount = value;
		}

		static public function set requestApplications(value:Boolean):void
		{
			_instance.requestApplication = value;
		}

		static public function get requestApplications():Boolean
		{
			return _instance.requestApplication;
		}

		static public function getLocation(roomId:int):Boolean
		{
			for each(var room:PacketClanPrivateRoomsItems in (_instance.privateRoomsData as TapePrivateRoomData).roomsInfo)
			{
				if (room.roomId == roomId)
					return true;
			}

			return false;
		}

		public function get clanId():int
		{
			return this._clanId;
		}

		public function set clanId(value:int):void
		{
			if (this.clanId == value)
				return;

			this._clanId = value;

			if (this.roomUpdateInterval == -1)
				this.roomUpdateInterval = setInterval(requestRooms, ROOM_UPDATE_INTERVAL);
			(this.dialogDailyRating as DialogClanDailyRating).clanId = this.clanId;
		}

		public function get leaderId():int
		{
			return this._leaderId;
		}

		public function set leaderId(value:int):void
		{
			if (this._leaderId == value)
				return;

			this._leaderId = value;

			Game.request(this._leaderId, PlayerInfoParser.NAME | PlayerInfoParser.PHOTO);
		}

		public function clearChats():void
		{
			(this.clanChat as ClanChat).clearChats();
		}

		public function onClanDispose():void
		{
			this._clanId = 0;
			this.applicationCount = 0;
			(this.applicationNotice as NewNotice).countNotice = 0;

			this.privateRoomsData.clear();
			this.noPrivateRoomField.visible = true;
			(this.totemsSlot as TotemsSlotView).clearSlot();

			this.newsMessage = "";

			if (this.dialogApplications != null)
			{
				(this.dialogApplications as DialogApplications).clear();

				this.dialogPrivateRoom = null;
				ClanManager.selfClanDonations = [];
				this.requestApplication = false;
			}

			(this.clanChat as ClanChat).clearChats();

			if (this.roomUpdateInterval == -1)
				return;

			clearInterval(this.roomUpdateInterval);
			this.roomUpdateInterval = -1;
		}

		public function set applicationCount(value:int):void
		{
			if (!Game.self)
				return;

			this.view.requestButton.visible = (Game.selfId == this.leaderId) || (Game.self['clan_duty'] == Clan.DUTY_SUBLEADER);
			this.view.buttonInfo.visible = (Game.selfId == this.leaderId) || (Game.self['clan_duty'] == Clan.DUTY_SUBLEADER);
			this._applicationCount = value;
		}

		public function setMemberCount(value:int, max:int):void
		{
			this._memberCount = value;
			this.fieldClanMembers.text = value.toString() + "/" + max.toString();
		}

		public function set coinsCount(value:int):void
		{
			if (this.coinsBalanceStatus != null)
			{
				this.coinsBalanceStatus.remove();
				this.coinsBalanceStatus = null;
			}

			var coinsString:String = value.toString();

			if (value < -99999 || value > 999999)
			{
				var shortValue:int = value / 1000;
				coinsString = shortValue.toString() + "к";
				this.coinsBalanceStatus = new Status(this.fieldCoinsBalance, value.toString(), true);
			}

			this.fieldCoinsBalance.htmlText = '<P ALIGN="RIGHT"><FONT FACE="Droid Sans" SIZE="20" COLOR="' + (value >= 0 ? "#FFFFFF" : "#FF0000") + '" LETTERSPACING="6" KERNING="1"><B>' + coinsString + '</B></FONT></P>';
			this.fieldCoinsBalance.x = this.view.x + 739 + 110 - this.fieldCoinsBalance.textWidth;
		}

		public function set nutsCount(value:int):void
		{
			if (this.acornsBalanceStatus != null)
			{
				this.acornsBalanceStatus.remove();
				this.acornsBalanceStatus = null;
			}

			var acornString:String = value.toString();

			if (value < -99999 || value > 999999)
			{
				var shortValue:int = value / 1000;
				acornString = shortValue.toString() + "к";
				this.acornsBalanceStatus = new Status(this.fieldNutsBalance, value.toString(), true);
			}

			this.fieldNutsBalance.htmlText = '<P ALIGN="RIGHT"><FONT FACE="Droid Sans" SIZE="20" COLOR="' + (value >= 0 ? "#FFFFFF" : "#FF8080") + '" LETTERSPACING="6" KERNING="1"><B>' + acornString + '</B></FONT></P>';
			this.fieldNutsBalance.x = this.view.x + 598 + 110 - this.fieldNutsBalance.textWidth;
		}

		public function set newsMessage(value:String):void
		{
			this.newsLabel.text = value;
		}

		private function init():void
		{
			this.style.parseCSS(CSS);

			var styleLeader:StyleSheet = new StyleSheet();
			styleLeader.parseCSS(CSS2);

			this.dialogRetireClan = new DialogInfo(gls("Покинуть клан"), gls("Ты точно хочешь\nвыйти из клана?"), true, retireClan, 170);
			this.dialogCloseClan = new DialogInfo(gls("Распустить клан"), gls("Ты точно хочешь распустить клан?\nВесь бюджет будет потерян!"), true, closeClan);

			this.dialogClanEdit = new DialogClanEdit();

			this.dialogApplications = new DialogApplications();
			this.dialogApplications.addEventListener(ApplicationsUpdateEvent.NAME, onChangeApplicationsCount);

			this.view = new ClanRoomView();
			this.view.x = 70;
			this.view.y = 50;
			addChild(this.view);

			addChild(new GameField(gls("Клан"), this.view.x + 205, this.view.y + 75, new TextFormat(GameField.PLAKAT_FONT, 23, 0xFFCC00))).filters = Dialog.FILTERS_CAPTION;

			this.fieldClanName = new GameField("", this.view.x + 138, this.view.y + 112, new TextFormat(null, 17, 0xDB4F1A, true, null, null, null, null, "center"), 210);
			addChild(this.fieldClanName);

			this.fieldClanMembers = new GameField("", this.view.x + 275, this.view.y + 185, new TextFormat(null, 16, 0xFFFFFF, true));
			addChild(this.fieldClanMembers);

			this.fieldNutsBalance = new GameField("", this.view.x + 598, this.view.y + 86, this.style);
			addChild(this.fieldNutsBalance);

			this.fieldCoinsBalance = new GameField("", this.view.x + 739, this.view.y + 86, this.style);
			addChild(this.fieldCoinsBalance);

			addChild(new GameField(gls("Участники:"), this.view.x + 175, this.view.y + 185, new TextFormat(null, 16, 0xFFFFFF, true)));

			(this.view as ClanRoomView).safeView.donateButton.addEventListener(MouseEvent.CLICK, onDonate);
			(this.view as ClanRoomView).requestButton.addEventListener(MouseEvent.CLICK, showApplicationsDialog);
			this.applicationCount = 0;

			this.applicationNotice = new NewNotice();
			this.applicationNotice.x = (this.view as ClanRoomView).requestButton.x + 50;
			this.applicationNotice.y = (this.view as ClanRoomView).requestButton.y + 60;
			addChild(this.applicationNotice);
			(this.applicationNotice as NewNotice).countNotice = 0;

			(this.view as ClanRoomView).closeClanButton.addEventListener(MouseEvent.CLICK, onCloseClan);
			(this.view as ClanRoomView).retireButton.addEventListener(MouseEvent.CLICK, onRetireClan);

			new Status((this.view as ClanRoomView).closeClanButton, gls("Распустить клан"));
			new Status((this.view as ClanRoomView).retireButton, gls("Выйти из клана"));
			new Status((this.view as ClanRoomView).requestButton, gls("Заявки в клан"));
			new Status((this.view as ClanRoomView).safeView.donateButton, gls("Пополнить бюджет клана"));
			new Status((this.view as ClanRoomView).privateRooms.roomBuyButton, gls("Купить частный район"));
			new Status((this.view as ClanRoomView).privateRooms.roomRefreshButton, gls("Обновить список частных районов"));

			this.changeNameLabel = new GameField(gls("<body><a class='blackSmall' href='event:#'>Изменить данные</a></body>"), 190+135, 101+70+17, this.style);
			this.changeNameLabel.addEventListener(MouseEvent.CLICK, onEditName);
			this.changeNameLabel.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			this.changeNameLabel.addEventListener(MouseEvent.ROLL_OVER, soundOver);
			addChild(this.changeNameLabel);

			(this.view as ClanRoomView).privateRooms.roomRefreshButton.addEventListener(MouseEvent.CLICK, requestRooms);
			(this.view as ClanRoomView).privateRooms.roomBuyButton.addEventListener(MouseEvent.CLICK, buyRoom);

			var formatNews:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000);

			this.newsLabel = new EditField("", 0, 0, 308, 148, formatNews, formatNews, 339);
			this.newsLabel.type = TextFieldType.DYNAMIC;
			this.newsLabel.selectable = true;
			this.newsLabel.background = false;
			this.newsLabel.border = false;
			this.newsLabel.multiline = true;
			this.newsLabel.wordWrap = true;
			this.newsLabel.maxChars = 1024;

			this.photoLoader = new ClanPhotoLoader("", 39, 105);
			this.photoLoader.mouseEnabled = false;
			this.photoLoader.mouseChildren = false;
			(this.view as ClanRoomView).addChild(this.photoLoader);

			this.privateRoomsData = new TapePrivateRoomData();

			this.privateRoomsView = new TapePrivateRoomView();
			this.privateRoomsView.x = 25;
			this.privateRoomsView.y = 25;
			this.privateRoomsView.setData(this.privateRoomsData);
			(this.view as ClanRoomView).privateRooms.addChild(this.privateRoomsView);

			this.noPrivateRoomField = new GameField(gls("У клана ещё нет своих районов.\nВы можете купить их."), 35, 40, new TextFormat(GameField.DEFAULT_FONT, 14, 0x663C0D, true));
			(this.view as ClanRoomView).privateRooms.addChild(this.noPrivateRoomField);

			this.clanExpirience = new ClanExpirienceView();
			this.clanExpirience.x = 132;
			this.clanExpirience.y = 154;
			(this.view as ClanRoomView).addChild(this.clanExpirience);

			this.totemsSlot = new TotemsSlotView();
			this.totemsSlot.x = 115;
			this.totemsSlot.y = 270;
			addChild(this.totemsSlot);

			this.imageClanBoard = new ImageClanBoard();
			this.imageClanBoard.visible = false;
			this.imageClanBoard.x = 110;
			this.imageClanBoard.y = 295;
			addChild(this.imageClanBoard);

			this.fieldClanWarning = new GameField("", 170, 365, new TextFormat(null, 12, 0xFF0000, true, null, null, null, null, "center"));
			addChild(this.fieldClanWarning);

			(this.view as ClanRoomView).buttonInfo.visible = false;
			(this.view as ClanRoomView).buttonInfo.addEventListener(MouseEvent.CLICK, dialogRatingShow);
			(this.view as ClanRoomView).buttonInfo.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			(this.view as ClanRoomView).buttonInfo.addEventListener(MouseEvent.ROLL_OVER, soundOver);
			new Status((this.view as ClanRoomView).buttonInfo, gls("Статистика клана"));

			this.dialogDailyRating = new DialogClanDailyRating(this.clanId);
		}

		private function soundClick(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.CLICK);
		}

		private function soundOver(e:MouseEvent):void
		{

		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player.id != this._leaderId)
				return;

			this.playerLeader = player;
		}

		private function onClanLoaded(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if (clan.id != this._clanId)
				return;

			this.clan = clan;

			this.leaderId = this.clan.leaderId;
			setMemberCount(clan.size, ClanExperience.getFreePlaces(clan.level) + clan.places);

			TextFieldUtil.formatField(this.fieldClanName, clan.name, 204);

			this.blockType = clan.state;
			this.nutsCount = clan.acorns;
			this.coinsCount = clan.coins;

			if (this.clan.exp >= this.clan.maxExp && (this.clan.exp != 0 && this.clan.maxExp != 0) && this.clan.state != PacketClient.CLAN_CLOSE && this.clan.level != ClanExperience.MAX_LEVEL)
				ClanManager.request(this.clan.id, true, ClanInfoParser.RANK | ClanInfoParser.RANK_RANGE);

			(this.clanExpirience as ClanExpirienceView).setData(clan.exp, clan.level, clan.maxExp, clan.dailyExp, ClanExperience.maxDailyExp(clan.level));

			this.photoLoader.load(e.clan.photoLink);

			toggleClanLeaderItems(Game.selfId == this.leaderId);
			requestRooms();

			if (this.newsLabel.type == TextFieldType.DYNAMIC)
				this.newsLabel.text = clan.news;

			(this.dialogApplications as DialogApplications).setPlaceCost(clan.places);

			(this.totemsSlot as TotemsSlotView).setClan(clan);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketClanPrivateRooms.PACKET_ID:
					(this.privateRoomsData as TapePrivateRoomData).loadData((packet as PacketClanPrivateRooms).items);
					(this.privateRoomsView as TapePrivateRoomView).refreshInfo();
					this.noPrivateRoomField.visible = (this.privateRoomsData as TapePrivateRoomData).roomsInfo.length < 1;
					break;
				case PacketBuy.PACKET_ID:
					var buy: PacketBuy = packet as PacketBuy;

					switch (buy.goodId)
					{
						case PacketClient.BUY_CLAN_ROOM:
							if (buy.status != PacketServer.BUY_SUCCESS)
								break;
							var bytes: ByteArray = new ByteArray();
							bytes.writeInt(buy.targetId);
							bytes.writeByte(buy.data >> 8);
							bytes.writeByte(0);
							bytes.writeByte(0);
							bytes.writeShort(0);
							bytes.position = 0;

							var data: PacketClanPrivateRoomsItems = new PacketClanPrivateRoomsItems(bytes);

							(this.privateRoomsData as TapePrivateRoomData).addData(data);
							(this.privateRoomsView as TapePrivateRoomView).refreshInfo();
							this.noPrivateRoomField.visible = (this.privateRoomsData as TapePrivateRoomData).roomsInfo.length < 1;
							if (buy.playerId == Game.selfId && this.dialogPrivateRoom)
								this.dialogPrivateRoom.hide();
							requestRooms();
							break;
						case PacketClient.BUY_CLAN_PLACE:
							if (buy.status != PacketServer.BUY_SUCCESS)
								break;
							this.clan.places += DialogApplications.SQUIRRELS_PACKET_SIZE;
							setMemberCount(this.clan.size, ClanExperience.getFreePlaces(this.clan.level) + this.clan.places);
							(this.dialogApplications as DialogApplications).setPlaceCost(this.clan.places);
							break;
					}
					break;
				case PacketRoomPrivate.PACKET_ID:
					var roomPrivate: PacketRoomPrivate = packet as PacketRoomPrivate;

					if (!roomExists(roomPrivate.roomId))
						return;

					switch (roomPrivate.status)
					{
						case PacketServer.ROOM_EXPIRED:
							new DialogInfo(gls("Частный район"), gls("Время комнаты истекло."), false, null, 180).show();
						case PacketServer.ROOM_NOT_EXIST:
							deleteRoom(roomPrivate.roomId);
							break;
						case PacketServer.ROOM_FULL:
							new DialogInfo(gls("Частный район"), gls("В комнате нет мест."), false, null, 150).show();
							requestRooms();
							break;
						case PacketServer.ROOM_NOT_EXIST_CLAN:
							break;
					}
					break;
			}
		}

		private function set blockType(value:int):void
		{
			(this.view as ClanRoomView).requestButton.enabled = (this.view as ClanRoomView).requestButton.mouseEnabled = value != PacketServer.CLAN_STATE_BANNED;

			this.totemsSlot.visible = value == PacketServer.CLAN_STATE_SUCCESS;
			this.fieldClanWarning.text = "";
			if (value == PacketServer.CLAN_STATE_BLOCKED && this.clan.size > ClanExperience.getFreePlaces(this.clan.level) + this.clan.places)
				this.fieldClanWarning.text = gls("Лимит на размер\nклана превышен.\nКлану заблокирован\nдоступ к тотемам\nи получению опыта.");
			if (value == PacketServer.CLAN_STATE_BLOCKED && this.clan.acorns < 0)
				this.fieldClanWarning.text = gls("Внимание!\nВаш клан заблокирован за\nнеуплату. Погасите долг,\nчтобы разблокировать клан.\n\n\n\t\t\t\t\tАдминистрация");
			if (value == PacketServer.CLAN_STATE_BANNED)
				this.fieldClanWarning.text = gls("Внимание!\nВаш клан заблокирован за\nнарушение правил поведения.\n\t\t\t\t\tАдминистрация");
			this.imageClanBoard.visible = this.fieldClanWarning.text != "";

			this.privateRoomsView.mouseEnabled = this.privateRoomsView.mouseChildren = value != PacketServer.CLAN_STATE_BANNED;
			this.privateRoomsView.filters = (this.view as ClanRoomView).requestButton.filters = value != PacketServer.CLAN_STATE_BANNED ? [] : FiltersUtil.GREY_FILTER;

			(this.view as ClanRoomView).privateRooms.mouseEnabled = (this.view as ClanRoomView).privateRooms.mouseChildren = value != PacketServer.CLAN_STATE_BANNED;
			(this.view as ClanRoomView).privateRooms.filters = value != PacketServer.CLAN_STATE_BANNED ? [] : FiltersUtil.GREY_FILTER;
		}

		private function onDonate(e:Event):void
		{
			new DialogClanDonate().show();
		}

		private function toggleClanLeaderItems(isLeader:Boolean):void
		{
			if (this.dialogPrivateRoom == null)
				this.dialogPrivateRoom = new DialogClanPrivateRoom();

			(this.clanChat as ClanChat).leader = isLeader;

			(this.view as ClanRoomView).requestButton.visible = isLeader || (Game.self['clan_duty'] == Clan.DUTY_SUBLEADER);
			(this.view as ClanRoomView).closeClanButton.visible = isLeader;
			(this.view as ClanRoomView).retireButton.visible = !isLeader;
			(this.view as ClanRoomView).buttonInfo.visible = isLeader || (Game.self['clan_duty'] == Clan.DUTY_SUBLEADER);

			(this.clanChat as ClanChat).toggleNewsEditButton(isLeader || (Game.self['clan_duty'] == Clan.DUTY_SUBLEADER));
			this.changeNameLabel.visible = isLeader;
			(this.view as ClanRoomView).clanEmblem.mouseEnabled = isLeader;
			(this.totemsSlot as TotemsSlotView).toggleClanLeaderItems(isLeader || (Game.self['clan_duty'] == Clan.DUTY_SUBLEADER));

			if (isLeader)
			{
				(this.view as ClanRoomView).clanEmblem.addEventListener(MouseEvent.CLICK, onEditName);
				new Status((this.view as ClanRoomView).clanEmblem, gls("Изменить данные"));
			}

			this.newsLabel.text = StringUtil.trim(this.newsLabel.text);
			this.newsLabel.text = StringUtil.removeHtmlTags(this.newsLabel.text);

			if (ClanManager.selfClanNews == null || ClanManager.selfClanNews == this.newsLabel.text)
				return;

			if ((Game.self['clan_duty'] != Clan.DUTY_LEADER) && (Game.self['clan_duty'] != Clan.DUTY_SUBLEADER))
				this.newsLabel.text = ClanManager.selfClanNews;
			else if (this.newsLabel.textHeight > 148)
				this.newsLabel.text = ClanManager.selfClanNews;
		}

		private function showApplicationsDialog(e:MouseEvent):void
		{
			if ((Game.self['clan_duty'] != Clan.DUTY_LEADER) && (Game.self['clan_duty'] != Clan.DUTY_SUBLEADER))
				return;

			this.dialogApplications.show();
		}

		private function onChangeApplicationsCount(e:ApplicationsUpdateEvent):void
		{
			(this.applicationNotice as NewNotice).countNotice = e.count;
			this.applicationNotice.visible = (this.applicationNotice as NewNotice).countNotice > 0;
			this.applicationCount = e.count;
		}

		private function onCloseClan(e:MouseEvent):void
		{
			this.dialogCloseClan.show();
		}

		private function buyRoom(e:MouseEvent = null):void
		{
			if (this.dialogPrivateRoom == null)
				return;

			this.dialogPrivateRoom.show();
		}

		private function closeClan():void
		{
			Connection.sendData(PacketClient.CLAN_CLOSE);
		}

		private function onRetireClan(e:MouseEvent):void
		{
			this.dialogRetireClan.show();
		}

		private function retireClan():void
		{
			Connection.sendData(PacketClient.CLAN_LEAVE);
		}

		private function onEditName(e:MouseEvent):void
		{
			(this.dialogClanEdit as DialogClanEdit).id = this.clanId;
			this.dialogClanEdit.show();
		}

		private function requestRooms(e:MouseEvent = null):void
		{
			var currentTime:Number = new Date().getTime();

			if ((this.privateRoomsData as TapePrivateRoomData).roomsInfo == null)
			{
				this.lastRefreshRoomsTime = currentTime;
				Connection.sendData(PacketClient.CLAN_GET_ROOMS);
			}

			if (this.clanId == 0 || !(Screens.active is ScreenClan) || Game.self['clan_id'] == 0)
				return;

			if (ClanManager.getClan(Game.self['clan_id']).state != PacketServer.CLAN_STATE_SUCCESS)
				return;

			if (Math.abs(currentTime - this.lastRefreshRoomsTime) < ROOM_REFRESH_INTERVAL)
				return;

			this.lastRefreshRoomsTime = currentTime;

			Connection.sendData(PacketClient.CLAN_GET_ROOMS);
		}

		private function roomExists(id:int):Boolean
		{
			return (this.privateRoomsData as TapePrivateRoomData).roomExist(id);
		}

		private function deleteRoom(id:int):void
		{
			(this.privateRoomsData as TapePrivateRoomData).deleteData(id);
			this.noPrivateRoomField.visible = (this.privateRoomsData as TapePrivateRoomData).roomsInfo.length < 1;
		}

		private function dialogRatingShow(e:MouseEvent):void
		{
			this.dialogDailyRating.show();
		}
	}
}