package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	import loaders.LoaderManager;
	import loaders.LocaleLoader;
	import sounds.SoundsBase;

	import utils.LoaderUtil;

	import fl.containers.ScrollPane;

	public class PreLoader extends MovieClip
	{
		static private const SKIP_ERRORS:Array = [0, 2002, 666].concat([3694, 3692, 3691, 3675, 3672]);
		static private const SHOW_ALWAYS_ERRORS:Array = [754];
		static private const MAX_ERROR_COUNT:int = 0;

		static private var _instance:PreLoader = null;
		static private var canShow:Boolean = false;

		static public var session:Object;

		private var loaderManager:LoaderManager;
		private var game:LoaderInfo;
		private var gameLoaded:Boolean = false;
		private var errorsCount:int = 0;

		private var movie:Sprite = null;
		private var imageBar:Sprite = null;
		private var fieldStatus:GameField = null;
		private var fieldProgress:GameField = null;
	
		private var debugField:TextField = new TextField();
		private var debugPane:ScrollPane = new ScrollPane();
		private var debugSprite:Sprite = new Sprite();

		private var playInvoked:Boolean = false;

		private var shadow:Sprite = null;

		public function PreLoader():void
		{
			_instance = this;

			Logger.add("Running client version " + Config.VERSION_MAJOR + "." + Config.VERSION_MINOR);

			super();
			stop();

			if (Config.CONFIG_URL[loaderInfo.parameters['useLocale']])
				Config.LOCALE = loaderInfo.parameters['useLocale'];

			if ('config' in loaderInfo.parameters)
				Config.CONFIG_URL[Config.LOCALE] = loaderInfo.parameters['config'];

			if ('protocol' in loaderInfo.parameters)
				Config.PROTOCOL = loaderInfo.parameters['protocol'];

			PreLoader.setContextMenu(this);

			this.loaderInfo.addEventListener(Event.INIT, init);
		}

		static public function get loaderInfo():LoaderInfo
		{
			return _instance.loaderInfo;
		}

		static public function get isShowing():Boolean
		{
			return (_instance.parent != null);
		}

		static public function hide():void
		{
			if (_instance.parent == null)
				return;
			_instance.parent.removeChild(_instance);

			if (_instance.movie != null)
				_instance.removeChild(_instance.movie);
			_instance.movie = null;
		}

		static public function setStatus(status:String):void
		{
			_instance.setStatus(status);
		}

		static public function showDebug(force:Boolean = false):void
		{
			if (!canShow && !force)
				return;
			canShow = true;

			_instance.showDebug();
		}

		static public function setContextMenu(container:DisplayObjectContainer):void
		{
		        CONFIG::mobile{return;}

			var item1:ContextMenuItem = new ContextMenuItem(LocaleLoader.gls("Трагедия белок!"), false, false);
			var item2:ContextMenuItem = new ContextMenuItem(LocaleLoader.gls("Версия {0}.{1}", Config.VERSION_MAJOR, Config.VERSION_MINOR), false, false);

			var myContextMenu:ContextMenu = new ContextMenu();
			myContextMenu.hideBuiltInItems();
			myContextMenu.customItems.push(item1, item2);

			container.contextMenu = myContextMenu;
		}

		static public function sendError(e:Error):void
		{
			_instance.onUncaughtError(new UncaughtErrorEvent(UncaughtErrorEvent.UNCAUGHT_ERROR, true, true, e));
		}

		static public function getLogo():DisplayObject
		{
			switch(Config.LOCALE)
			{
				case Config.EN_LOCALE:
					return new ImageLogoEn();
				default:
					return new ImageLogoRu();
			}
		}

		static private function getBack():MovieClip
		{
			switch(Config.LOCALE)
			{
				case Config.EN_LOCALE:
					return new ImagePreloaderBackEn();
				default:
					return new ImagePreloaderBackRu();
			}
		}

		static private function traceSession():void
		{
			Logger.add("sessionVars:");
			for (var index:String in PreLoader.session)
				Logger.add(index + ": \"" + PreLoader.session[index] + "\"" + ",");
		}

		private function init(e:Event):void
		{
			this.loaderInfo.removeEventListener(Event.INIT, init);

			if (!this.stage)
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
				return;
			}
			removeEventListener(Event.ADDED_TO_STAGE, init);

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.stageFocusRect = false;
			this.stage.tabChildren = false;
			this.stage.showDefaultContextMenu = false;

			LoaderUtil.load(Config.CONFIG_URL[Config.LOCALE] + "?" + Math.random(), false, null, onConfigLoad, function(e:Event):void
			{
				Logger.add("Can't load config from " + Config.CONFIG_URL[Config.LOCALE]);
			});

			this.movie = new PreLoaderBackGround();
			addChild(this.movie);

			var image:MovieClip = getBack();
			image.x = int((Config.GAME_WIDTH - image.width) * 0.5);
			image.y = 20;
			addChild(image);

			this.imageBar = image['imageBar'];

			Font.registerFont(FontDroidSans);
			Font.registerFont(FontDroidSansBold);
			Font.registerFont(FontAPlakatTitul);

			this.fieldStatus = new GameField("", 0, 590, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFFFFF, null, null, null, null, null, "center"));
			this.fieldStatus.filters = [new DropShadowFilter()];
			setStatus(LocaleLoader.gls("Выполняется загрузка приложения"), false);
			addChild(this.fieldStatus);
			
			this.debugSprite.graphics.beginFill(0xFFFFFF);
			this.debugSprite.graphics.drawRect(0, 0, 870, 500);
			this.debugSprite.visible = false;

			this.debugField.width = 250;
			this.debugField.multiline = true;
			this.debugField.wordWrap = false;
			this.debugField.mouseWheelEnabled = false;
			this.debugField.autoSize = TextFieldAutoSize.LEFT;
			this.debugField.embedFonts = true;
			this.debugField.defaultTextFormat = new TextFormat(GameField.DEFAULT_FONT, 12);
			this.debugSprite.addChild(this.debugField);

			this.debugPane.x = 15;
			this.debugPane.y = 15;
			this.debugPane.setSize(870, 500);
			this.debugPane.source = this.debugSprite;
			this.debugPane.visible = false;
			addChild(this.debugPane);

			this.fieldProgress = new GameField("", this.imageBar.x, this.imageBar.y - 14, new TextFormat(GameField.DEFAULT_FONT, 20, 0x481225, true, null, null, null, null, "center"), this.imageBar.width);
			this.fieldProgress.filters = [new GlowFilter(0xFFBE70, 1.0, 2, 2)];
			image.addChild(this.fieldProgress);

			this.shadow = new Sprite();
			this.shadow.graphics.beginFill(0x00000, 1.0);
			this.shadow.graphics.drawRect(0, -this.imageBar.height * 0.5, this.imageBar.width, this.imageBar.height);
			this.shadow.x = -this.imageBar.width;
			this.imageBar.mask = this.shadow;
			this.imageBar.addChild(this.shadow);
		}

		private function onConfigLoad(e:Event):void
		{
			Config.load(new XML(e.currentTarget.data));

			PreLoader.session = this.stage.loaderInfo.parameters as Object;

			this.loaderManager = new LoaderManager();
			this.loaderManager.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.loaderManager.loadLibs();

			this.loaderManager.loadConfig(Config.SOUNDS_CONFIG_URL, function callback(data:XML=null):void
			{
				SoundsBase.config = data;
			}, "sounds", true);

			this.loaderManager.loadConfig(Config.SOUNDS_CONFIG_URL, function callback(data:XML=null):void
			{
				SoundsBase.config = data;
			}, "sounds", true);

			this.game = this.loaderInfo;
			this.game.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.game.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.game.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.game.addEventListener(Event.COMPLETE, gameComplete);

			this.gameLoaded = (this.game.bytesLoaded == this.game.bytesTotal);

			this.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onError(e:Event):void
		{
			trace(e);
		}

		private function setStatus(status:String, log:Boolean = true):void
		{
			if (log)
				trace(status);

			this.fieldStatus.text = status;
			this.fieldStatus.x = int((Config.GAME_WIDTH - this.fieldStatus.textWidth) * 0.5);
			this.fieldStatus.y = 590 - int(this.fieldStatus.textHeight * 0.5);
		}

		private function showDebug():void
		{
			this.debugField.text = Logger.getMessages(500);
			this.debugField.height = this.debugField.textHeight + 20;

			this.debugSprite.visible = true;

			this.debugPane.visible = true;
			this.debugPane.update();
		}

		private function onProgress(e:ProgressEvent):void
		{
			var loaded:Number = this.game.bytesLoaded + this.loaderManager.loadedBytes;
			var total:Number = this.game.bytesTotal + this.loaderManager.totalBytes;

			if (total == 0)
				return;

			drawProcess(loaded / total);
		}

		private function drawProcess(percent:Number):void
		{
			if (percent > 1)
				percent = 1;

			setStatus(LocaleLoader.gls("Выполняется загрузка приложения"), false);

			this.fieldProgress.text = int(percent * 100).toString() + "%";
			this.shadow.x = int((percent - 1) * this.shadow.width);
		}

		private function gameComplete(e:Event):void
		{
			this.game.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			this.game.removeEventListener(Event.COMPLETE, gameComplete);

			this.gameLoaded = true;
		}

		private function onEnterFrame(e:Event):void
		{
			if (this.loaderManager && this.loaderManager.loaded && !this.playInvoked)
			{
				this.playInvoked = true;

				play();
				return;
			}

			if (!this.gameLoaded || !this.playInvoked)
				return;

			if(this.game.uncaughtErrorEvents)
				this.game.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

			stop();
			drawProcess(1);

			var main:Class = this.game.applicationDomain.getDefinition("Main") as Class;

			this.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.stage.addChild(new main());

			traceSession();
		}

		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			e.preventDefault();

			if (!e.error.getStackTrace() && e.errorID != 999)
				return;

			for each (var skipError:int in SKIP_ERRORS)
			{
				if (e.error.errorID == skipError)
					return;
			}

			var message:String = e + "\n" + e.error + "\n" + e.error.getStackTrace();
			Logger.add(message);

			if (!Config.DEBUG && SHOW_ALWAYS_ERRORS.indexOf(e.error.errorID) == -1)
				return;

			try
			{
				var gameClass:Class = loaderInfo.applicationDomain.getDefinition("Game") as Class;

				this.errorsCount++;

				var variables:URLVariables = new URLVariables();
				variables['errno'] = -(e.error.errorID * 10000 + Config.VERSION_MINOR);
				variables['uid'] = gameClass.selfId;
				variables['message'] = Logger.getMessages();

				var request:URLRequest = new URLRequest();
				request.url = Config.ERRORS_URL;
				request.method = URLRequestMethod.POST;
				request.data = variables;

				var loader:URLLoader = new URLLoader();
				loader.load(request);
			}
			catch (error:Error)
			{}
			finally
			{
				if (this.errorsCount > PreLoader.MAX_ERROR_COUNT)
					this.game.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			}
		}
	}
}