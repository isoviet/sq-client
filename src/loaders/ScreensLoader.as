package loaders
{
	import flash.events.Event;
	import flash.events.ProgressEvent;

	import screens.Screen;
	import screens.Screens;
	import views.LoadGameAnimation;

	public class ScreensLoader extends LoaderBase
	{
		CONFIG::inner
		{
			[Embed(source = "../../content/screens67.swf", mimeType = "application/octet-stream")]
			static private var SCREENS:Class;
		}
		CONFIG::external
		{
			static private const SCREENS:String = "screens";
		}

		static private var _instance:ScreensLoader = null;

		private var screen:Screen = null;
		private var screensLoaded:Boolean = false;

		public function ScreensLoader():void
		{
			_instance = this;
		}

		static public function clearCallback():void
		{
			_instance.callbacks = [];
		}

		static public function load(screen:Screen, callback:Function = null):void
		{
			_instance.screen = screen;
			_instance.loadScreens(callback);
			_instance.loadScreens(function():void
			{
				Screens.show(screen);
			});

			if (loaded)
				return;

			LoadGameAnimation.instance.close();
			RuntimeLoader.listen(Event.COMPLETE, _instance.onRuntimeLoaded);
			RuntimeLoader.listen(ProgressEvent.PROGRESS, _instance.onProgress);
		}

		static public function get loaded():Boolean
		{
			return _instance.loaded;
		}

		override protected function onProgress(e:Event):void
		{}

		override protected function onLoaded(e:Event):void
		{
			super.onLoaded(e);

			this.screensLoaded = true;

			Logger.add("ScreensLoader - onLoaded");

			if (!RuntimeLoader.loaded)
				return;

			onAllLoaded();
		}

		private function onRuntimeLoaded(e:Event):void
		{
			if (!this.screensLoaded)
				return;

			onAllLoaded();
		}

		private function onAllLoaded():void
		{
			super.loaded = true;

			LoadGameAnimation.instance.open(function():void
			{
				if (Screens.active == screen)
					screen.firstShow();
				doCallbacks();
			});
		}

		private function loadScreens(callback:Function = null):void
		{
			super.load(SCREENS, callback);
		}
	}
}