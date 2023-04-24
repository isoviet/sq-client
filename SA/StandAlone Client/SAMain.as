package 
{
	import by.blooddy.crypto.MD5;
	import by.blooddy.crypto.serialization.JSON;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.fscommand;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	[Frame(factoryClass="Preloader")]
	public class SAMain extends Sprite 
	{
		static public var USER_ID:int;
		static public var SESSION_KEY:String;
		static public var APP_ID:int;
		static public var _instance:SAMain;

		private var loader:Loader = new Loader();
		private var gameList:GameLoader;
		private var loginSprite:LoginSprite = new LoginSprite();
		private var gameSprite:DisplayObject;

		public function SAMain():void 
		{
			_instance = this;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		static public function load(URL:String, appId:int):void
		{
			_instance.loader.unloadAndStop(true);
			APP_ID = appId;

			if (URL != null)
			{
				var context:LoaderContext = new LoaderContext();
				
				context.parameters = new Object();
				context.parameters['userId'] = USER_ID.toString();
				context.parameters['sessionKey'] = SESSION_KEY.toString();
				context.parameters['appId'] = APP_ID.toString();
				context.parameters['api_url'] = SAConfig.API_URL;

				_instance.loader.load(new URLRequest(URL), context);

				_instance.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
				function (e:Event):void
				{
					if (!_instance.loader.content)
						return;

					_instance.gameSprite = _instance.loader.content;
					_instance.stage.addChild(_instance.gameSprite);
				});
				
				_instance.gameList.visible = false;
				_instance.loader.visible = true;
			}
			else 
			{
				_instance.loader.close();
				_instance.loader.visible = false;
				_instance.gameList.visible = true;
				_instance.gameSprite.visible = false;
			}
		}

		static public function execute(method:String, vars:Object, onComplete:Function):void
		{
			_instance.execute(method, vars, onComplete);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			this.loginSprite.x = (760 - this.loginSprite.width) / 2;
			this.loginSprite.y = (600 - this.loginSprite.height) / 2;
			this.loginSprite.addEventListener("LOGIN", onLogin);
			addChild(this.loginSprite);
			
			this.loader.visible = false;
			addChild(this.loader);
			
			this.gameList = new GameLoader();
			this.gameList.visible = false;
			addChild(this.gameList);
		}

		private function onLogin(e:Event):void 
		{
			this.gameList.visible = true;
			this.loginSprite.visible = false;
		}

		private function execute(method:String, vars:Object, onComplete:Function):void
		{
			var variables:URLVariables = new URLVariables();
			for (var key:String in vars)
				variables[key] = vars[key];

			var self:SAMain = this;
			var request:URLRequest = new URLRequest();
			request.url = SAConfig.API_URL;
			request.method = URLRequestMethod.GET;
			request.data = variables;
			request.data['method'] = method;
			request.data['time'] = new Date().toString();

			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;

			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
			{
				self.onError(new Error(e.text));
			});
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void
			{
				self.onError(new Error(e.text));
			});
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				var data:Object;

				try
				{
					data = JSON.decode(e.currentTarget.data);
				}
				catch (error:Error)
				{
					self.onError(error);
				}

				if ("error" in data)
					onError(data);
				else if (onComplete != null)
					onComplete(data);
			});

			for (var tries:int = 3; tries != 0; tries--)
			{
				try
				{
					loader.load(request);
					return;
				}
				catch (error:Error)
				{
					self.onError(error);
				}
			}
		}

		private function onError(error:Object):void
		{

		}	
		
	}

}