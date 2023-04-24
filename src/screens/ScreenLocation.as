package screens
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.system.Capabilities;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;

	import clans.ClanManager;
	import dialogs.DialogDailyQuests;
	import dialogs.DialogDepletionEnergy;
	import dialogs.DialogGifts;
	import dialogs.DialogInfo;
	import dialogs.DialogNeedUpdatePlayer;
	import dialogs.DialogOfferQuest;
	import dialogs.DialogOfferVKQuest;
	import dialogs.DialogViralityQuest;
	import dialogs.education.DialogEducationQuest;
	import events.DiscountEvent;
	import events.GameEvent;
	import game.gameData.EducationQuestManager;
	import game.gameData.FlagsManager;
	import game.gameData.GameConfig;
	import game.gameData.NotificationManager;
	import game.gameData.PowerManager;
	import loaders.RuntimeLoader;
	import mobile.view.locations.MapLocations;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import views.LoadGameAnimation;
	import views.NotificationView;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketFriendsOnline;
	import protocol.packages.server.PacketOnline;

	import utils.starling.utils.CacheImages;

	public class ScreenLocation extends Screen
	{
		static private var _instance:ScreenLocation = null;

		static public var _firstShow:Boolean = true;

		private var unlockedLocs:Array = [];

		private var offersSprite:Sprite = null;

		private var buttonDailyQuest:SimpleButton = null;
		private var buttonViralityQuest:SimpleButton = null;
		private var buttonFriendGifts:SimpleButton = null;

		private var spriteInterface:Sprite = null;

		private var friendsOnline:Object = {};

		private var dialogOffers:DialogOfferQuest = new DialogOfferQuest();
		private var dialogOffersVK:DialogOfferVKQuest = new DialogOfferVKQuest();

		private var _scrollLocations: MapLocations = null;

		public function ScreenLocation():void
		{
			super();
			init();

			_instance = this;

			Connection.listen(onPacket, [PacketOnline.PACKET_ID, PacketFriendsOnline.PACKET_ID]);
		}

		static public function setLevel(level:int):void
		{
			_instance.setLevel(level);
		}

		static public function addOffers(offers:Array):void
		{
			_instance.dialogOffers.setOffers(offers, _instance.showOffersFP);
		}

		static public function addOffersVK(offers:Array):void
		{
			_instance.dialogOffersVK.setOffers(offers, _instance.showOffersVK);
		}

		static public function addThzOffer(button:DisplayObject):void
		{
			button.y = _instance.offersSprite.height;
			_instance.offersSprite.addChild(button);
		}

		static public function addBrightStatOffer():void
		{
			if (_instance == null)
				return;
			_instance.sortMenu();
		}

		static public function sortMenu():void
		{
			if (_instance == null)
				return;
			_instance.sortMenu();
		}

		override public function show():void
		{
			super.show();

			if (_firstShow)
			{
				for (var i:int = 0; i < MailManager.dialogsArray.length; i++)
					MailManager.dialogsArray[i].show();

				if (Game.self['clan_id'] != 0)
				{
					if (ClanManager.getClan(Game.self['clan_id']).state == PacketServer.CLAN_STATE_BANNED)
						new DialogInfo(gls("Клан заблокирован."), gls("Твой клан заблокирован за нарушения.")).show();
				}

				sortMenu();

				_firstShow = false;
			}

			RuntimeLoader.loadLib(onLoadRuntimeLib);

			if (_scrollLocations)
				_scrollLocations.show();
		}

		override public function hide():void
		{
			super.hide();

			if (_scrollLocations)
				_scrollLocations.hide();
		}

		private function onLoadRuntimeLib(): void
		{
			new CacheImages;
		}

		private function init():void
		{
			var ids:Array = [Locations.ISLAND_ID, Locations.SWAMP_ID, Locations.HARD_ID, Locations.DESERT_ID, Locations.STORM_ID, Locations.ANOMAL_ID];

			_scrollLocations = new MapLocations(unlockedLocs, null, playLocation);
			_scrollLocations.hide();
			_scrollLocations.addEventListener(GameEvent.CHANGED, onCardChanged);

			for (var i:int = 0; i < ids.length; i++)
			{
				this.friendsOnline[ids[i]] = getFriendImage(593, 129, 0);
				var image:Sprite = this.friendsOnline[ids[i]]['image'];
				this.friendsOnline[ids[i]]['count'] = 0;
				this.addChild(image);
				image.visible = false;
			}

			initButtons();
			sortMenu();

			var majorVersion:Number = parseInt(Capabilities.version.split(",")[0].split(" ")[1]);
			if (majorVersion < Config.MIN_VERSION_PLAYER)
				new DialogNeedUpdatePlayer().show();

			Logger.add('flash player ver: ' + majorVersion);

			DiscountManager.addEventListener(DiscountEvent.BONUS_START, onBonus);
		}

		private function onCardChanged(event:GameEvent = null):void
		{
			for (var i:int = 0; i < Locations.LIST.length; i++)
			{
				if(!(Locations.LIST[i].value in this.friendsOnline) ||
					this.friendsOnline[Locations.LIST[i].value]['count'] == 0)
					continue;

				this.friendsOnline[Locations.LIST[i].value]['image'].visible =
					Locations.LIST[i].value == _scrollLocations.locationID;
				var field:GameField = this.friendsOnline[Locations.LIST[i].value]['field'];
				field.visible = Locations.LIST[i].value == _scrollLocations.locationID;
			}
		}

		private function playLocation(locationId: int, event: Event = null): void
		{
			if (this.unlockedLocs.indexOf(locationId) == -1)
				return;

			if (locationId == Locations.BATTLE_ID && !FlagsManager.has(Flag.BATTLE_SCHOOL_FINISH))
			{
				RuntimeLoader.load(function():void
				{
					ScreenSchool.type = ScreenSchool.BATTLE;
					Screens.show("School");
				}, true);
				return;
			}

			if(locationId == Locations.SCHOOL_ID)
			{
				RuntimeLoader.load(function():void
				{
					ScreenSchool.type = FlagsManager.has(Flag.MAGIC_SCHOOL_FINISH) ? ScreenSchool.SHAMAN : ScreenSchool.MAGIC;
					Screens.show("School");
				}, true);
				return;
			}

			if (event)
				event.stopImmediatePropagation();

			if (!PowerManager.isEnoughEnergy(locationId))
			{
				DialogDepletionEnergy.show(locationId);
				return;
			}

			LoadGameAnimation.instance.close();

			RuntimeLoader.load(function():void
			{
				if (EducationQuestManager.firstGame)
					setTimeout(Screens.show, 2000, "Learning");
				else
					ScreenGame.start(locationId, false, false);
			}, true);
		}

		private function initButtons():void
		{
			this.spriteInterface = new Sprite;

			this.buttonDailyQuest = new ButtonQuestShow;
			this.buttonDailyQuest.x = 10;
			this.buttonDailyQuest.scaleX = this.buttonDailyQuest.scaleY = 0.85;
			this.buttonDailyQuest.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				GameSounds.play(SoundConstants.BUTTON_CLICK, true);

				if (EducationQuestManager.educationQuest)
					DialogEducationQuest.show();
				else
					DialogDailyQuests.show();
			});
			this.spriteInterface.addChild(this.buttonDailyQuest);
			new Status(this.buttonDailyQuest, gls("Задания"));
			NotificationManager.instance.register(NotificationManager.DAILY_QUEST, new NotificationView(this.buttonDailyQuest, 35, 35));

			EducationQuestManager.fieldState.x = 60;
			EducationQuestManager.fieldState.y = 5;
			this.spriteInterface.addChild(EducationQuestManager.fieldState);

			EducationQuestManager.arrowMovie.x = 175;
			EducationQuestManager.arrowMovie.y = 20;

			this.spriteInterface.addChild(EducationQuestManager.arrowMovie);

			this.buttonFriendGifts = new ButtonFriendGiftsShow();
			this.buttonFriendGifts.x = 10;
			this.buttonFriendGifts.y = 60;
			this.buttonFriendGifts.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				GameSounds.play(SoundConstants.BUTTON_CLICK, true);

				RuntimeLoader.load(function():void
				{
					DialogGifts.show();
				});
			});

			this.spriteInterface.addChild(this.buttonFriendGifts);
			new Status(this.buttonFriendGifts, gls("Подарки друзьям"));

			this.buttonViralityQuest = new (Config.isRus ? ButtonViralityQuestsShowRu : ButtonViralityQuestsShowEn);
			this.buttonViralityQuest.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				GameSounds.play(SoundConstants.BUTTON_CLICK, true);
				DialogViralityQuest.show();
			});

			this.buttonViralityQuest.x = 38;
			this.buttonViralityQuest.y = 26;

			this.spriteInterface.addChild(this.buttonViralityQuest);
			new Status(this.buttonViralityQuest, ViralityQuestManager.COINS.toString() + ' ' + gls("монет бесплатно"));

			this.offersSprite = new Sprite();
			this.offersSprite.x = 822;
			this.offersSprite.y = 123;
			this.spriteInterface.addChild(this.offersSprite);

			this.spriteInterface.y = 100;
			addChild(this.spriteInterface);
		}

		private function onBonus(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.LOCATIONS && e.id != DiscountManager.LOCATIONS_NP)
				return;
			ScreenLocation.setLevel(Experience.selfLevel);
		}

		private function getFriendImage(x:int, y:int, angle:int = 0):Object
		{
			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			var onlineView:FriendsOnlineImage = new FriendsOnlineImage();
			onlineView.rotation = angle;
			sprite.addChild(onlineView);
			new Status(onlineView, gls("Количество твоих друзей на локации"));

			var field:GameField = new GameField("", 0, 0, new TextFormat(GameField.PLAKAT_FONT, 14, 0x000000));
			field.filters = [new GlowFilter(0xE5E1D4, 1.0, 2, 2, 8)];
			field.mouseEnabled = false;
			field.x = -(field.textWidth * 0.5) - 2;
			field.y = -(field.textHeight * 0.5) - 2;
			sprite.addChild(field);

			sprite.visible = false;

			return {'image': sprite, 'field': field};
		}

		private function setLevel(selfLevel:int):void
		{
			selfLevel = Math.max(selfLevel, DiscountManager.freeContent ? GameConfig.maxLevel : 0);
			this.unlockedLocs = Locations.getLocations(selfLevel);

			if (_scrollLocations)
				_scrollLocations.updateLocationUnlock(this.unlockedLocs);

			sortMenu();
		}

		private function onPacket(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketOnline.PACKET_ID:
				{
					if (!_scrollLocations)
						return;
					_scrollLocations.updateOnline((packet as PacketOnline).locationsOnline);
					break;
				}
				case PacketFriendsOnline.PACKET_ID:
				{
					var friendsOnline: PacketFriendsOnline = packet as PacketFriendsOnline;
					for each (var object:Object in this.friendsOnline)
						object['image'].visible = false;

					for (var i:int = 0, len:int = friendsOnline.items.length; i < len; i++)
					{
						if (!(friendsOnline.items[i].locationId in this.friendsOnline))
							continue;
						this.friendsOnline[friendsOnline.items[i].locationId]['image'].visible = true;
						this.friendsOnline[friendsOnline.items[i].locationId]['count'] = (friendsOnline.items[i].count >= 0 ? friendsOnline.items[i].count
							: (friendsOnline.items[i].count + 256));

						var field:GameField = this.friendsOnline[friendsOnline.items[i].locationId]['field'];

						field.text = (friendsOnline.items[i].count >= 0 ? friendsOnline.items[i].count : (friendsOnline.items[i].count + 256)).toString();
						field.x = -(field.textWidth * 0.5) - 2;
						field.y = -(field.textHeight * 0.5) - 2;
					}

					onCardChanged();
					break;
				}
			}
		}

		private function sortMenu():void
		{
			this.offersSprite.y = 145;

			this.buttonFriendGifts.visible = (Experience.selfLevel >= Game.LEVEL_TO_INVITE) && MailManager.friendsArray != null && (MailManager.friendsArray.length == 0 || (MailManager.friendsArray.length > DialogGifts.sendedIds.length));
			this.buttonFriendGifts.y = this.buttonDailyQuest.y + (this.buttonDailyQuest.visible ? 60 : 0);

			this.buttonViralityQuest.y = this.buttonFriendGifts.y + (this.buttonFriendGifts.visible ? 85 : 27);
			this.buttonViralityQuest.visible = ViralityQuestManager.questAvailable && !ViralityQuestManager.questCompleted;

			//this.schoolView.visible = false;
			//this.schoolView.visible = this.schoolView.visible || (EducationQuestManager.allowMagic && !FlagsManager.has(Flag.MAGIC_SCHOOL_FINISH) && Experience.selfLevel >= Game.LEVEL_TO_LEAVE_SANDBOX);
			//this.schoolView.visible = this.schoolView.visible || (EducationQuestManager.allowSchool && !FlagsManager.has(Flag.SHAMAN_SCHOOL_FINISH) && Experience.selfLevel >= Game.LEVEL_TO_OPEN_SHAMAN);
		}

		private function showOffersFP():void
		{
			showOffers();
		}

		private function showOffersVK():void
		{
			showOffers();
		}

		private function showOffers():void
		{
			sortMenu();
		}
	}
}