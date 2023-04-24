package screens
{
	import flash.events.FullScreenEvent;
	import flash.system.Capabilities;

	import loaders.HeroLoader;

	import feathers.themes.AeonDesktopTheme;

	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;

	import utils.starling.utils.StarlingConverter;

	public class ScreenStarling extends Sprite
	{
		private const SCALE_SCENE: Number = 1;
		private static var _instance:ScreenStarling;
		private static var _groundLayer:Sprite = new Sprite();
		private static var _upLayer:Sprite = new Sprite();
		private static var _debugLayer:Sprite = new Sprite();

		private static var _hardwareAccelerationEnable:Boolean = false;
		public static var scaleFactorScreen: Number = 1;
		public static var mainScreenSideSize: Number = 0;
		public static var mainGameSideSize: Number = 0;
		public static var mainScreenMaxSize: Number = 0;
		public static var mainGameMaxSize: Number = 0;

		private static var sizeAppend:Number;
		/**
		 *  constructor
		 *
		 *  @return ScreenStarling
		 **/
		public function ScreenStarling()
		{
			mainScreenSideSize = Math.min(Capabilities.screenResolutionY, Capabilities.screenResolutionX);
			mainScreenMaxSize = Math.max(Capabilities.screenResolutionY, Capabilities.screenResolutionX);
			mainGameSideSize = mainScreenSideSize == Capabilities.screenResolutionY ? Config.GAME_HEIGHT : Config.GAME_WIDTH;
			mainGameMaxSize =  mainScreenMaxSize == Capabilities.screenResolutionY ? Config.GAME_HEIGHT : Config.GAME_WIDTH;

			sizeAppend = (mainGameSideSize *  0.5);
			scaleFactorScreen = Math.max(Math.min(mainScreenSideSize / mainGameSideSize, SCALE_SCENE), 1);

			StarlingConverter.scaleFactor = scaleFactorScreen < 1 ? 1 : scaleFactorScreen;
			this.alignPivot();
			_instance = this;
			_instance.addChild(_groundLayer);
			_instance.addChild(_upLayer);
			_instance.addChild(_debugLayer);

			new AeonDesktopTheme();
			HeroLoader.parseDataHero();
			trace('Starling ver:', Starling.VERSION);
			Logger.add('driver info', Starling.current.context.driverInfo);
			Logger.add('hardwareAccelerationEnable: ', hardwareAccelerationEnable);

			//profile baselineConstrained
			//drive info  Hw_disabled=userDisabled (Baseline Constrained)
			//profile baselineConstrained
			//drive info DirectX9 (Baseline Constrained)

			addEventListener(Event.ENTER_FRAME, onEnterFrameStarling);
			//Game.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			//Game.stage.addEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, onFullScreen);

			if (hardwareAccelerationEnable)
			{
				Analytics.hardwareAcceleration();
			}
		}

		static public function get hardwareAccelerationEnable():Boolean
		{
			_hardwareAccelerationEnable = Starling.current.context.driverInfo.indexOf('Software') == -1;
			return _hardwareAccelerationEnable;
		}

		static public function get instance():ScreenStarling
		{
			return _instance;
		}

		private function onEnterFrameStarling(event:EnterFrameEvent):void
		{
			FPSCounter.onEnterFrameStarling(event.passedTime);
		}

		/**
		 * get
		 *
		 * @return static groundLayer of ScreenStarling
		 **/
		static public function get groundLayer():Sprite
		{
			return _groundLayer;
		}

		static public function get upLayer():Sprite
		{
			return _upLayer;
		}

		static public function get debugLayer():Sprite
		{
			return _debugLayer;
		}

	}
}