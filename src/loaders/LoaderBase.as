package loaders
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;

	public class LoaderBase
	{
		protected var loader:Loader = null;
		protected var callbacks:Array = [];
		protected var loading:Boolean = false;

		public var loaded:Boolean = false;

		protected function load(lib:*, callback:Function = null):void
		{
			if (callback != null)
				this.callbacks.push(callback);

			if (this.loaded)
			{
				doCallbacks();
				return;
			}

			if (this.loading)
				return;
			this.loading = true;

			var loader:LibLoader = new LibLoader();
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(Event.COMPLETE, onLoaded);
			CONFIG::external {
				loader.loadURL(lib);
			}
			CONFIG::inner {
				loader.loadBytes(lib);
			}
		}

		protected function onProgress(e:Event):void
		{}

		protected function onDebug():void
		{}

		protected function onLoaded(e:Event):void
		{}

		protected function doCallbacks():void
		{
			for (var i:int = 0; i < this.callbacks.length; i++)
				this.callbacks[i]();

			this.callbacks = [];
		}
	}
}