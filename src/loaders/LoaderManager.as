package loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;

	import utils.LoaderUtil;

	public class LoaderManager extends EventDispatcher
	{
		CONFIG::inner
		{
			[Embed(source = "../../content/base273.swf", mimeType = "application/octet-stream")]
			static private const BASE_LIB:Class;

			[Embed(source = "../../content/offers37.swf", mimeType = "application/octet-stream")]
			static private const OFFERS_LIB:Class;

			[Embed(source = "../../content/hero19.swf", mimeType = "application/octet-stream")]
			static private const HERO_LIB:Class;

			[Embed(source = "../../content/en/en.lp", mimeType = "application/octet-stream")]
			static private const LANG_PACK:Class;

			[Embed(source = "../../content/news46.swf", mimeType = "application/octet-stream")]
			static private var NEWS:Class;

			static private const LIBS:Array = [BASE_LIB, OFFERS_LIB, HERO_LIB, LANG_PACK, NEWS];
		}
		CONFIG::external
		{
			static private const HERO_LIB:String = "hero";
			static private const LANG_PACK:String = "lang";

			static private const LIBS:Array = ["base", "offers", "news", HERO_LIB, LANG_PACK];
		}

		static public const DEFAULT_TYPE:String = "default";

		static public var contentConfig:XML = null;
		static public var contentType:String = "default";


		static public var failedLibs:Array = [];

		private var _stackLoader:Vector.<Object> = new Vector.<Object>();

		private var libLoaders:Vector.<LibLoader> = new Vector.<LibLoader>();

		private var configLoaded:Boolean = false;


		public function LoaderManager():void
		{}

		static public function getLibUrl(lib:String, type:String):String
		{
			return Config.PROTOCOL + String(LoaderManager.contentConfig[type][lib]);
		}

		public function loadLibs():void
		{
			CONFIG::external
			{
				LoaderUtil.load(Config.CONTENT_URL + "?" + Math.random(), false, null, onConfigLoad, function(e:Event):void
				{
					Logger.add("Can't load content config from " + Config.CONTENT_URL);
				});
			}
			CONFIG::inner
			{
				this.configLoaded = true;
				load();
			}
		}

		public function get totalBytes():int
		{
			var total:int = 0;
			for each (var loader:LibLoader in this.libLoaders)
				total += loader.totalBytes;
			return total;
		}

		public function get loadedBytes():int
		{
			var loaded:int = 0;
			for each (var loader:LibLoader in this.libLoaders)
				loaded += loader.loadedBytes;


			return loaded;
		}

		public function get loaded():Boolean
		{

			if (!this.configLoaded || _stackLoader.length > 0)
				return false;

			for each (var loader:LibLoader in this.libLoaders)
				if (!loader.loaded)
					return false;

			return true;
		}

		private function onConfigLoad(e:Event):void
		{
			var config:XML = new XML(e.currentTarget.data);
			load(config);

			this.configLoaded = true;
		}

		private function onProgress(e:ProgressEvent):void
		{
			dispatchEvent(e);
		}

		private function load(data:XML = null):void
		{
			if (data != null)
			{
				var session:Object = PreLoader.loaderInfo.parameters as Object;

				var socialType:String;
				if ("useApiType" in session)
					socialType = session['useApiType'];
				else if ("useapitype" in session)
					socialType = session['useapitype'];
				else
					socialType = Config.DEFAULT_API;

				LoaderManager.contentType = ((socialType == "vk" && !("OAuth" in session)) ? "vk" : "default");
				LoaderManager.contentConfig = data;
			}

			for each(var item:* in LoaderManager.LIBS)
			{
				switch(item)
				{
					case HERO_LIB:
						var loader:LibLoader = new HeroLoader();
						break;
					case LANG_PACK:
						if (Config.isRus)
							continue;
						loader = new LocaleLoader();
						break;
					default:
						loader = new LibLoader();
				}

				loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				if (item is String)
					loader.loadURL(item);
				else
					loader.loadBytes(item);
				this.libLoaders.push(loader);
			}
		}

		public function loadConfig(url:String, callback:Function, name:String, safe:Boolean=false):void
		{
			_stackLoader.push({ callback:callback, safe:safe, name:name, loader:
				LoaderUtil.load(url + "?" + Math.random(), false, null, _onStackLoader,
					//error
				function(e:Event):void
				{
					_onStackLoader(e, true);
				})
			});

		}
		private function _onStackLoader(e:Event, error:Boolean=false):void
		{
			var loader:URLLoader = e.target as URLLoader;

			for each(var loaderData:Object in _stackLoader)
				if(loaderData.loader == loader)
				{
					if(loaderData.safe == true || error == false)
					{
						_stackLoader.splice(_stackLoader.indexOf(loaderData), 1);
						loader = null;
					}

					if(error)
					{
						Logger.add("Can't load config from " + loaderData.name + "!");
						loaderData.callback(null);
					}
					else
						loaderData.callback(new XML(e.currentTarget.data));
				}

		}
	}
}