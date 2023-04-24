package game.userInterfaceView.mobile
{
	import flash.display.Sprite;

	import com.greensock.TweenMax;

	CONFIG::mobile{ import flash.display.Screen; }
	import flash.display.Shape;

	public class SidebarsView extends Sprite
	{
		public static const SCREEN_NAME_AUTH: String = 'auth';
		public static const SCREEN_NAME_LOADER: String = 'loader';
		public static const SCREEN_NAME_DEFAULT: String = 'default';
		public static const SCREEN_NAME_LOCATION: String = 'screens::ScreenLocation';
		public static const SCREEN_NAME_GAME: String = 'screens::ScreenGame';
		public static const SCREEN_NAME_LEARNING: String = 'screens::ScreenLearning';
		public static const SCREEN_NAME_SCHOOL: String = 'screens::ScreenSchool';

		private const COLOR_MAIN_MENU: uint = 0x005BA8;
		private const COLOR_LOAD: uint = 0x68BDEF;
		private const COLOR_SCREENS: uint = 0xF6F0DD;
		private const COLOR_GAME: uint = 0x68BDEF;

		private static var _instance: SidebarsView = null;

		private static const SCREENS_COLOR: Object = {
			'auth': {'visible': false},
			'loader': {'left': 0x68BDEF, 'right': 0x68BDEF},
			'default': {'left': 0xF6F0DD, 'right': 0xF6F0DD},
			'dialog::DialogShop': {'left': 0x005BA8, 'right': 0x005BA8},
			'screens::ScreenLocation': {'left': 0x005BA8, 'right': 0x005BA8},
			'screens::ScreenGame': {'visible': false},
			'screens::ScreenLearning': {'visible': false},
			'screens::ScreenSchool': {'visible': false}
		};

		private var _leftBar: Sprite = new Sprite();
		private var _rightBar: Sprite = new Sprite();

		private var sizeWidth: Number = 0;
		private var sizeHeight: Number = 0;

		private var _lastBarColor: uint = 0;

		public function SidebarsView()
		{
			addChild(_leftBar);
			addChild(_rightBar);
		}

		public static function getInstance(): SidebarsView
		{
			if (!_instance)
				_instance = new SidebarsView();
			return _instance;
		}

		public function drawBars(screen: String = null): void
		{
			if (!SCREENS_COLOR[screen])
				screen = SCREEN_NAME_DEFAULT;

			this.alpha = 1;

			if (screen == SCREEN_NAME_LOADER)
				this.alpha = 0.8;

			CONFIG::mobile{
				var thisScreen:Screen = Screen.mainScreen;
				var newScaleX:Number = thisScreen.visibleBounds.width / Config.GAME_WIDTH;
				var newScaleY:Number = thisScreen.visibleBounds.height / Config.GAME_HEIGHT;
				var newScale:Number = Math.min(newScaleX, newScaleY);
				sizeWidth = (thisScreen.visibleBounds.width - Config.GAME_WIDTH * newScale) / 2 + 4;
				sizeHeight = thisScreen.visibleBounds.height;

				_leftBar.graphics.clear();
				_rightBar.graphics.clear();

				if (screen != SCREEN_NAME_DEFAULT && SCREENS_COLOR[screen].hasOwnProperty('visible')
					&& SCREENS_COLOR[screen].visible == false)
					return;

				_leftBar.graphics.beginFill(uint(SCREENS_COLOR[screen].left));
				_leftBar.graphics.drawRect(0, 0, sizeWidth, sizeHeight);
				_leftBar.graphics.endFill();

				_rightBar.graphics.beginFill(uint(SCREENS_COLOR[screen].right));
				_rightBar.graphics.drawRect(0, 0, sizeWidth, sizeHeight);
				_rightBar.graphics.endFill();
				_rightBar.x = thisScreen.visibleBounds.width - _rightBar.width;
			}
		}

		public function refreshColorBarsLocations(color: uint): void
		{
			_lastBarColor = 0;
			drawBarsLocations(color);
		}

		public function drawBarsLocations(color: uint): void
		{
			if (_lastBarColor != color)
			{
				this._leftBar.graphics.clear();
				this._rightBar.graphics.clear();
				this._leftBar.graphics.beginFill(color);
				this._leftBar.graphics.drawRect(0, 0, sizeWidth, sizeHeight);
				this._leftBar.graphics.endFill();

				this._rightBar.graphics.beginFill(color);
				this._rightBar.graphics.drawRect(0, 0, sizeWidth, sizeHeight);
				this._rightBar.graphics.endFill();

			//	TweenMax.to(this._leftBar, 1, {'tint': color});
			//	TweenMax.to(this._rightBar, 1, {'tint': color});
				_lastBarColor = color;
			}
		}
	}
}