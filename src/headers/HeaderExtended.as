package headers
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import dialogs.DialogShop;
	import events.ScreenEvent;
	import game.gameData.HolidayManager;
	import game.gameData.NotificationManager;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import screens.ScreenClan;
	import screens.ScreenLocation;
	import screens.ScreenProfile;
	import screens.ScreenRating;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import views.NotificationView;
	import views.PlayerPlaceSmall;
	import views.TvView;

	public class HeaderExtended extends Sprite
	{
		static private var _instance:HeaderExtended;

		private var selfPlace:PlayerPlaceSmall;

		private var group:ButtonTabGroup;

		private var buttonNews:SimpleButton;
		private var buttonShop:SimpleButton;
		private var buttonPlanet:ButtonTab;
		private var buttonProfile:ButtonTab;
		private var buttonRating:ButtonTab;

		private var buttonEvent:SimpleButton;

		private var headerBar:HeaderBar;

		public function HeaderExtended():void
		{
			_instance = this;

			super();

			this.visible = false;

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);

			init();
		}

		static public function toggleButtons(value:Boolean):void
		{
			_instance.headerBar.update(value);
		}

		static public function update():void
		{
			_instance.update();
		}

		static public function show():void
		{
			_instance.visible = true;
		}

		static public function hide():void
		{
			_instance.visible = false;
		}

		private function init():void
		{
			addChild(new HeaderLeftBack);

			var back:DisplayObject = new HeaderRightBack();
			if (!HolidayManager.isHolidayEnd)
				back.width = 385;
			back.x = Config.GAME_WIDTH - back.width;
			addChild(back);

			this.selfPlace = new PlayerPlaceSmall(new PhotoHeaderFrame);
			this.selfPlace.x = 5;
			addChild(this.selfPlace);

			if (!HolidayManager.isHolidayEnd)
			{
				this.buttonEvent = new ButtonHeaderHoliday();
				this.buttonEvent.x = 548;
				this.buttonEvent.y = 37;
				this.buttonEvent.addEventListener(MouseEvent.CLICK, HolidayManager.showLottery);
				addChild(this.buttonEvent);
				new Status(this.buttonEvent, HolidayManager.holidayName);
			}

			this.buttonPlanet = new ButtonTab(new ButtonHeaderPlanet);
			this.buttonPlanet.x = 605;
			this.buttonPlanet.y = 35;
			this.buttonPlanet.addEventListener(MouseEvent.CLICK, showLocation);
			this.buttonPlanet.addEventListener(MouseEvent.MOUSE_OVER, onLocation)
			addChild(this.buttonPlanet);
			new Status(buttonPlanet, gls("Планета"));

			this.buttonProfile = new ButtonTab(new ButtonHeaderHome);
			this.buttonProfile.x = 665;
			this.buttonProfile.y = 35;
			this.buttonProfile.addEventListener(MouseEvent.CLICK, showHome);
			this.buttonProfile.addEventListener(MouseEvent.ROLL_OVER, onOverButton);
			this.buttonProfile.addEventListener(MouseEvent.ROLL_OUT, onOutButton);
			addChild(this.buttonProfile);
			new Status(this.buttonProfile, gls("Домик"));
			NotificationManager.instance.register(NotificationManager.COLLECTION | NotificationManager.MAIL | NotificationManager.LEPRECHAUN, new NotificationView(this.buttonProfile.getChildAt(0), 10, 10));

			this.buttonShop = Config.isRus ? new ButtonHeaderShopRu() : new ButtonHeaderShopEn();
			this.buttonShop.x = 725;
			this.buttonShop.y = 35;
			this.buttonShop.addEventListener(MouseEvent.CLICK, showShop);
			this.buttonShop.addEventListener(MouseEvent.MOUSE_OVER, onShowShop);
			addChild(this.buttonShop);
			new Status(buttonShop, gls("Магазин"));
			NotificationManager.instance.register(NotificationManager.SHOP, new NotificationView(this.buttonShop, 10, 10));

			this.buttonNews = new ButtonHeaderNews();
			this.buttonNews.x = 785;
			this.buttonNews.y = 35;
			this.buttonNews.addEventListener(MouseEvent.CLICK, showNews);
			this.buttonNews.addEventListener(MouseEvent.MOUSE_OVER, onShowNews);
			addChild(this.buttonNews);
			new Status(this.buttonNews, gls("Новости"));
			NotificationManager.instance.register(NotificationManager.NEWS, new NotificationView(this.buttonNews, 10, 10));

			this.buttonRating = new ButtonTab(new ButtonHeaderRating);
			this.buttonRating.x = 840;
			this.buttonRating.y = 40;
			this.buttonRating.addEventListener(MouseEvent.CLICK, showRating);
			this.buttonRating.addEventListener(MouseEvent.MOUSE_OVER, onShowRating);
			addChild(this.buttonRating);
			new Status(this.buttonRating, gls("Рейтинг игроков"));

			this.group = new ButtonTabGroup();
			this.group.insert(this.buttonPlanet);
			this.group.insert(this.buttonProfile);
			this.group.insert(this.buttonRating);
			this.group.setSelected(buttonPlanet);
			addChild(this.group);

			this.headerBar = new HeaderBar();
			this.headerBar.x = 575;
			this.headerBar.hide();
			addChildAt(this.headerBar, 0);
		}

		private function onShowRating(event:MouseEvent):void
		{
			GameSounds.play("reiting", true);
		}

		private function onShowNews(event:MouseEvent):void
		{
			GameSounds.play("paper", true);
		}

		private function onShowShop(event:MouseEvent):void
		{
			GameSounds.play("icon_shop_1", true);
		}

		private function onLocation(event:MouseEvent):void
		{
			GameSounds.play(SoundConstants.CLICK, true);
		}

		private function update():void
		{
			if (Game.self == null)
				return;

			this.selfPlace.setPlayer(Game.self);
		}

		private function showLocation(e:MouseEvent):void
		{
			Screens.show("Location");
		}

		private function showHome(e:MouseEvent):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenProfile.instance);
		}

		private function showNews(e:MouseEvent = null):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);
			TvView.show(true);
		}

		private function showShop(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);

			RuntimeLoader.load(function():void
			{
				DialogShop.instance.show();
			});
		}

		private function showRating(e:MouseEvent):void
		{
			ScreensLoader.load(ScreenRating.instance);
		}

		private function onOverButton(e:MouseEvent):void
		{
			GameSounds.play("hous", true);

			if (Screens.active is ScreenLocation || Screens.active is ScreenClan)
				this.headerBar.show();
		}

		private function onOutButton(e:MouseEvent):void
		{
			if (this.headerBar.visible)
				this.headerBar.hideAfterTime();
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (e.screen is ScreenLocation)
				this.group.setSelected(this.buttonPlanet);
			else if (e.screen is ScreenRating)
				this.group.setSelected(this.buttonRating);
			else if (e.screen is ScreenProfile)
				this.group.setSelected(this.buttonProfile);

			toggleButtons(e.screen is ScreenProfile);
		}
	}
}