package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import chat.Chat;
	import chat.ChatCommon;
	import clans.Clan;
	import clans.ClanManager;
	import dialogs.DialogCelebrate;
	import dialogs.DialogDebug;
	import dialogs.DialogDepletionEnergy;
	import dialogs.DialogInfo;
	import dialogs.DialogInviteAward;
	import dialogs.DialogInviteTimeout;
	import dialogs.DialogLocation;
	import dialogs.DialogPaymentResult;
	import dialogs.DialogRebuyVIP;
	import dialogs.DialogReturnedAward;
	import dialogs.DialogSearchPlayer;
	import dialogs.DialogSendError;
	import dialogs.DialogShopNotify;
	import dialogs.DialogSkinBuy;
	import dialogs.hotWheels.DialogHotWheelsBonus;
	import events.ClanEvent;
	import events.GameEvent;
	import footers.FooterGame;
	import footers.FooterTop;
	import footers.Footers;
	import game.gameData.CollectionManager;
	import game.gameData.EducationQuestManager;
	import game.gameData.FlagsManager;
	import game.gameData.GameConfig;
	import game.gameData.NotificationManager;
	import game.gameData.ProduceManager;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import headers.HeaderExtended;
	import headers.Headers;
	import loaders.DiscountsLoader;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import menu.MenuProfile;
	import screens.ScreenAward;
	import screens.ScreenBlocked;
	import screens.ScreenClan;
	import screens.ScreenCollection;
	import screens.ScreenDisconnected;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.ScreenLocation;
	import screens.ScreenProfile;
	import screens.ScreenRating;
	import screens.ScreenSchool;
	import screens.ScreenShamanTree;
	import screens.ScreenStarling;
	import screens.ScreenWardrobe;
	import screens.Screens;
	import sounds.GameMusic;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import tape.TapeShamanCastShop;
	import views.FriendGiftBonusView;
	import views.LoadGameAnimation;
	import views.Settings;
	import views.SnowView;
	import views.TvView;
	import views.issuance.BonusAnimation;

	import by.blooddy.crypto.serialization.JSON;

	import com.api.ApiEvent;
	import com.api.LoggerEvent;
	import com.api.LoginEvent;
	import com.api.OfferAvalibleEvent;
	import com.api.Player;
	import com.api.PlayerEvent;
	import com.api.Players;
	import com.api.PlayersEvent;
	import com.api.ReferalEvent;
	import com.api.RefillEvent;
	import com.api.Services;
	import com.demonsters.debugger.MonsterDebugger;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketAdminMessage;
	import protocol.packages.server.PacketBalance;
	import protocol.packages.server.PacketBan;
	import protocol.packages.server.PacketBirthday;
	import protocol.packages.server.PacketBonuses;
	import protocol.packages.server.PacketBuy;
	import protocol.packages.server.PacketFeathers;
	import protocol.packages.server.PacketFriends;
	import protocol.packages.server.PacketGuard;
	import protocol.packages.server.PacketInfo;
	import protocol.packages.server.PacketInfoNet;
	import protocol.packages.server.PacketLogin;
	import protocol.packages.server.PacketOffers;
	import protocol.packages.server.PacketPlayWith;
	import protocol.packages.server.PacketShamanExperience;
	import protocol.packages.server.PacketTransfer;

	import starling.core.Starling;

	import utils.ArrayUtil;
	import utils.CountryUtil;
	import utils.GuardUtil;
	import utils.PersonalOfferUtil;
	import utils.starling.extensions.virtualAtlas.AssetManager;

	public class Game extends MovieClip
	{
		static private const STATUS_LOGGED:int = 1;
		static private const STATUS_LOADED:int = 2;
		static private const STATUS_ADVERTISING:int = 4;
		static private const STATUS_DONE:int = 7;

		static public const ROUND_DEFAULT_TIME:int = 600;
		static public const ROUND_MIN_TIME:int = 20;
		static public const R2D:Number = 180 / Math.PI;
		static public const D2R:Number = Math.PI / 180;

		static public const ROOM_HEIGHT:int = 531;

		static public const PIXELS_TO_METRE:int = 10;

		static public const LEVEL_TO_OPEN_STORAGE:int = 4;
		static public const LEVEL_TO_OPEN_ADVERTISING:int = 4;
		static public const LEVEL_TO_OPEN_DRAGON:int = 4;
		static public const LEVEL_TO_LEAVE_SANDBOX:int = 4;
		static public const LEVEL_TO_NEWBIE_BUNDLE:int = 6;
		static public const LEVEL_TO_NEWBIE_BUNDLE_END:int = 12;
		static public const LEVEL_TO_FREE_RESPAWN:int = 5;
		static public const LEVEL_REQUEST_LEFT_MENU:int = 5;
		static public const LEVEL_TO_OPEN_CLANS:int = 7;
		static public const LEVEL_TO_INVITE:int = 7;
		static public const LEVEL_TO_OPEN_SHAMAN:int = 7;
		static public const LEVEL_TO_SHOW_TV:int = 10;
		static public const LEVEL_TO_PAY_FOR_NICK:int = 10;
		static public const LEVEL_TO_FRIEND_INVITE:int = 16;
		static public const LEVEL_TO_SHOW_CHAT_ALL:int = 20;

		static public const CLAN_CREATE_COST:int = 50;

		static public const COLLECTION_EXCHANGE_COST:int = 100;
		static public const SHAMAN_ACORNS_COST:int = 300;
		static public const SHAMAN_COINS_COST:int = 1;
		static public const HARE_ACORNS_COST:int = 500;
		static public const HARE_COINS_COST:int = 1;
		static public const DRAGON_ACORNS_COST:int = 100;
		static public const DRAGON_COINS_COST:int = 1;

		static public const COINS_FOR_INVITE:int = 15;

		static public const NICKNAME_CHANGE_COST:int = 50;

		static private var _instance:Game;

		static public var clanApplication:int = 0;

		static public var self:Player = null;
		static public var gameSprite:Sprite = null;
		static public var spriteHits:Sprite = new Sprite();

		static public var unix_time:int = 0;
		static public var editor_access:int = 0;
		static public var friendsCount:int = 0;
		static public var friendsSocialCount:int = -1;
		static public var quickPhoto:Boolean = false;
		static public var registerTime:int = 0;
		static public var logoutTime:int = 0;
		static public var paymentTime:int = 0;
		static public var friendsIds:Array = [];
		static public var allFriendsIds:Array = [];
		static public var friendsSocialIds:Array = [];
		static public var selfCastItems:Vector.<int> = null;
		static public var newsRepost:Vector.<int>;
		static public var inviter_id:int = 0;

		static public var showLagWarning:Boolean = true;
		static public var showedExchangeHint:Boolean = true;
		static public var canOffer:Boolean = false;
		static public var canAdvertising:Boolean = false;
		static public var offerUrl:String;
		static public var like:Boolean = false;
		static public var isMemberGroup:Boolean = false;
		static public var gagTime:int = 0;
		static public var clanInvites:Boolean = true;
		static public var freeChangeNick:Boolean = false;
		static public var openAppUrl:Boolean = false;
		static public var transferComplete:Boolean = false;

		static public var starling: Starling = null;
		static public var notBecomeShaman:Boolean = true;

		private var _analytics:Analytics = null;

		private var friends:Object = {};
		private var deleteFriends:Object = {};

		private var status:int = 0;
		private var loginTimer:Timer = new Timer(1000, 1);

		private var advertisingInited:Boolean = false;
		private var isFirstInfo:Boolean = true;

		private var chatInstance:Chat = null;

		private var friendNotGame:DialogInfo = null;
		private var friendNotGameDefault:DialogInfo = null;
		private var notExist:DialogInfo = null;
		private var fullRoomGame:DialogInfo = null;
		private var notInClan:DialogInfo = null;
		private var unavaiableLocation:DialogInfo = null;

		private var dialogPaymentResult:DialogPaymentResult = null;

		private var quiz:String;
		private var loginEvent:LoginEvent = null;
		private var initStageDone:Boolean = false;
		private var initScreensDone:Boolean = false;
		private var initAwardsDone:Boolean = false;

		public function Game():void
		{
			_instance = this;

			super();

			if (this.stage != null)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);

			CONFIG::debug
			{
				MonsterDebugger.initialize(this);
			}
		}

		static public function transfer():void
		{
			if (Game.openAppUrl)
				navigateToURL(new URLRequest("https://apps.facebook.com/squirrelsgame"), "_blank");

			Services.requestCrossId(_instance.onGetCrossId);
		}

		static public function get chat():Chat
		{
			return _instance.chatInstance;
		}

		static public function get guardValue():String
		{
			return _instance.quiz;
		}

		static public function get balanceNuts():int
		{
			return Game.self.nuts;
		}

		static public function get balanceCoins():int
		{
			return Game.self.coins;
		}

		static public function get analytics():Analytics
		{
			if (!_instance)
				return null;
			return _instance._analytics;
		}

		static public function get isGameOffer():Boolean
		{
			return (Game.self.type == Config.API_VK_ID || Game.self.type == Config.API_FS_ID ||
				Game.self.type == Config.API_SA_ID);
		}

		static public function inviteFriendsByKey(e:Event = null):void
		{
			if (Game.self.type != Config.API_FS_ID)
			{
				Game.inviteFriends();
				return;
			}

			Services.inviteFriendsByKey();
		}

		static public function inviteFriends(e:Event = null):void
		{
			FullScreenManager.instance().fullScreen = false;
			Services.inviteFriends();

			Connection.sendData(PacketClient.COUNT, PacketClient.INVITE_FRIENDS);
		}

		static public function sendAchievement(url:String):void
		{
			Services.sendAchievement(url);
		}

		static public function get site():Boolean
		{
			return Game.self != null && (Game.self.type == Config.API_SA_ID || Services.isOAuth);
		}

		static public function addOffersToQuest(offers:Array):void
		{
			ScreenLocation.addOffers(offers);
		}

		static public function addOffersVKToQuest(offers:Array):void
		{
			ScreenLocation.addOffersVK(offers);
		}

		static public function buy(goodId:int, coinsCost:uint, acornsCost:uint, targetId:int = 0, data:int = 0):void
		{
			_instance.buy(goodId, coinsCost, acornsCost, targetId, data);
		}

		static public function buyWithoutPay(gooId:int, coinsCost:uint, acornsCost:uint, targetId:int = 0, data:int = 0):Boolean
		{
			return _instance.buyWithoutPay(gooId, coinsCost, acornsCost, targetId, data);
		}

		static public function event(type:String, listener:Function, priority:int = 0):void
		{
			_instance.addEventListener(type, listener, false, priority);
		}

		static public function removeEvent(type:String, listener:Function):void
		{
			_instance.removeEventListener(type, listener);
		}

		static public function isFriend(playerId:int):Boolean
		{
			return (playerId in _instance.friends);
		}

		static public function isDeleteFriend(playerId:int):Boolean
		{
			return (playerId in _instance.deleteFriends);
		}

		static public function get friends():Object
		{
			return _instance.friends;
		}

		static public function addFriend(playerId:int):void
		{
			_instance.addFriend([playerId]);
		}

		static public function removeFriend(playerId:int):void
		{
			_instance.removeFriend(playerId);
		}

		static public function listen(listener:Function):void
		{
			Services.players.listen(listener);
		}

		static public function forget(listener:Function):void
		{
			Services.players.forget(listener);
		}

		static public function request(ids:*, type:*, nocache:Boolean = false):void
		{
			if (ids is Vector)
				ids = ArrayUtil.parseIntVector(ids);

			if (ids is Array && ids.length == 0)
				return;

			if (!(type is Array))
				type = [type, 0];

			if (type.length == 1)
				type.push(0);

			Logger.add("[Request user info] ids:" + ((ids is Array) ? "[" + ids.join() + "]" : ids) + " type:" + type + " nocache:" + nocache);
			Services.players.requestInfo(ids, type, !nocache);
		}

		static public function getPlayer(id:int):Player
		{
			return Services.players.getPlayer(id);
		}

		static public function parsePlayersData(data:ByteArray, mask:uint, skipEmpty:Boolean = false):Array
		{
			return _instance.parsePlayersData(data, mask, skipEmpty);
		}

		static public function get stage():Stage
		{
			return _instance.stage;
		}

		static public function get selfId():int
		{
			return Game.self.id;
		}

		static public function saveSelf(data:Object):void
		{
			_instance.saveSelf(data);
		}

		static public function onRuntimeLoaded():void
		{
			AssetManager.instance.parseAtlas(new AtlasGameObjects);
			_instance.onRuntimeLoaded();
		}

		static public function setBalance(nuts:int, coins:int, reason:int = 0):void
		{
			if (Game.self.nuts == nuts && Game.self.coins == coins)
				return;

			if (reason == PacketServer.REASON_REFILLING)
			{

				GameSounds.play("buy", true);

				if (_instance.dialogPaymentResult == null)
					_instance.dialogPaymentResult = new DialogPaymentResult();

				_instance.dialogPaymentResult.setBalance(coins - Game.self.coins);
			}

			if (reason == PacketServer.REASON_FRIEND_GIFT)
				FriendGiftBonusView.coins = coins - Game.self.coins;

			if (reason == PacketServer.REASON_INVITER_REWARDING)
				DialogInviteAward.show();

			if (reason == PacketServer.REASON_RETURNER_REWARDING)
				new DialogReturnedAward(nuts - Game.self.nuts).show();

			if (reason != PacketServer.REASON_NURSE_AWARDING && reason != PacketServer.REASON_SHAMAN_KILLING && reason != PacketServer.REASON_SHAMAN_RESCUING && reason != PacketServer.REASON_WINNING)
				Game.self.nutsOld = nuts;

			Game.self.nuts = nuts;
			Game.self.coins = coins - FriendGiftBonusView.coins;

			_instance.dispatchEvent(new GameEvent(GameEvent.BALANCE_CHANGED));
		}

		static public function setFeathers(value:int, reason:int = 0):void
		{
			if (reason){/*unused*/}

			Game.self.feathers = value;

			_instance.dispatchEvent(new GameEvent(GameEvent.FEATHERS_CHANGED));
		}

		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			PreLoader.setStatus(gls("Выполняется инициализация приложения"));

			this.loginTimer.addEventListener(TimerEvent.TIMER, Services.login);

			var connection:Connection = new Connection();
			connection.addEventListener(Event.CONNECT, onConnect);
			connection.addEventListener(Connection.CONNECTION_ERROR, onError);
			connection.addEventListener(Connection.CONNECTION_CLOSED, onError);

			Logger.add("sounds.GameSounds ctor");

			new GameSounds;
			new GameMusic;

			Services.init(new ConfigApi(PreLoader.loaderInfo.parameters, PreLoader.loaderInfo));
			Services.config.log = onLogService;
			Services.addEventListener(ApiEvent.LOADED, onApiLoaded);
			Services.addEventListener(LoginEvent.LOGIN, onLogin);
			Services.addEventListener(LoggerEvent.LOGGER, onLogger);
			Services.addEventListener(RefillEvent.REFILL, onRefill);
			Services.addEventListener(ReferalEvent.REFERAL, onReferal);
			Services.addEventListener(OfferAvalibleEvent.NAME, onOfferAvalible);
			(Services.players as Players).addEventListener(PlayersEvent.REQUEST, onRequestPlayer);
