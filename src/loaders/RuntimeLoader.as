package loaders
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	public class RuntimeLoader extends EventDispatcher
	{
		CONFIG::inner
		{
			[Embed(source = "../../content/clothesHero40.swf", mimeType = "application/octet-stream")]
			static private const CLOTHES_HERO_LIB:Class;

			[Embed(source = "../../content/runtime122.swf", mimeType = "application/octet-stream")]
			static private const RUNTIME_LIB:Class;

			[Embed(source = "../../content/clothes100.swf", mimeType = "application/octet-stream")]
			static private const CLOTHES_LIB:Class;

			static private const LIBS:Array = [RUNTIME_LIB, CLOTHES_HERO_LIB, CLOTHES_LIB];
		}
		CONFIG::external
		{
			static private const CLOTHES_HERO_LIB:String = "clothesHero";

			static private const CLOTHES_LIB:String = "clothes";

			static private const LIBS:Array =["runtime", CLOTHES_HERO_LIB, CLOTHES_LIB];
		}

		static private var _instance:RuntimeLoader = null;

		private var libLoaders:Vector.<LibLoader> = new Vector.<LibLoader>();
		private var callbacks:Array = [];

		private var loading:Boolean = false;
		private var loaded:Boolean = false;
		private var waitingMovie:Sprite = null;

		public function RuntimeLoader():void
		{
			_instance = this;
		}

		static public function loadLib(callback:Function = null):void
		{
			if (_instance.loaded)
				return;

			_instance.load(callback);
		}

		static public function load(callback:Function = null, toLocation:Boolean = false):void
		{
			if (_instance.loaded)
			{
				callback();
				return;
			}
			if (!_instance.waitingMovie && !toLocation)
			{
				_instance.waitingMovie = new Sprite();
				_instance.waitingMovie.addChild(new MovieWaitingContent()).filters = [new GlowFilter(0xFFFFFF, 1, 7, 7, 8)];;
				var field:GameField = new GameField(gls("Подожди\nИдёт загрузка библиотеки..."), -90, -7, new TextFormat(GameField.PLAKAT_FONT, 14, 0x867754, null, null, null, null, null, "center"), 275);
				_instance.waitingMovie.addChild(field);
				_instance.waitingMovie.x = int(Config.GAME_WIDTH * 0.5);
				_instance.waitingMovie.y = int(Config.GAME_HEIGHT * 0.5);
				_instance.waitingMovie.graphics.beginFill(0x000000, 0.2);
				_instance.waitingMovie.graphics.drawRect(-_instance.waitingMovie.x, -_instance.waitingMovie.y, Config.GAME_WIDTH, Config.GAME_HEIGHT);
				Game.gameSprite.addChild(_instance.waitingMovie);
			}

			_instance.load(callback);
		}

		static public function get loaded():Boolean
		{
			return _instance.loaded;
		}

		static public function listen(event:String, completeFunction:Function):void
		{
			if (_instance.loaded)
				return;

			_instance.addEventListener(event, completeFunction);
		}

		static public function removeListen(event:String, completeFunction:Function):void
		{
			if (_instance.loaded)
				return;

			_instance.removeEventListener(event, completeFunction);
		}

		static public function get totalBytes():int
		{
			var total:int = 0;
			for each (var loader:LibLoader in _instance.libLoaders)
				total += loader.totalBytes;

			return total;
		}

		static public function get loadedBytes():int
		{
			var loaded:int = 0;
			for each (var loader:LibLoader in _instance.libLoaders)
				loaded += loader.loadedBytes;

			return loaded;
		}

		private function onProgress(e:Event):void
		{
			dispatchEvent(e);
		}

		private function onLoaded(e:Event):void
		{
			for each (var loader:LibLoader in this.libLoaders)
			{
				if (!loader.loaded)
					return;
			}

			Logger.add("RuntimeLoader - onLoaded");

			this.loaded = true;

			if (this.waitingMovie != null)
			{
				Game.gameSprite.removeChild(this.waitingMovie);
				this.waitingMovie = null;
			}

			Game.onRuntimeLoaded();

			doCallbacks();

			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function doCallbacks():void
		{

			for (var i:int = 0; i < this.callbacks.length; i++)
				this.callbacks[i]();

			this.callbacks = [];
		}

		private function load(callback:Function):void
		{
			if (callback != null)
				this.callbacks.push(callback);

			if (this.loading)
				return;

			this.loading = true;

			if (this.loaded)
			{
				doCallbacks();
				return;
			}

			for each(var item:* in RuntimeLoader.LIBS)
			{
				if (item == CLOTHES_HERO_LIB)
					var loader:LibLoader = new ClothesLoader();
				else
					loader = new LibLoader();

				loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.addEventListener(Event.COMPLETE, onLoaded);
				if (item is String)
					loader.loadURL(item);
				else
					loader.loadBytes(item);
				this.libLoaders.push(loader);
			}
		}
	}
}