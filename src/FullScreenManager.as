package
{
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;

	import buttons.ButtonToggle;
	import events.ScreenEvent;
	import game.gameData.FlagsManager;
	import game.gameData.SettingsStorage;
	import game.mainGame.GameMap;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.ScreenStarling;
	import screens.Screens;
	import sounds.GameMusic;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.StatusFullScreen;
	import views.Settings;

	import protocol.Flag;

	import starling.core.Starling;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;

	import utils.FlashUtil;

	public class FullScreenManager extends EventDispatcher
	{
		public static const CHANGE_FULLSCREEN: String = 'changeFullScreen';

		static private const MIDDLE:int = 0;
		static private const LIGHT:int = 1;
		static private const DARK:int = 2;

		static private const BLACKOUT_BUTTONS:Array = [
			{'button': FullscreenMiddleButton,	'type': MIDDLE},
			{'button': FullscreenLightButton,	'type': LIGHT},
			{'button': FullscreenDarkButton,	'type': DARK}
		];

		static private var _instanse:FullScreenManager = null;

		private var _background:Bitmap = null;
		private var _lightSprite:Sprite = null;
		private var _blackSprite:Sprite = null;

		private var _glowImage:Bitmap = null;
		private var toggleSoundButtons:ButtonToggle = null;

		private var toggleBlackoutButtons:Sprite = null;
		private var blackoutButtons:Array = null;

		private var _currentBlackout:int = 0;

		private var resizeButton:FullscreenResizeButton = null;
		private var buttonsSprite:Sprite = null;
		private var gameMask:Sprite = null;

		private var gameMaskGameObjects: Sprite;

		private var blackoutSprite:Sprite = null;

		private var _fullScreen:Boolean = false;

		private var localData:Object;
		private var fullScreenChecked:Boolean = false;
		private var available:Boolean = false;
		private var stageEffectLayer: Sprite = new Sprite();
		private var _needResize: Boolean = false;

		public function FullScreenManager():void
		{
			Game.stage.addChild(stageEffectLayer);
			Game.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);

			init();
		}

		public static function instance(): FullScreenManager
		{
			if (!_instanse)
				_instanse = new FullScreenManager();
			return _instanse;
		}

		public function get fullScreen():Boolean
		{
			return this._fullScreen;
		}

		public function set fullScreen(value:Boolean):void
		{
			if (this._fullScreen == value)
				return;

			this._fullScreen = value;

			if (value)
			{
				try
				{
					Game.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					return;
				}
				catch(e:Error)
				{
					this._fullScreen = false;
					this.available = false;
					//TODO убирать с хедера
					//Settings.hideFullscreenButton();
					//HeaderShort.hideFullscreenButton();
				}
			}

			try
			{
				Game.stage.displayState = StageDisplayState.NORMAL;
			}
			catch (e: Error)
			{
				Logger.add('set fullScreen: ' + e.message);
			}
		}

		public function get fullScreenAvailable():Boolean
		{
			if (this.fullScreenChecked)
				return this.available;

			var session:Object = PreLoader.loaderInfo.parameters as Object;

			var socialType:String;
			if ("useApiType" in session)
				socialType = session['useApiType'];
			else if ("useapitype" in session)
				socialType = session['useapitype'];
			else
				socialType = Config.DEFAULT_API;

			var flashVersions:Object = FlashUtil.flashVersions;

			var isWeb:Boolean = false;

			try
			{
				isWeb = Boolean(ExternalInterface.call("eval", "true;"));
			}
			catch (e:Error)
			{}

			this.available = ((flashVersions['major'] > 11) || (flashVersions['major'] == 11 && flashVersions['minor'] >= 3)) && (isWeb || socialType != "sa");
			this.fullScreenChecked = true;

			return this.available;
		}

		private function init():void
		{
			this.gameMask = new Sprite();
			this.gameMask.graphics.beginFill(0xCCCCCC);
			this.gameMask.graphics.drawRect(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT);
			this.gameMask.graphics.endFill();
			stageEffectLayer.mouseChildren = false;
			stageEffectLayer.mouseEnabled = false;

			stageEffectLayer.blendMode = BlendMode.LAYER;
			this.gameMask.blendMode = BlendMode.ERASE;

			initGameObjectsMask();
			Game.gameSprite.mask = this.gameMaskGameObjects;
			Game.stage.color = 0xffffff;

			this.localData = SettingsStorage.load(SettingsStorage.SETTINGS);

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
		}

		private function initGameObjectsMask(): void
		{
			this.gameMaskGameObjects = new Sprite();
			this.gameMaskGameObjects.graphics.beginFill(0xCCCCCC, 0);
			this.gameMaskGameObjects.graphics.drawRect(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT);
			this.gameMaskGameObjects.graphics.endFill();
			this.gameMaskGameObjects.mouseChildren = false;
			this.gameMaskGameObjects.mouseEnabled = false;
		}

		private function get background():Bitmap
		{
			if (this._background == null)
				this._background = new Bitmap(new FullscreenBackgroundBmp);

			return this._background;
		}

		private function get lightSprite():Sprite
		{
			if (this._lightSprite == null)
			{
				this._lightSprite = new Sprite();
				this._lightSprite.graphics.beginFill(0xffffff, 0.45);
				this._lightSprite.graphics.drawRect(0, 0, Game.stage.fullScreenWidth, Game.stage.fullScreenHeight);
				this._lightSprite.graphics.endFill();
				this._lightSprite.cacheAsBitmap = true;
			}

			return this._lightSprite;
		}

		private function get blackSprite():Sprite
		{
			if (this._blackSprite == null)
			{
				this._blackSprite = new Sprite();
				this._blackSprite.graphics.beginFill(0x000000, 0.5);
				this._blackSprite.graphics.drawRect(0, 0, Game.stage.fullScreenWidth, Game.stage.fullScreenHeight);
				this._blackSprite.graphics.endFill();
				this._blackSprite.cacheAsBitmap = true;
			}

			return this._blackSprite;
		}

		private function get glowImage():Bitmap
		{
			if (this._glowImage == null)
				this._glowImage = new Bitmap(new fullScreenGlowBmp);

			return this._glowImage;
		}

		private function addButtons():void
		{
			if (this.buttonsSprite == null)
			{
				this.buttonsSprite = new Sprite();

				this.resizeButton = new FullscreenResizeButton();
				this.resizeButton.x = -6;
				this.resizeButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					fullScreen = false;
					GameSounds.play(SoundConstants.BUTTON_CLICK);
				});
				this.buttonsSprite.addChild(this.resizeButton);
				new StatusFullScreen(this.resizeButton, gls("Выйти из полноэкранного режима"));

				var soundOffButton:FullscreenSoundOffButton = new FullscreenSoundOffButton();
				soundOffButton.y = 30;
				soundOffButton.x = -6;
				soundOffButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					GameMusic.on = true;
					Settings.updateToggleButtons();
					GameSounds.play(SoundConstants.BUTTON_CLICK);
					FlagsManager.unset(Flag.MUSIC);
				});
				new StatusFullScreen(soundOffButton, gls("Включить музыку"));

				var soundOnButton:FullscreenSoundOnButton = new FullscreenSoundOnButton();
				soundOnButton.y = 30;
				soundOnButton.x = -6;
				soundOnButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					GameMusic.on = false;
					Settings.updateToggleButtons();
					GameSounds.play(SoundConstants.BUTTON_CLICK);
					FlagsManager.set(Flag.MUSIC);
				});
				new StatusFullScreen(soundOnButton, gls("Выключить музыку"));

				this.toggleSoundButtons = new ButtonToggle(soundOffButton, soundOnButton, GameMusic.on);
				this.buttonsSprite.addChild(this.toggleSoundButtons);

				this.toggleBlackoutButtons = new Sprite();
				this.toggleBlackoutButtons.addEventListener(MouseEvent.CLICK, changeBlackout);
				this.toggleBlackoutButtons.x = -2;
				this.toggleBlackoutButtons.y = soundOnButton.y + soundOnButton.height + 10;
				this.buttonsSprite.addChild(this.toggleBlackoutButtons);
				new StatusFullScreen(this.toggleBlackoutButtons, gls("Поменять яркость фона"));

				this.blackoutButtons = [];

				for (var i:int = 0; i < BLACKOUT_BUTTONS.length; i++)
				{
					this.blackoutButtons.push(new BLACKOUT_BUTTONS[i]['button']);
					this.toggleBlackoutButtons.addChild(this.blackoutButtons[i]);
					this.blackoutButtons[i].visible = false;
				}
				this.blackoutButtons[0].visible = true;
			}

			this.buttonsSprite.x = Game.gameSprite.x + Config.GAME_WIDTH + 26;
			this.buttonsSprite.y = Game.gameSprite.y + 250;
			Game.stage.addChild(this.buttonsSprite);
		}

		private function set blackout(value:int):void
		{
			this.localData['blackout'] = value;
			SettingsStorage.save(SettingsStorage.SETTINGS, this.localData);

			if (this.blackoutSprite != null && stageEffectLayer.contains(this.blackoutSprite))
				stageEffectLayer.removeChild(this.blackoutSprite);

			if (this.localData['blackout'] == DARK)
			{
				this.blackoutSprite = this.blackSprite;
				stageEffectLayer.addChild(this.blackoutSprite);
			}
			else if (this.localData['blackout'] == LIGHT)
			{
				this.blackoutSprite = this.lightSprite;
				stageEffectLayer.addChild(this.blackoutSprite);
			}

			stageEffectLayer.addChild(this.glowImage);
			stageEffectLayer.addChild(this.gameMask);
			Game.stage.addChild(Game.gameSprite);

			addButtons();
		}

		private function get currentBlackout():int
		{
			return this._currentBlackout;
		}

		private function set currentBlackout(type:int):void
		{
			this.blackoutButtons[this._currentBlackout].visible = false;
			this._currentBlackout = type < BLACKOUT_BUTTONS.length ? type : 0;
			this.blackoutButtons[this._currentBlackout].visible = true;

			if (this.localData['blackout'] == BLACKOUT_BUTTONS[this._currentBlackout]['type'])
				return;

			blackout = BLACKOUT_BUTTONS[this._currentBlackout]['type'];
		}

		private function changeBlackout(e:MouseEvent):void
		{
			currentBlackout++;
			GameSounds.play(SoundConstants.BUTTON_CLICK);
		}

		private function removeButtons():void
		{
			if (this.buttonsSprite == null || this.buttonsSprite.parent == null)
				return;

			Game.stage.removeChild(this.buttonsSprite);
		}

		public function updateToggleButtons():void
		{
			if (this.buttonsSprite == null)
				return;

			GameMusic.on ? this.toggleSoundButtons.on() : this.toggleSoundButtons.off();

			initGameObjectsMask();
			gameMaskGameObjects.x = gameMask.x;
			gameMaskGameObjects.y = gameMask.y;
			Game.gameSprite.mask = gameMaskGameObjects;
		}

		public function get needResize(): Boolean
		{
			return 	_needResize;
		}

		private function onScreenChanged(e: ScreenEvent): void
		{
			_needResize = (e.screen is ScreenGame || e.screen is ScreenSchool);

			applyRequiredFullScreen();
			dispatchEvent(new Event(CHANGE_FULLSCREEN));
		}

		private function applyRequiredFullScreen(): void
		{
			if (this.fullScreen)
			{
				if (_needResize)
				{
					redrawFullscreenResize();
				}
				else
				{
					redrawFullscreen();
				}
			}
		}

		private function redrawFullscreenResize(): void
		{
			GameMap.gameScreenWidth = ScreenStarling.mainScreenMaxSize;
			GameMap.gameScreenHeight = ScreenStarling.mainScreenSideSize;

			Starling.current.viewPort = new Rectangle(0, 0,
				ScreenStarling.mainScreenMaxSize * ScreenStarling.scaleFactorScreen,
				ScreenStarling.mainScreenSideSize * ScreenStarling.scaleFactorScreen
			);
			Starling.current.stage.stageWidth = ScreenStarling.mainScreenMaxSize;
			Starling.current.stage.stageHeight = ScreenStarling.mainScreenSideSize;

			this.gameMask.x = Game.gameSprite.x = 0;
			this.gameMask.y = Game.gameSprite.y = 0;
			initGameObjectsMask();
			this.gameMaskGameObjects.x = this.gameMask.x;
			this.gameMaskGameObjects.y = this.gameMask.y;

			this.background.x = 0;
			this.background.y = 0;

			this.glowImage.x = 0;
			this.glowImage.y = 0;
			stageEffectLayer.visible = false;
			if (this.buttonsSprite)
				this.buttonsSprite.visible = false;

			Game.gameSprite.mask = null;
		}

		private function redrawFullscreen(): void
		{
			GameMap.gameScreenWidth = Config.GAME_WIDTH;
			GameMap.gameScreenHeight =  Config.GAME_HEIGHT;

			Game.starling.stage.stageWidth = Config.GAME_WIDTH;
			Game.starling.stage.stageHeight = Config.GAME_HEIGHT;

			RectangleUtil.fit(
				new Rectangle(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT),
				new Rectangle(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT),
				ScaleMode.NONE, false, Starling.current.viewPort
			);

			Starling.current.viewPort.x = (Game.stage.fullScreenWidth - Config.GAME_WIDTH) / 2;
			Starling.current.viewPort.y = (Game.stage.fullScreenHeight - Config.GAME_HEIGHT) / 2;

			this.gameMask.x = Game.gameSprite.x = (Game.stage.fullScreenWidth - Config.GAME_WIDTH) / 2;
			this.gameMask.y = Game.gameSprite.y = (Game.stage.fullScreenHeight - Config.GAME_HEIGHT) / 2;
			initGameObjectsMask();

			this.gameMaskGameObjects.x = this.gameMask.x;
			this.gameMaskGameObjects.y = this.gameMask.y;

			Game.gameSprite.mask = this.gameMaskGameObjects;

			this.background.x = Game.gameSprite.x - 435;
			this.background.y = Game.gameSprite.y - 132;

			this.glowImage.x = Game.gameSprite.x - 106;
			this.glowImage.y = Game.gameSprite.y - 103;

			stageEffectLayer.visible = true;

			if (this.buttonsSprite)
				this.buttonsSprite.visible = true;

			this.buttonsSprite.x = Game.gameSprite.x + Config.GAME_WIDTH + 26;
			this.buttonsSprite.y = Game.gameSprite.y + 250;
			stageEffectLayer.addChild(this.gameMask);
		}

		private function onFullScreen(e:FullScreenEvent):void
		{
			this._fullScreen = e.fullScreen;
			Settings.updateToggleButtons();
			//TODO
			//HeaderShort.updateFullScreenButtons();
			Game.gameSprite.mask = null;

			if (e.fullScreen)
			{
				Game.stage.color = 0x6491b8;
				Starling.current.stage.color = 0x6491b8;

				this.stageEffectLayer.addChild(this.background);

				blackout = this.localData['blackout'];
				currentBlackout = this.localData['blackout'];
			}
			else
			{
				Game.starling.viewPort = new Rectangle(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT);

				Game.starling.stage.stageWidth = Config.GAME_WIDTH;
				Game.starling.stage.stageHeight = Config.GAME_HEIGHT;
				GameMap.gameScreenWidth = Config.GAME_WIDTH;
				GameMap.gameScreenHeight = Config.GAME_HEIGHT;

				Starling.current.viewPort.x = 0;
				Starling.current.viewPort.y = 0;

				Game.stage.color = 0xffffff;

				removeButtons();

				 if (this.blackSprite.parent)
					 stageEffectLayer.removeChild(this.blackSprite);

				 if (this.lightSprite.parent)
				 	stageEffectLayer.removeChild(this.lightSprite);

				 if (this.background.parent != null)
				 	stageEffectLayer.removeChild(this.background);

				 if (this.glowImage.parent != null)
				 	stageEffectLayer.removeChild(this.glowImage);

				 this.gameMask.x = Game.gameSprite.x = 0;
				 this.gameMask.y = Game.gameSprite.y = 0;

				 initGameObjectsMask();
				 this.gameMaskGameObjects.x = this.gameMask.x;
				 this.gameMaskGameObjects.y = this.gameMask.y;
				 Game.gameSprite.mask = this.gameMaskGameObjects;
			}

			applyRequiredFullScreen();

			dispatchEvent(new Event(CHANGE_FULLSCREEN));
		}

	}
}