//			(Services.players as Players).addEventListener(PlayersEvent.SAVE_SELF_PHOTO, onSaveSelf);
//			(Services.players as Players).addEventListener(PlayersEvent.SAVE_SELF_INFO, onSaveSelf);

			var text:String = "";
			for (var key:String in PreLoader.loaderInfo.parameters)
				text += "&" + key + "=" + PreLoader.loaderInfo.parameters[key];

			Logger.add(text);
			
			Analytics.gameLoaded();

			WordFilter.init();
			Services.load();
			new ViralityQuestManager;
			NotificationManager.instance;

			Connection.listen(onPacket, [PacketGuard.PACKET_ID, PacketLogin.PACKET_ID, PacketInfo.PACKET_ID,
				PacketInfoNet.PACKET_ID, PacketBan.PACKET_ID, PacketBalance.PACKET_ID, PacketBonuses.PACKET_ID,
				PacketFeathers.PACKET_ID, PacketShamanExperience.PACKET_ID, PacketFriends.PACKET_ID,
				PacketBuy.PACKET_ID, PacketAdminMessage.PACKET_ID, PacketPlayWith.PACKET_ID,
				PacketBirthday.PACKET_ID, PacketOffers.PACKET_ID]);

			Services.players.requestDelay = 1000;
			PlayerInfoParser.replaceName = Services.config.noName;
			Game.stage.addEventListener(MouseEvent.CLICK, onClick);

