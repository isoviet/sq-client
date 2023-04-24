package loaders
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class PreviewLoader
	{
		static private var loading:Object = {};
		static private var loaded:Object = {};

		static public function load(name:String, callback:Function = null):void
		{
			if (name in loaded)
			{
				callback(name);
				return;
			}

			if (name in loading)
				return;
			loading[name] = true;

			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					callback(name);
					loaded[name] = true;
				});
				loader.loadBytes((e.currentTarget as URLLoader).data, context);
			});
			loader.load(new URLRequest(Config.PREVIEWS_URL + name + ".swf"));
		}
	}
}