package menu
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import clans.Clan;
	import clans.ClanManager;
	import dialogs.Dialog;
	import dialogs.DialogBlock;
	import dialogs.DialogInfo;
	import dialogs.collections.DialogCollectionExchange;
	import events.GameEvent;
	import events.ScreenEvent;
	import game.gameData.CollectionManager;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import screens.ScreenGame;
	import screens.ScreenProfile;
	import screens.Screens;
	import views.OnlineIcon;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;

	public class MenuProfile extends ContextMenu
	{
		static private var _instance:MenuProfile;
		static private var _dispatcher:EventDispatcher = new EventDispatcher();

		private var player:Player = null;

		private var title:Sprite;
		private var game:ContextMenuItem;
		private var invite:ContextMenuItem;
		private var profileVK:ContextMenuItem;
		private var profileMM:ContextMenuItem;
		private var profileOK:ContextMenuItem;
		private var profileFS:ContextMenuItem;
		private var profileNG:ContextMenuItem;
		private var profileFB:ContextMenuItem;
		private var profileSA:ContextMenuItem;
		private var friend:ContextMenuItem;
		private var notFriend:ContextMenuItem;
		private var ignore:ContextMenuItem;
		private var notIgnore:ContextMenuItem;
		private var clanApplication:ContextMenuItem;
		private var clanInvite:ContextMenuItem;
		private var clanKick:ContextMenuItem;
		private var clanSubleader:ContextMenuItem;
		private var notClanSubleader:ContextMenuItem;
		private var spy:ContextMenuItem;
		private var ban:ContextMenuItem;
		private var exchange:ContextMenuItem;
		private var clanInBlacklist:ContextMenuItem;
		private var clanOutBlacklist:ContextMenuItem;

		private var onlineIcon:OnlineIcon;
		private var levelField:GameField;
		private var backgroundImage:DisplayObject;

		private var dialogBlock:Dialog = null;
		private var dialogAddFriend:DialogInfo = null;
		private var dialogRemoveFriend:DialogInfo = null;
		private var dialogSubleader:DialogInfo = null;
		private var dialogSubleaderBorder:DialogInfo = null;
		private var dialogFireSubleader:DialogInfo = null;

		private var dialogApplicationClan:DialogInfo = null;
		private var dialogInviteClan:DialogInfo = null;
		private var dialogCantInviteClan:DialogInfo = null;
		private var dialogKickClan:DialogInfo = null;
		private var dialogInBlacklist:DialogInfo = null;
		private var dialogOutBlacklist:DialogInfo = null;

		private var inited:Boolean = false;

		public function MenuProfile():void
		{
			_instance = this;

			super(141);
		}

		static public function showMenu(id:int):void
		{
			if (!_instance.inited)
			{
				_instance.init();
				_instance.inited = true;
			}

			if (id == Game.selfId)
				return;

			var player:Player = Game.getPlayer(id);
			if (player == null)
				return;

			if (_instance.player)
				_instance.player.removeEventListener(_instance.onPlayerLoaded);

			_instance.player = player;

			Game.stage.addEventListener(MouseEvent.MOUSE_UP, _instance.onMouseUp);
		}

		static public function isShowing():Boolean
		{
			return _instance.visible;
		}

		static public function hide():void
		{
			_instance.visible = false;
		}

		static public function update():void
		{
			_instance.update();
		}

		static public function listen(event:String, callback:Function):void
		{
			if(_dispatcher)
				_dispatcher.addEventListener(event, callback);
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			_dispatcher.dispatchEvent(new GameEvent(GameEvent.SHOWED));
		}

		override public function update(shift:int = 42):void
		{
			if (shift) {/*unused*/}

			super.update(this.title.height);

			this.backgroundImage.height = int(this.title.height) + this.displayedCount * 22 + 0.5;
		}

		override protected function show(e:MouseEvent):void
		{
			this.ignore.hide();
			this.notIgnore.hide();
			this.friend.hide();
			this.notFriend.hide();
			this.clanApplication.hide();
			this.clanInvite.hide();
			this.clanKick.hide();
			this.clanInBlacklist.hide();
			this.clanOutBlacklist.hide();
			this.clanSubleader.hide();
			this.notClanSubleader.hide();

			this.profileVK.hide();
			this.profileFS.hide();
			this.profileMM.hide();
			this.profileOK.hide();
			this.profileNG.hide();
			this.profileFB.hide();
			this.profileSA.hide();
			this.spy.hide();
			this.ban.hide();

			this.game.active = false;
			this.spy.active = false;

			this.levelField.text = Experience.getTextLevel(this.player['exp']);
			this.onlineIcon.setPlayer(this.player);
			(this.title as ContextMenuItemInfo).setPlayer(this.player);

			checkIgnoreList();

			if (!Game.isFriend(this.player.id))
				this.friend.show();
			else
				this.notFriend.show();

			this.exchange.active = !CollectionManager.isExchangeEmpty;

			var accessToProfile:Boolean = true;
			if ((Game.self.type == Config.API_OK_ID || Game.self.type == Config.API_MM_ID) && (Game.self.type != this.player.type))
				accessToProfile = false;

			// Susanin ban
			if (this.player.id == 3743112)
				accessToProfile = false;

			switch (this.player.type)
			{
				case Config.API_VK_ID:
					this.profileVK.show();
					this.profileVK.active = accessToProfile || Game.self['moderator'];
					break;
				case Config.API_MM_ID:
					this.profileMM.show();
					this.profileMM.active = accessToProfile || Game.self['moderator'];
					break;
				case Config.API_OK_ID:
					this.profileOK.show();
					this.profileOK.active = accessToProfile || Game.self['moderator'];
					break;
				case Config.API_FS_ID:
					this.profileFS.show();
					this.profileFS.active = accessToProfile || Game.self['moderator'];
					break;
				case Config.API_FB_ID:
					this.profileFB.show();
					this.profileFB.active = accessToProfile || Game.self['moderator'];
					break;
				case Config.API_SA_ID:
					this.profileSA.show();
					this.profileSA.active = false;
					break;
			}

			var clan:Clan = ClanManager.getClan(Game.self['clan_id']);

			if (Game.self['clan_id'] == 0 && this.player['clan_id'] != 0 && Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS)
				this.clanApplication.show();

			if (Game.self['clan_id'] != 0 && (Game.self['clan_duty'] == Clan.DUTY_LEADER))
			{
				if (this.player['level'] >= Game.LEVEL_TO_OPEN_CLANS && this.player['clan_id'] != Game.self['clan_id'] && clan.blacklist.indexOf(this.player['id']) == -1)
					this.clanInvite.show();
				if (this.player['clan_id'] == Game.self['clan_id'])
					this.clanKick.show();
			}

			if (Game.self['clan_id'] != 0 && Game.self['clan_duty'] == Clan.DUTY_LEADER)
			{
				if (clan.blacklist.indexOf(this.player['id']) == -1)
					this.clanInBlacklist.show();
				else
					this.clanOutBlacklist.show();
			}

			if (Game.self['clan_id'] != 0 && Game.self['clan_duty'] == Clan.DUTY_SUBLEADER)
			{
				if (clan.blacklist.indexOf(this.player['id']) == -1 && (this.player['id'] != clan.leaderId) && ClanManager.subLeaderIds.indexOf(this.player['id']) == -1)
					this.clanInBlacklist.show();
			}

			if (Game.self['clan_id'] != 0 && (Game.self['clan_duty'] == Clan.DUTY_SUBLEADER))
			{
				if (this.player['clan_id'] == Game.self['clan_id'] && (this.player['clan_duty'] != Clan.DUTY_SUBLEADER) && (this.player.id != clan.leaderId))
					this.clanKick.show();

				if (this.player['clan_id'] != Game.self['clan_id'])
					this.clanInvite.show();
			}

			if (Game.self['clan_id'] != 0 && (Game.self['clan_duty'] == Clan.DUTY_LEADER))
			{
				if (this.player['clan_id'] == Game.self['clan_id'])
				{
					if (this.player['clan_duty'] != Clan.DUTY_SUBLEADER)
						this.clanSubleader.show();
					else
						this.notClanSubleader.show();
				}
			}

			if (Game.self.moderator)
			{
				this.spy.show();
			}

			if (Game.self.moderator && !this.player.moderator)
				this.ban.show();

			this.game.active = !(Screens.active is ScreenGame);
			this.spy.active = !(Screens.active is ScreenGame);
			this.invite.active = !(Screens.active is ScreenGame);

			update();

			super.show(e);
		}

		private function onMouseUp(e:MouseEvent = null):void
		{
			if (this.player)
			{
				this.player.addEventListener(PlayerInfoParser.ALL, onPlayerLoaded);
				Game.request(this.player['id'], PlayerInfoParser.ALL);
			}

			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function onPlayerLoaded(player:Player):void
		{
			player.removeEventListener(onPlayerLoaded);
			show(null);
		}

		private function init():void
		{
			this.title = new ContextMenuItemInfo();
			this.title.x = 1;
			addChild(this.title);

			this.game = add({'active': new GameActiveMenuItem, 'passive': new GameMenuItem, 'name': gls("Перейти в игру"), 'handler': onGame});
			this.invite = add({'active': new InviteActiveMenuItem, 'passive': new InviteMenuItem, 'name': gls("Сходить в гости"), 'handler': onView});
			this.profileVK = add({'active': new ProfileVKActiveMenuItem, 'passive': new ProfileVKMenuItem, 'name': gls("Перейти на профиль"), 'handler': onProfile});
			this.profileMM = add({'active': new ProfileMMActiveMenuItem, 'passive': new ProfileMMMenuItem, 'name': gls("Перейти на профиль"), 'handler': onProfile});
			this.profileOK = add({'active': new ProfileOKActiveMenuItem, 'passive': new ProfileOKMenuItem, 'name': gls("Перейти на профиль"), 'handler': onProfile});
			this.profileFS = add({'active': new ProfileFSActiveMenuItem, 'passive': new ProfileFSMenuItem, 'name': gls("Перейти на профиль"), 'handler': onProfile});
			this.profileNG = add({'active': new ProfileNGActiveMenuItem, 'passive': new ProfileNGMenuItem, 'name': gls("Перейти на профиль"), 'handler': onProfile});
			this.profileFB = add({'active': new ProfileFBActiveMenuItem, 'passive': new ProfileFBMenuItem, 'name': gls("Перейти на профиль"), 'handler': onProfile});
			this.profileSA = add({'active': new ProfileSAActiveMenuItem, 'passive': new ProfileSAMenuItem, 'name': gls("Перейти на профиль"), 'handler': onProfile});
			this.friend = add({'active': new FriendActiveMenuItem, 'name': gls("Добавить в друзья"), 'handler': onFriend});
			this.notFriend = add({'active': new NoFriendActiveMenuItem, 'name': gls("Убрать из друзей"), 'handler': onNotFriend});
			this.ignore = add({'active': new IgnoreActiveMenuItem, 'name': gls("Игнорировать"), 'handler': onIgnore});
			this.notIgnore = add({'active': new NotIgnoreActiveMenuItem, 'name': gls("Убрать из игнора"), 'handler': onNotIgnore});
			this.clanApplication = add({'active': new ClanInviteActiveMenuItem, 'name': gls("Попроситься в клан"), 'handler': onApplicationClan});
			this.clanInvite = add({'active': new ClanInviteActiveMenuItem, 'name': gls("Пригласить в клан"), 'handler': onInviteClan});
			this.clanKick = add({'active': new ClanKickActiveMenuItem, 'name': gls("Выгнать из клана"), 'handler': onKickClan});
			this.clanInBlacklist = add({'active': new ClanAddInBlacklist, 'name': gls("Добавить в чс"), 'handler': onInBlacklist});
			this.clanOutBlacklist = add({'active': new ClanRemoveFromBlacklist, 'name': gls("Удалить из чс"), 'handler': onOutBlacklist});
			this.clanSubleader = add({'active': new ClanSubleaderActiveMenuItem, 'name': gls("Сделать помощником"), 'handler': onClanSubleader});
			this.notClanSubleader = add({'active': new ClanFireSubleaderActiveMenuItem, 'name': gls("Снять с должности"), 'handler': onNotClanSubleader});
			this.exchange = add({'active': new ProfileExchangeActiveMenuItem, 'passive': new ProfileExchangeMenuItem, 'name': gls("Обмен"), 'handler': onExchange});
			this.spy = add({'active': new SpyMenuActiveItem, 'passive': new SpyMenuItem, 'name': gls("Наблюдать"), 'handler': onSpy});
			this.ban = add({'active': new BanMenuActiveItem, 'name': gls("Забанить"), 'handler': onBan});

			this.backgroundImage = new ProfileContextMenuImage();
			addChild(this.backgroundImage);

			this.levelField = new GameField("99", 0, 4, new TextFormat(null, 11, 0xFFE046, true));
			this.levelField.width = 24;
			this.levelField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.levelField);

			this.onlineIcon = new OnlineIcon();
			this.onlineIcon.x = 131;
			this.onlineIcon.y = 3;
			addChild(this.onlineIcon);

			this.dialogAddFriend = new DialogInfo(gls("Добавление в друзья"), gls("Добавив игрока в друзья, ты\nвсегда сможешь быстро его найти, чтобы\nпоиграть с ним или сходить в гости."), true, addFriend);
			this.dialogRemoveFriend = new DialogInfo(gls("Удаление из друзей"), gls("Ты уверен, что хочешь\nудалить игрока из друзей?"), true, removeFriend);
			this.dialogApplicationClan = new DialogInfo(gls("Попроситься в клан"), gls("Ты уверен, что хочешь\nподать заявку на вступление в клан?"), true, applicationToClan);
			this.dialogInviteClan = new DialogInfo(gls("Пригласить в клан"), gls("Ты уверен, что хочешь\nпригласить игрока в клан?"), true, inviteToClan);
			this.dialogCantInviteClan = new DialogInfo(gls("Пригласить в клан"), gls("Ты не можешь приглашать в клан,\nт.к. твой клан заблокирован."));
			this.dialogKickClan = new DialogInfo(gls("Выгнать из клана"), gls("Ты уверен, что хочешь\nвыгнать игрока из клана?"), true, kickFromClan);
			this.dialogInBlacklist = new DialogInfo(gls("Добавить в черный список клана"), gls("Ты уверен, что хочешь добавить\nигрока в черный список клана?"), true, addInBlacklist);
			this.dialogOutBlacklist = new DialogInfo(gls("Удалить из черного списка клана"), gls("Ты уверен, что хочешь удалить\nигрока из черного списка клана?"), true, removeFromBlacklist);
			this.dialogSubleader = new DialogInfo(gls("Сделать помощником"), gls("Ты точно хочешь сделать игрока твоим помощником?"), true, addSubleader);
			this.dialogSubleaderBorder = new DialogInfo(gls("Сделать помощником"), gls("Ты можешь сделать не более {0} помощников.", ClanManager.MAX_SUBLEADERS_COUNT));
			this.dialogFireSubleader = new DialogInfo(gls("Снять с должности помощника"), gls("Ты точно хочешь снять игрока с должности помощника?"), true, fireSubleader);

			Screens.instance.addEventListener(ScreenEvent.SHOW, onChangeScreen);
		}

		private function checkIgnoreList():void
		{
			if (IgnoreList.isIgnored(this.player.id))
			{
				this.notIgnore.show();
				return;
			}
			this.ignore.show();
		}

		private function onExchange(e:Event):void
		{
			CollectionManager.saveExchange();

			RuntimeLoader.load(function():void
			{
				DialogCollectionExchange.setPlayer(player.id);
			});
		}

		private function onChangeScreen(e:ScreenEvent):void
		{
			this.visible = false;
		}

		private function onGame(e:Event):void
		{
			RuntimeLoader.load(function():void
			{
				ScreenGame.start(player.id, true);
			}, true);
		}

		private function onView(e:Event):void
		{
			ScreensLoader.load(ScreenProfile.instance);
			ScreenProfile.setPlayerId(player.id);
		}

		private function onProfile(e:Event):void
		{
			if (this.player.type == Config.API_SA_ID)
				return;

			var url:String = this.player.profile;

			if (this.player.type == Config.API_FS_ID)
			{
				switch (Game.self.type)
				{
					case Config.API_FB_ID:
						url += "?ref_id=170540607";
						break;
					case Config.API_VK_ID:
						url += "?ref_id=275327198";
						break;
				}
			}

			navigateToURL(new URLRequest(url), "_blank");
		}

		private function onFriend(e:Event):void
		{
			this.dialogAddFriend.show();
		}

		private function onNotFriend(e:Event):void
		{
			this.dialogRemoveFriend.show();
		}

		private function onIgnore(e:Event):void
		{
			IgnoreList.ignore(this.player.id);
		}

		private function onNotIgnore(e:Event):void
		{
			IgnoreList.unignore(this.player.id);
		}

		private function onSpy(e:Event):void
		{
			RuntimeLoader.load(function():void
			{
				ScreenGame.start(player.id, false, true);
			}, true);
		}

		private function onBan(e:Event):void
		{
			RuntimeLoader.load(function():void
			{
				if (!dialogBlock)
					dialogBlock = new DialogBlock();
				(dialogBlock as DialogBlock).playerId = player.id;
				dialogBlock.show();
			});
		}

		private function onApplicationClan(e:Event):void
		{
			if (Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS)
				this.dialogApplicationClan.show();
			else
				new DialogInfo(gls("Подать заявку"), gls("Вы не можете подавать заявки в кланы, если ваш уровень ниже {0}", Game.LEVEL_TO_OPEN_CLANS)).show();
		}

		private function onInviteClan(e:Event):void
		{
			if (ClanManager.getClan(Game.self['clan_id']).state != PacketServer.CLAN_STATE_BANNED)
			{
				if (this.player['level'] >= Game.LEVEL_TO_OPEN_CLANS)
					this.dialogInviteClan.show();
				else
					new DialogInfo(gls("Приглашение в клан"), gls("В клан можно приглашать только белок {0} уровня и выше", Game.LEVEL_TO_OPEN_CLANS)).show();
			}
			else
				this.dialogCantInviteClan.show();
		}

		private function onKickClan(e:Event):void
		{
			this.dialogKickClan.show();
		}

		private function onInBlacklist(e:Event):void
		{
			this.dialogInBlacklist.show();
		}

		private function addInBlacklist():void
		{
			Connection.sendData(PacketClient.CLAN_ADD_IN_BLACKLIST, this.player.id);
		}

		private function onOutBlacklist(e:Event):void
		{
			this.dialogOutBlacklist.show();
		}

		private function removeFromBlacklist():void
		{
			Connection.sendData(PacketClient.CLAN_REMOVE_FROM_BLACKLIST, this.player.id);
		}

		private function addFriend():void
		{
			Game.addFriend(this.player.id);
		}

		private function removeFriend():void
		{
			Game.removeFriend(this.player.id);
		}

		private function inviteToClan():void
		{
			Connection.sendData(PacketClient.CLAN_INVITE, this.player.id);
		}

		private function kickFromClan():void
		{
			Connection.sendData(PacketClient.CLAN_KICK, this.player.id);
		}

		private function applicationToClan():void
		{
			if (Game.self['clan_id'] != 0)
				return;

			Game.clanApplication = this.player['clan_id'];
			Connection.sendData(PacketClient.CLAN_JOIN, this.player['clan_id']);
		}

		private function onClanSubleader(e:Event):void
		{
			if (ClanManager.subLeaderIds.length >= ClanManager.MAX_SUBLEADERS_COUNT)
			{
				this.dialogSubleaderBorder.show();
				return;
			}

			this.dialogSubleader.show();
		}

		private function addSubleader():void
		{
			if (this.player['clan_id'] == 0 || (this.player['clan_id'] != Game.self['clan_id']))
				return;

			Connection.sendData(PacketClient.CLAN_SUBSTITUTE, this.player.id);
		}

		private function onNotClanSubleader(e:Event):void
		{
			this.dialogFireSubleader.show();
		}

		private function fireSubleader():void
		{
			if (this.player['clan_id'] == 0 || (this.player['clan_id'] != Game.self['clan_id']) || this.player['clan_duty'] != Clan.DUTY_SUBLEADER)
				return;

			Connection.sendData(PacketClient.CLAN_UNSUBSTITUTE, this.player.id);
		}
	}
}