//			PreLoader.showDebug(true);
		}

		private function onLogService(...param):void
		{
			Logger.add("SERVICE LOG:", param);
		}

		private function onClick(event: MouseEvent): void
		{
			var target: * = event.target;

			if (event.target is TextField)
			{
				if ((target as TextField).selectable && Game.stage.focus != target)
				{
					Game.stage.focus = target;
					//TODO set caret to end symbol
					/*(target as TextField).setSelection(
						(target as TextField).length,
						(target as TextField).length
					);*/
				}
			}
		}

		private function initScreens():void
		{
			if (this.initScreensDone)
				return;
			this.initScreensDone = true;

			Logger.add("initScreens");

			addChild(new Screens);

			new DialogDebug;
			new DialogSearchPlayer;
			new DialogSendError;

			Logger.add("initScreens DONE");
		}

		private function initStage():void
		{
			if (this.initStageDone)
				return;
			this.initStageDone = true;

			Logger.add("initStage");

			initScreens();

			GameSounds.preload(SoundConstants.LOCATIONS_HOVER_SOUNDS.concat(
				[SoundConstants.CLICK, SoundConstants.BUTTON_CLICK]));

			GameSounds.preload(SoundConstants.LOCATIONS_HOVER_SOUNDS.concat(
				[SoundConstants.CLICK, SoundConstants.BUTTON_CLICK]));

			Screens.register("Learning", new ScreenLearning);
			Screens.register("Location", new ScreenLocation);
			Screens.register("Profile", new ScreenProfile);
			Screens.register("Wardrobe", new ScreenWardrobe);
			Screens.register("Collection", new ScreenCollection);
			Screens.register("Clan", new ScreenClan);
			Screens.register("Rating", new ScreenRating);
			Screens.register("Edit", new ScreenEdit);
			Screens.register("Game", new ScreenGame);
			Screens.register("School", new ScreenSchool);
			Screens.register("Award", new ScreenAward);
			Screens.register("ShamanTree", new ScreenShamanTree);

			ClanManager.listen(onClanLoaded);

			new MenuProfile;
			new NotifyQueue;
			FullScreenManager.instance();
			CollectionManager.init();
			MailManager.init();
			new InteriorManager;

			GameMusic.addListener();

			ScreenStarling.upLayer.addChild(new SnowView().getStarlingView());

			initDialogs();

			addChild(new Footers);
			addChild(new Headers);

			addChild(spriteHits);

			LoadGameAnimation.instance.close(false, 97);

			new AntiSpeedHack;
			new FPSCounter;

			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);

			Logger.add("initStage DONE");
		}

		private function onChangeScreenSize(e: Event): void
		{}

		private function initDialogs():void
		{
			new DialogLocation();

			this.friendNotGame = new DialogInfo(gls("Перейти в игру"), gls("Сейчас ты не можешь перейти в игру к другу, так как он находится не в игре"), false, null, 350);
			this.friendNotGameDefault = new DialogInfo(gls("Перейти в игру"), gls("Сейчас ты не можешь перейти в игру к другу: либо он не в игре, либо в его команде нет свободных мест."), false, null, 350);
			this.notExist = new DialogInfo(gls("Перейти в игру"), gls("Сейчас ты не можешь перейти в игру к другу, так как его нет в игровой локации"), false, null, 350);
			this.fullRoomGame = new DialogInfo(gls("Перейти в игру"), gls("Сейчас ты не можешь перейти в игру к другу, так как в его команде нет свободных мест."), false, null, 350);
			this.notInClan = new DialogInfo(gls("Перейти в игру"), gls("Ты не можешь перейти в игру к другу, так как не состоишь в его клане"), false, null, 350);
			this.unavaiableLocation = new DialogInfo(gls("Перейти в игру"), gls("Сейчас ты не можешь перейти в игру к другу, так как эта локация тебе еще не доступна."), false, null, 350);
		}

		private function onRuntimeLoaded():void
		{
			EntityFactory.init();

			this.chatInstance = new Chat();
			this.addChild(chatInstance);
			this.chatInstance.setGag();

			PerkShamanFactory.init();
			FooterGame.initGame();

			this.initAwardsDone = true;
		}

		private function onConnect(e:Event):void
		{
			Logger.add("Game.onConnect");

			FlagsManager.onLoad(onLoadFlags);
			FlagsManager.init();

			Services.login();
		}

		private function onLoadFlags():void
		{
			GameMusic.on = !FlagsManager.has(Flag.MUSIC);
			GameSounds.on = !FlagsManager.has(Flag.SOUND);

			Game.showLagWarning = !FlagsManager.has(Flag.HIDE_LOW_FPS);

			Game.showedExchangeHint = FlagsManager.has(Flag.HIDE_EXCHANGE);

			Game.like = false;
			Game.isMemberGroup = false;
			Game.notBecomeShaman = FlagsManager.has(Flag.NOT_BE_SHAMAN);
			Game.clanInvites = !FlagsManager.has(Flag.HIDE_CLAN_INVITES);
			Game.freeChangeNick = !FlagsManager.has(Flag.NICKNAME_CHANGED);

			Game.transferComplete = true;

			ScreenLocation.sortMenu();
		}

		private function onError(e:Event):void
		{
			Logger.add("error", e);

			setStatus(~STATUS_LOGGED);

			PreLoader.hide();

			initScreens();

			Screens.toggleChildren(false);

			Screens.register("Disconnected", new ScreenDisconnected);
			Screens.show("Disconnected");
		}

		private function buy(goodId:uint, coinsCost:uint, acornsCost:uint, targetId:int, data:int):void
		{
			if (!pay(coinsCost, acornsCost))
				return;

			GameSounds.play("buy", true);

			Connection.sendData(PacketClient.BUY, goodId, coinsCost, acornsCost, targetId, data);
		}

		private function buyWithoutPay(goodId:uint, coinsCost:uint, acornsCost:uint, targetId:int, data:int):Boolean
		{
			if (Game.balanceCoins < coinsCost || Game.balanceNuts < acornsCost)
			{
				RuntimeLoader.load(function():void
				{
					Services.bank.open();
				});
				return false;
			}

			Connection.sendData(PacketClient.BUY, goodId, coinsCost, acornsCost, targetId, data);
			return true;
		}

		private function pay(coinsCost:uint, acornsCost:uint):Boolean
		{
			if (Game.balanceCoins < coinsCost || Game.balanceNuts < acornsCost)
			{
				RuntimeLoader.load(function():void
				{
					Services.bank.open();
				});
				return false;
			}

			Game.setBalance(Game.self.nuts - acornsCost, Game.self.coins - coinsCost, PacketServer.REASON_SPENT);
			return true;
		}

		private function onClanLoaded(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if ((Game.self['clan_id'] == 0) || ((Game.self['clan_id'] != 0) && (clan.id != Game.self['clan_id'])))
				return;

			if (Game.self.id == clan.leaderId)
				Game.self['clan_duty'] = Clan.DUTY_LEADER;

			setStatus(STATUS_LOADED);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player.id != Game.selfId)
				return;

			HeaderExtended.update();

			checkAdvertising();

			if (player['clan_id'] != 0)
				return;

			setStatus(STATUS_LOADED);
		}

		private function checkAdvertising():void
		{
			if (this.advertisingInited)
				return;

			this.advertisingInited = true;

			PersonalOfferUtil.getPersonalOffers();

			if ((Game.self.type != Config.API_VK_ID) || !Game.canAdvertising)
			{
				setStatus(STATUS_ADVERTISING);
				return;
			}

			if (Experience.selfLevel < Game.LEVEL_TO_OPEN_ADVERTISING)
			{
				setStatus(STATUS_ADVERTISING);
				return;
			}

			try
			{
				ExternalInterface.call("addAppscentrum");
				setStatus(STATUS_ADVERTISING);
			}
			catch (e:Error)
			{
				setStatus(STATUS_ADVERTISING);
				trace(e.getStackTrace());
			}
		}

		private function onAppFriendsLoaded(ids:Array):void
		{
			Game.friendsSocialIds = ids;
			Game.friendsSocialCount = ids.length;

			if (Game.friendsSocialCount > 0)
			{
				Connection.sendData(PacketClient.REQUEST_NET, Game.friendsSocialIds, Game.self.type, PlayerInfoParser.NET_ID | PlayerInfoParser.PHOTO | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.ONLINE);
				Connection.sendData(PacketClient.SOCIAL_FRIENDS, Game.friendsSocialIds);
			}
			else
				Connection.sendData(PacketClient.SOCIAL_FRIENDS, []);
		}

		private function onAllFriendsLoaded(ids:Array):void
		{
			Logger.add("Game.onAllFriendLoaded", ids);
			Game.allFriendsIds = ids;

			DialogInviteTimeout.init();
		}

		private function setStatus(status:int):void
		{
			var oldStatus:int = this.status;
			this.status |= status;

			Logger.add("setStatus", this.status);

			if (oldStatus == STATUS_DONE || this.status != STATUS_DONE)
				return;

			Services.initBank();
			Services.setCounter(0);

			setReferrer();

			Services.friends.get(onAllFriendsLoaded);
			Services.friends.getAppUsers(onAppFriendsLoaded);

			startGame();
		}

		private function startGame():void
		{
			new Locations;

			Screens.toggleChildren(true);
			ScreenLocation.setLevel(Experience.selfLevel);

			//if (Game.self.type == Config.API_VK_ID)
			//	BrightStatUtil.init();

			PreLoader.hide();

			if (EducationQuestManager.firstGame)
			{
				Screens.show("Learning");
				Screens.setStatus(Screens.TV);
			}
			else
			{
				Screens.show("Location");
				setTimeout(LoadGameAnimation.instance.open, 2000, !EducationQuestManager.educationQuest ? TvView.show : function():void
				{
					Screens.setStatus(Screens.TV);
				});
			}

			ViralityQuestManager.requestApiData();

			Connection.sendData(PacketClient.BIRTHDAY_CELEBRATE);

			Services.players.requestDelay = 0;
		}

		private function setReferrer():void
		{
			Logger.add("setReferrer for id " + Game.self.id + " and referrer " + Referrers.get());

			if (Referrers.isFromWall())
				Connection.sendData(PacketClient.COUNT, PacketClient.REPOST_FOLLOW, Game.self['type']);
		}

		private function save(player:Player):void
		{
			var serverName:String = player.name == Services.config.noName ? "" : player.name;
			Logger.add("SAVED player.name, player.sex, player.bdate, player.photoBig, player.profile, player.email, player.country", player.name, player.sex, player.bdate, player.photoBig, player.profile, player.email, player.country);

			if ("country" in player)
				Connection.sendData(PacketClient.INFO, serverName, player.sex, player.bdate, player.photoBig, player.profile, player.email, CountryUtil.convertId(player.country, Game.self.type));
			else
				Connection.sendData(PacketClient.INFO, serverName, player.sex, player.bdate, player.photoBig, player.profile, player.email);
		}

		private function saveSelf(data:Object):void
		{
			Game.self.name = data['name'];
			Game.self.sex = data['sex'];

			if ('email' in data)
				Game.self.email = data['email'];

			save(Game.self);
		}

		private function addFriend(playersId:Array):void
		{
			var ids:Array = [];
			for (var i:int = 0; i < playersId.length; i++)
			{
				if (isFriend(playersId[i]))
					continue;

				Logger.add("Game.addFriend " + playersId[i]);

				this.friends[playersId[i]] = true;
				Game.friendsCount++;

				ids.push(playersId[i]);
			}

			dispatchEvent(new GameEvent(GameEvent.ADD_FRIEND, {'value': ids}));

			Connection.sendData(PacketClient.FRIENDS_ADD, playersId);
		}

		private function removeFriend(playerId:int):void
		{
			if (!isFriend(playerId))
				return;

			Logger.add("Game.removeFriend " + playerId);

			delete this.friends[playerId];

			Game.friendsCount--;

			dispatchEvent(new GameEvent(GameEvent.REMOVE_FRIEND, {'value': [playerId]}));

			Connection.sendData(PacketClient.FRIENDS_REMOVE, playerId);
		}

		private function addContextUid():void
		{
			CONFIG::mobile{return;}

			Game.gameSprite.contextMenu.customItems.push(new ContextMenuItem("ID: " + Game.selfId, true, false));
		}

		private function parsePlayersData(data:ByteArray, mask:uint, skipEmpty:Boolean = false):Array
		{
			var players:Array = PlayerInfoParser.parse(data, mask);

			var ids:Array = [];

			for each (var dataP:Object in players)
			{
				if (("photo_big" in dataP && dataP['photo_big'] != "") || !skipEmpty)
					ids.push(dataP['uid']);

				if (dataP['uid'] == Game.selfId)
				{
					if ("exp" in dataP && !this.isFirstInfo && Experience.checkNew(Experience.selfExp, dataP['exp']))
						Experience.newLevel(dataP['exp']);

					if ("vip_info" in dataP && dataP["vip_buy"] != 0 && dataP["vip_time"] == 0 && this.isFirstInfo)
						Screens.addCallback(DialogRebuyVIP.show);

					if ("shaman_exp" in dataP && !this.isFirstInfo && ShamanExperience.checkNew(Game.self['shaman_exp'], dataP['shaman_exp']))
						ShamanExperience.newLevel(dataP['shaman_exp']);

					if ("clan_totem" in dataP)
						dataP['last_update'] = getTimer() / 1000;
				}

				Services.players.dataLoaded(dataP, mask);

				if (this.isFirstInfo)
				{
					if (Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS)
						Settings.addClanInvitesButton();

					this.isFirstInfo = false;
				}
			}
			return ids;
		}

		private function onPacket(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketGuard.PACKET_ID:
					var data:ByteArray = (packet as PacketGuard).data;
					var beforeLogin:Boolean = (Game.self == null);

					if (data.length != 0)
					{
						data.position = 0;
						data.uncompress();
						data.position = 0;
						GuardUtil.dataString = data.readUTFBytes(data.length);
						this.quiz = GuardUtil.calculateQuiz();
					}
					else
					{
						CONFIG::debug{trace("Guard off");}
						this.quiz = "";
					}

					Connection.sendData(PacketClient.GUARD, this.quiz);

					if (beforeLogin)
						Login();
					break;
				case PacketLogin.PACKET_ID:
				{
					var loginPacket:PacketLogin = PacketLogin(packet);
					var status:int = loginPacket.status;//[PacketServer.LOGIN_STATUS];

					switch (loginPacket.status)
					{
						case PacketServer.LOGIN_SUCCESS:
							PreLoader.setContextMenu(Game.gameSprite);
							PreLoader.setStatus(gls("Выполняется загрузка данных профиля"));

							GuardUtil.setSelfId(loginPacket.innerId);

							Game.self = Services.players.getPlayer(loginPacket.innerId);
							Game.self.type = Services.netType();
							Game.self.email = loginPacket.email;
							Game.self.shaman_tree = loginPacket.shamanInfo;
							Game.listen(onPlayerLoaded);

							new ScreensLoader;
							new RuntimeLoader;
							new DiscountsLoader;

							GameConfig.load();

							unix_time = loginPacket.unixTime;
							TagManager.tag = loginPacket.tag;

							if (Game.self.type == Config.API_SA_ID || Services.isOAuth)
								new XsollaPayment;

							addContextUid();

							Game.clanApplication = loginPacket.clanApplication;

							Game.selfCastItems = loginPacket.items;
							Game.editor_access = loginPacket.editor;

							Game.registerTime = loginPacket.registerTime;

							Game.logoutTime = loginPacket.logoutTime;
							Game.paymentTime = loginPacket.paymentTime;

							Game.canOffer = (loginPacket.canOffer == 1);
							Game.canAdvertising = (loginPacket.advertising == 1);

							Game.newsRepost = loginPacket.newsRepost;

							GuardUtil.circularKey = loginPacket.key;

							setStatus(STATUS_LOGGED);
							initStage();

							Services.requestLiked();
							Services.requestGroup();

							dispatchEvent(new GameEvent(GameEvent.BALANCE_CHANGED));

							DiscountManager.init(loginPacket.discounts);
							ProduceManager.init();

							if (Game.paymentTime != 0)
							{
								//SupportManager.init();
								this._analytics = new Analytics(Game.selfId);
							}

							Connection.sendData(PacketClient.DAILY_QUEST_REQUEST);
							Connection.sendData(PacketClient.REQUEST_AWARD);

							inviter_id = loginPacket.inviterId;
							if (inviter_id == 0)
								Services.referal();

							Latency.latency();

							try
							{
								ExternalInterface.call("eval", "function ShowWidget(){new SPONSORPAY.Widget.Layover({appid: '3029', uid:'" + Game.selfId + "'}).start();}");
							}
							catch (e:Error)
							{}
							break;
						case PacketServer.LOGIN_EXIST:
							PreLoader.setStatus(gls("Ожидание завершения предыдущего подключения"));

							this.loginTimer.reset();
							this.loginTimer.start();
							break;
						case PacketServer.LOGIN_FAILED:
							PreLoader.setStatus(gls("Не удалось войти в игру"));
							initScreens();
							new DialogInfo(gls("Информация"), gls("Не удалось войти в игру")).show();
							break;
						case PacketServer.LOGIN_BLOCKED:
							PreLoader.hide();
							Game.self = Services.players.getPlayer(loginPacket.innerId);
							initScreens();
							Screens.register("Block", new ScreenBlocked);
							break;
						case PacketServer.LOGIN_WRONG_VERSION:
							PreLoader.setStatus(gls("Вы используете старую версию клиента.\nОчистите кэш браузера и обновите страницу(CTRL+R)"));
							initScreens();
							new DialogInfo(gls("Вы используете старую версию клиента"), gls("Очистите кэш браузера и обновите страницу(CTRL+R)")).show();
							break;
					}

					if (this._analytics == null)
						this._analytics = new Analytics();

					Analytics.playerLogin(status);
					break;
				}
				case PacketInfo.PACKET_ID:
				{
					var info: PacketInfo = packet as PacketInfo;
					parsePlayersData(info.data, info.mask);
					break;
				}
				case PacketInfoNet.PACKET_ID:
				{
					var infoNet: PacketInfoNet = packet as PacketInfoNet;
					var socialFriends:Array = Game.parsePlayersData(infoNet.data, infoNet.mask, true);
					Game.friendsIds = Game.friendsIds.concat(socialFriends);

					var friends:Array = [];
					for (var j:int = 0; j < socialFriends.length; j++)
					{
						if (isFriend(socialFriends[j]) || isDeleteFriend(socialFriends[j]))
							continue;
						friends.push(socialFriends[j]);
					}

					if (friends.length > 0)
						addFriend(friends);
					Connection.sendData(PacketClient.FRIENDS_ONLINE);
					break;
				}
				case PacketBan.PACKET_ID:
				{
					var ban: PacketBan = packet as PacketBan;

					if ((ban.type == PacketClient.BAN_TYPE_GAG) && (ban.targetId == Game.selfId))
					{
						Game.gagTime = getTimer() / 1000 + ban.duration;
						if (this.chatInstance)
							this.chatInstance.setGag();
						ChatCommon.setGag();
					}

					if (ban.reason != PacketClient.BAN_REASON_PROFILE_SWEARING)
						return;

					var player:Player = getPlayer(ban.targetId);
					player.name = "Player " + ban.targetId;
					player.resetPhoto();
					Game.request(ban.targetId, PlayerInfoParser.ALL, true);
					break;
				}
				case PacketBalance.PACKET_ID:
				{
					var balance: PacketBalance = packet as PacketBalance;
					Game.setBalance(balance.nuts, balance.coins, balance.reason);
					break;
				}
				case PacketFeathers.PACKET_ID:
				{
					var feathers: PacketFeathers = packet as PacketFeathers;
					Game.setFeathers(feathers.feathers, feathers.reason);
					break;
				}
				case PacketShamanExperience.PACKET_ID:
				{
					var experience: PacketShamanExperience = packet as PacketShamanExperience;
					if (ShamanExperience.checkNew(Game.self['shaman_exp'], experience.shamanExp))
						ShamanExperience.newLevel(experience.shamanExp);
					Game.self['shaman_exp']= experience.shamanExp;
					ScreenShamanTree.updateExperience();
					break;
				}
				case PacketFriends.PACKET_ID:
				{
					var packetFriends: PacketFriends = packet as PacketFriends;

					for (var i:int = 0, len: int = packetFriends.items.length; i < len; i++)
					{
						if (packetFriends.items[i].removed == 1)
						{
							this.deleteFriends[packetFriends.items[i].friend] = true;
							continue;
						}

						this.friends[packetFriends.items[i].friend] = true;
						Game.friendsIds.push(packetFriends.items[i].friend);
						Game.friendsCount++;
					}
					break;
				}
				case PacketBuy.PACKET_ID:
				{
					var buy:PacketBuy = packet as PacketBuy;

					if (buy.targetId != Game.selfId)
						break;

					switch (buy.status)
					{
						case PacketServer.BUY_SUCCESS:

							GameSounds.play("buy", true);

							switch (buy.goodId)
							{
								case PacketClient.BUY_ITEMS:
									Game.selfCastItems[buy.data]++;
									//DialogShop.onCastItemAdd(buy.data);
									FooterGame.updateCastItems([buy.data, 1]);
									break;
								case PacketClient.BUY_ITEM_SET:
									Game.selfCastItems[buy.data] += GameConfig.itemSetCount;
									//DialogShop.onCastItemAdd(buy.data);
									FooterGame.updateCastItems([buy.data, GameConfig.itemSetCount]);
									break;
								case PacketClient.BUY_ITEMS_FAST:
									var itemId:int = buy.data;
									var amount:int = buy.coins > 0 ? GameConfig.getItemFastCoinsCount(itemId) : GameConfig.itemFastCount;

									Game.selfCastItems[itemId] += amount;
									//DialogShop.onCastItemAdd(itemId);

									TapeShamanCastShop.resetButton(itemId);
									FooterGame.updateCastItems([itemId, amount]);
									break;
								case PacketClient.BUY_MANA_BIG:
									if (Game.self['clan_id'] > 0)
										ClanManager.request(Game.self['clan_id'], true, ClanInfoParser.TOTEMS_RANGS);
									break;
								case PacketClient.BUY_DECORATION:
									if (Screens.active is ScreenGame)
										return;
									ScreensLoader.load(ScreenProfile.instance);
									ScreenProfile.setPlayerId(Game.selfId);
									FooterTop.showDecorations();
									break;
								case PacketClient.BUY_SKIN:
									new DialogSkinBuy(buy.data).show();
									break;
								case PacketClient.BUY_PACKAGE:
									new DialogSkinBuy(buy.data).show();
									break;
								case PacketClient.BUY_MISC:
									if (buy.data == 0)
										new DialogShopNotify().show();
									break;
							}
							break;
						case PacketServer.BUY_FAIL:
						case PacketServer.BUY_NO_BALANCE:
						case PacketServer.BUY_PRICE_CHANGED:
							break;
					}
					break;
				}
				case PacketAdminMessage.PACKET_ID:
				{
					var messageAdmin: PacketAdminMessage = packet as PacketAdminMessage;
					CONFIG::debug
					{
						try
						{
							var fakePacket:Object = by.blooddy.crypto.serialization.JSON.decode(messageAdmin.message);
							if ('id' in fakePacket && fakePacket['id'] != Game.selfId)
								return;
							if ('type' in fakePacket && 'data' in fakePacket)
							{
								Connection.receiveFake(fakePacket['type'], fakePacket['data']);
								return;
							}
						}
						catch (e:Error)
						{}
					}
					var message:DialogInfo = new DialogInfo(gls("Сообщение"), messageAdmin.message, false, null, 300);
					message.show();
					break;
				}
				case PacketPlayWith.PACKET_ID:
				{
					var playWith: PacketPlayWith = packet as PacketPlayWith;

					switch (playWith.type)
					{
						case PacketServer.PLAY_OFFLINE:
							this.friendNotGame.show();
							break;
						case PacketServer.PLAY_FAILED:
							this.friendNotGameDefault.show();
							break;
						case PacketServer.NOT_EXIST:
							this.notExist.show();
							break;
						case PacketServer.FULL_ROOM:
							this.fullRoomGame.show();
							break;
						case PacketServer.NOT_IN_CLAN:
							this.notInClan.show();
							break;
						case PacketServer.UNAVAIABLE_LOCATION:
							this.unavaiableLocation.show();
							break;
						case PacketServer.LOW_ENERGY:
							DialogDepletionEnergy.show(playWith.locationId);
							break;
					}
					break;
				}

				case PacketBonuses.PACKET_ID:
				{
					var bonuses:PacketBonuses = packet as PacketBonuses;

					switch (bonuses.awardReason)
					{
						case PacketServer.REASON_GIFT:
							Screens.addCallback(function():void
							{
								RuntimeLoader.load(function():void
								{
									new BonusAnimation(bonuses);
								}, true);
							});
							break;
						case PacketServer.REASON_CELEBRATE:
							Screens.addCallback(function():void
							{
								RuntimeLoader.load(function():void
								{
									new DialogCelebrate(bonuses).show();
								}, true);
							});
							break;
						case PacketServer.REASON_HOT_WHEELS:
							Screens.addCallback(function():void
							{
								DialogHotWheelsBonus.show();
							});
							break;
					}
					break;
				}
				case PacketTransfer.PACKET_ID:
				{
					trace("TRANSFER STATUS = " + (packet as PacketTransfer).status);
					break;
				}
				/*case PacketTemporaryClothes.PACKET_ID:
				{
					var tempClothes: PacketTemporaryClothes = packet as PacketTemporaryClothes;
					var ids:Array = ClothesData.addTemporaryClothes(tempClothes.clothes);
					ClothesData.addTemporaryPackages(tempClothes.packages);

					DialogShop.onClothesAdd(ids);
					ScreenWardrobe.addClothesToWardrobe(ids);

					if (!ClothesData.firstInfo)
						return;
					ClothesData.firstInfo = false;
					Screens.addCallback(ClothesData.checkTime);
					break;
				}*/
			}
		}

		private function onApiLoaded(e:Event):void
		{
			Connection.connect(Config.SERVER_HOST, Config.SERVER_PORT);
		}

		private function onRefill(e:Event):void
		{
			Connection.sendData(PacketClient.REFILL);

			if (Game.self != null && (Game.self['type'] != Config.API_SA_ID || Services.isOAuth))
				Game.canOffer = false;
		}

		private function onLogin(e:LoginEvent):void
		{
			this.loginEvent = e;
			Login();
		}

		private function Login():void
		{
			if (this.loginEvent == null || this.quiz == null)
				return;

			TagManager.randTag();

			if (Services.isOAuth)
			{
				Connection.sendData(PacketClient.LOGIN, this.loginEvent.id, this.loginEvent.netType, 1, this.loginEvent.key, TagManager.tag, Referrers.get(), PreLoader.session['token']);
				return;
			}

			if (this.loginEvent.authKey == "")
				Connection.sendData(PacketClient.LOGIN, this.loginEvent.id, this.loginEvent.netType, 0, this.loginEvent.key, TagManager.tag, Referrers.get());
			else
				Connection.sendData(PacketClient.LOGIN, this.loginEvent.id, this.loginEvent.netType, 0, this.loginEvent.key, TagManager.tag, Referrers.get(), this.loginEvent.authKey);
		}

		private function onLogger(e:LoggerEvent):void
		{
			Logger.add("New loggerEvent: " + e.message);
		}

		private function onRequestPlayer(e:PlayersEvent):void
		{
			Connection.sendData(PacketClient.REQUEST, e.uids, e.rType[0]);
		}

		private function onReferal(e:ReferalEvent):void
		{
			Logger.add("REFERAL DETECTED!! ID INVITER " + e.id);
			Connection.sendData(PacketClient.INVITE, e.id);
		}

		private function onOfferAvalible(e:OfferAvalibleEvent):void
		{
			Game.offerUrl = e.offerUrl;
		}

		private function onGetCrossId(id:String):void
		{
			if (id)
			{
				Connection.sendData(PacketClient.TRANSFER, id, this.loginEvent.key, this.loginEvent.authKey);
				Game.openAppUrl = false;
				return;
			}

			Services.requestCrossId(onGetCrossId);
		}
	}
}