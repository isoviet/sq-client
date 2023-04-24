package game.userInterfaceView.mobile
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;

	CONFIG::mobile{ import flash.display.Screen; }

	public class SplashScreenLoading extends Sprite
	{
		private static var _instance: SplashScreenLoading = null;
		private var _background: Shape = new Shape();
		private var _progressView: MovieClip = new LoadingProgressElement();
		private static var _counterClick: int = 0;

		public function SplashScreenLoading()
		{
			CONFIG::mobile
			{
				this.addChild(_background);
				this.addChild(_progressView);
			}
			this.addEventListener(TouchEvent.TOUCH_END, onClose);
		}

		private function onClose(e: Event): void
		{
			_counterClick++;
			if (_counterClick > 5)
			{
				hide();
				_counterClick = 0;
			}
		}

		public static function getInstance(): SplashScreenLoading
		{
			if (!_instance)
				_instance = new SplashScreenLoading();
			return _instance;
		}

		public static function show(): void
		{
			if (SplashScreenLoading.getInstance().visible != true)
			{
				SplashScreenLoading.getInstance().redraw();
				SplashScreenLoading.getInstance().visible = true;
			}
		}

		public static function hide(): void
		{
			SplashScreenLoading.getInstance().visible = false;
		}

		private function redraw(): void
		{
			CONFIG::mobile
			{
				var thisScreen:Screen = Screen.mainScreen;
				_background.graphics.clear();
				_background.graphics.beginFill(0x0, 0.5);
				_background.graphics.drawRect(
					0, 0, thisScreen.visibleBounds.width * 1.2, thisScreen.visibleBounds.height * 1.2
				);

				_progressView.scaleX = _progressView.scaleY = 6;
				_progressView.x = thisScreen.visibleBounds.width / 2;
				_progressView.y = thisScreen.visibleBounds.height / 2;
			}
		}
	}
}