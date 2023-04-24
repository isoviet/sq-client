package loaders
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public class LibLoader extends EventDispatcher
	{
		protected var urlLoader:URLLoader;

		private var loader:Loader;
		private var isTried:Boolean = false;
		private var isTriedNoCache:Boolean = false;
		private var lib:String;

		public var loaded:Boolean = false;

		public function loadURL(lib:String):void
		{
			this.lib = lib;
			var url:String = LoaderManager.getLibUrl(this.lib, LoaderManager.contentType);

			this.urlLoader = new URLLoader();
			this.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			this.urlLoader.addEventListener(Event.COMPLETE, onLoaded);
			this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.urlLoader.load(new URLRequest(url));
		}

		public function loadBytes(dataClass:Class):void
		{
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			context.allowCodeImport = true;
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			this.loader.loadBytes((new dataClass() as ByteArray), context);
		}

		private function onProgress(e:ProgressEvent):void
		{
			dispatchEvent(e);
		}

		public function get totalBytes():int
		{
			return (this.urlLoader == null || this.urlLoader.bytesTotal == 0) ? 2000000 : this.urlLoader.bytesTotal;
		}

		public function get loadedBytes():int
		{
			return (this.urlLoader == null) ? 0 : this.urlLoader.bytesLoaded;
		}

		protected function onLoaded(e:Event):void
		{
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			this.loader.loadBytes((e.currentTarget as URLLoader).data, context);
		}

		protected function onComplete(e:Event):void
		{
			this.loaded = true;
			dispatchEvent(e == null ? new Event(Event.COMPLETE) : e);
		}

		private function onError(e:Event):void
		{
			Logger.add("Loader.onError " + e);

			if (this.isTried || LoaderManager.contentType == LoaderManager.DEFAULT_TYPE)
			{
				if (this.isTriedNoCache)
					PreLoader.sendError(new Error("Can't load Lib " + this.lib + "\n" + this, 404));
				else
				{
					this.isTriedNoCache = true;

					var url:String = LoaderManager.getLibUrl(this.lib, LoaderManager.DEFAULT_TYPE);
					url += "?" + int(Math.random() * 10000);
					this.urlLoader.load(new URLRequest(url));
				}
				return;
			}

			this.isTried = true;

			LoaderManager.failedLibs.push(this.lib);

			url = LoaderManager.getLibUrl(this.lib, LoaderManager.DEFAULT_TYPE);
			this.urlLoader.load(new URLRequest(url));
		}
	}
}