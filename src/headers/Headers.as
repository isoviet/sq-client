package headers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import buttons.ButtonToggle;
	import events.ScreenEvent;
	import game.gameData.DailyBonusManager;
	import game.gameData.EducationQuestManager;
	import screens.Screen;
	import screens.ScreenClan;
	import screens.ScreenDisconnected;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.ScreenLocation;
	import screens.ScreenProfile;
	import screens.ScreenSchool;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import views.BalanceView;
	import views.BonusBarView;
	import views.PowerBarsView;
	import views.Settings;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.anchorHelp.AnchorEnum;
	import utils.anchorHelp.AnchorHelpManager;

	public class Headers extends Sprite
	{
		static private const TYPE_EXTENDED:int = 0;
		static private const TYPE_GAME:int = 1;
		static private const TYPE_HIDE:int = 2;
		static private const TYPE_LEARNING:int = 3;

		static private var _instance:Headers;

		private var lastType:int = -1;

		private var settings:Settings;
		private var balance:BalanceView;
		private var powers:PowerBarsView;
		private var bonusBarView:BonusBarView;

		private var buttonToggleFullscreen:ButtonToggle;

		private var isShort:Boolean = false;

		public function Headers():void
		{
			_instance = this;

			super();

			init();

			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
		}

		public function onFullScreen(e:Event): void
		{
			if (!_instance)
				return;

			if (this.buttonToggleFullscreen)
				this.buttonToggleFullscreen.x = Game.starling.stage.stageWidth - (this.isShort ? 145 : 30);
			this.settings.x = Game.starling.stage.stageWidth - (this.isShort ? 95 : 35);

			HeaderShort.onFullScreen();
		}

		private function init():void
		{
			addChild(new HeaderExtended);
			addChild(new HeaderShort);

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);

			this.settings = new Settings();
			addChild(this.settings);

			if (FullScreenManager.instance().fullScreenAvailable)
			{
				var buttonFullscreenOn:ButtonFullscreenHeaderOn = new ButtonFullscreenHeaderOn();
				buttonFullscreenOn.addEventListener(MouseEvent.CLICK, fullscreenOn);
				new Status(buttonFullscreenOn, gls("Перейти в полноэкранный режим"));

				var buttonFullscreenOff:ButtonFullscreenHeaderOff = new ButtonFullscreenHeaderOff();
				buttonFullscreenOff.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					GameSounds.play(SoundConstants.BUTTON_CLICK);
					FullScreenManager.instance().fullScreen = false;
				});
				new Status(buttonFullscreenOff, gls("Выйти из полноэкранного режима"));

				this.buttonToggleFullscreen = new ButtonToggle(buttonFullscreenOn, buttonFullscreenOff, FullScreenManager.instance().fullScreen);
				this.buttonToggleFullscreen.x = 873;
				this.buttonToggleFullscreen.y = 15;
				this.buttonToggleFullscreen.visible = false;
				addChild(this.buttonToggleFullscreen);
			}

			this.powers = new PowerBarsView();
			this.powers.y = 10;
			addChild(this.powers);

			this.bonusBarView = new BonusBarView();
			this.bonusBarView.y = 56;
			this.bonusBarView.visible = false;
			addChild(this.bonusBarView);

			this.balance = new BalanceView();
			this.balance.y = 15;
			addChild(this.balance);

			AnchorHelpManager.instance.addAnchorObject(AnchorEnum.GameMannaAnchor, this.powers);
		}

		private function fullscreenOn(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);
			Analytics.fullScreen();
			Connection.sendData(PacketClient.COUNT, PacketClient.FULLSCREEN);
			FullScreenManager.instance().fullScreen = true;
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			var newType:int = getHeaderType(e.screen);
			if (this.lastType == newType)
				return;
			this.lastType = newType;

			if (e.screen is ScreenDisconnected)
			{
				this.visible = false;
				return;
			}

			HeaderExtended.hide();
			HeaderShort.hide();
			HeaderShort.enableMiddleHeader = true;
			HeaderShort.enableButtons = true;
			this.bonusBarView.visible = true;

			switch (this.lastType)
			{
				case TYPE_EXTENDED:
					HeaderExtended.show();
					toggleElements(true);
					move(false);
					break;
				case TYPE_HIDE:
				case -1:
					HeaderShort.hide();
					HeaderExtended.hide();
					toggleElements(false);
					break;
				case TYPE_GAME:
					HeaderShort.show();
					toggleElements(true);
					move(true);
					break;
				case TYPE_LEARNING:
					HeaderShort.show();
					toggleElements(true);
					this.bonusBarView.visible = false;
					HeaderShort.enableButtons = false;
					HeaderShort.enableMiddleHeader = false;
					move(true);
					break;
			}
		}

		private function move(isShort:Boolean):void
		{
			this.isShort = isShort;

			if (this.buttonToggleFullscreen)
			{
				this.buttonToggleFullscreen.x = Game.starling.stage.stageWidth - (this.isShort ? 145 : 30);
				this.buttonToggleFullscreen.y = this.isShort ? 14 : 15;
			}

			this.settings.x = Game.starling.stage.stageWidth - (this.isShort ? 95 : 35);
			this.settings.y = (this.isShort ? 10 : 40);

			this.balance.x = (this.isShort ? 120 : 210);
			this.balance.notify.visible = !this.isShort && DailyBonusManager.haveBonus && EducationQuestManager.allowDailyBonus;

			this.bonusBarView.x = this.isShort ? 15 : 105;
			this.powers.x = (this.isShort ? 5 : 95);
		}

		private function toggleElements(value:Boolean):void
		{
			this.settings.visible = value;
			this.balance.visible = value;
			this.bonusBarView.visible = value;
			this.powers.visible = value;

			if (this.buttonToggleFullscreen)
				this.buttonToggleFullscreen.visible = value;
		}

		private function getHeaderType(screen:Screen):int
		{
			if (screen is ScreenLocation || screen is ScreenProfile || screen is ScreenClan)
				return TYPE_EXTENDED;

			if (screen is ScreenGame || screen is ScreenSchool)
				return TYPE_GAME;

			if (screen is ScreenLearning)
				return TYPE_LEARNING;

			if (screen is ScreenEdit)
				return TYPE_HIDE;

			return -1;
		}
	}
}