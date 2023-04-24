package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;

	import by.blooddy.crypto.MD5;
	import by.blooddy.crypto.image.PNGEncoder;
	import by.blooddy.crypto.serialization.JSON;

	import com.sa.LoginSprite;
	import com.sa.OAuth;
	import com.sa.Services;
	import com.sa.Processor;

	public class Main extends Sprite
	{
		static public var isRus:Boolean = true;
		static public var promo:String = "";

		static public var _instance:Main;
		static public var socialType:String = "";
		static public var socialUrl:String = "";
		static public var oAuthCode:String = "";
		static private var isEval:Boolean = false;

		private var loader:URLLoader;

		static public var loadingSprite:Sprite = new Sprite();
		public var loginSprite:DisplayObject;

		public function Main()
		{
			_instance = this;

			Security.allowDomain("*");

			if (loaderInfo.parameters['lang'] == "en")
				isRus = false;
			if ('promo' in loaderInfo.parameters)
				promo = "&promo" + loaderInfo.parameters['promo'];

			new Services();

			addChild(new LoaderBackground);

			this.loginSprite = new LoginSprite();
			this.loginSprite.x = 165;
			this.loginSprite.y = 105;
			addChild(this.loginSprite);

			loadingSprite.graphics.beginFill(0x000000, 0.5);
			loadingSprite.graphics.drawRect(0, 0, 900, 620);
			var loadingMovie:MovieClip = isRus ? new LoaderRu : new LoaderEn;
			loadingMovie.x = int((loadingSprite.width - loadingMovie.width) * 0.5) + 15;
			loadingMovie.y = int((loadingSprite.height - loadingMovie.height) * 0.5);
			loadingSprite.addChild(loadingMovie);
			loadingSprite.visible = false;
			addChild(loadingSprite);

			ExternalInterface.call("SetSkin", Config.skinEncoded);

			if (this.stage == null)
				return;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
		}

		static public function onLogin():void
		{
			Processor.execute("setUserInfo", {'fName': Main.isRus ? "Белочка" : "Little Squirrel", 'sName': "", 'photoUrl': "", 'gender': 1, 'birthDate': 0}, onInfoSaved);
			//var dialog:DisplayObject = new EditSprite;
			//dialog.x = (900 - dialog.width) * 0.5;
			//dialog.y = _instance.loginSprite.y;
			//_instance.addChild(dialog);
		}

		static public function onInfoSaved(data:*):void
		{
			Main.start();
		}

		static public function start(e:Event = null):void
		{
			_instance.loginSprite.visible = true;
			_instance.loader = new URLLoader();
			_instance.loader.addEventListener(Event.COMPLETE, _instance.onVersionLoaded);
			_instance.loader.load(new URLRequest((isRus ? Config.VERSION_URL_RU : Config.VERSION_URL_EN) + "?time=" + new Date().time));
			_instance.loader.dataFormat = URLLoaderDataFormat.TEXT;
		}

		private function onVersionLoaded(e:Event):void
		{
			var pngImage:ByteArray = PNGEncoder.encode(new BitmapData(10, 10, true));
			pngImage.position = 0;

			var versionSource:String = this.loader.data as String;
			var version:String;

			version = parseVersion(versionSource);

			if (version == "")
				return;

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			load((isRus ? Config.SWF_PATH_RU : Config.SWF_PATH_EN) + version + ".swf");
		}

		private function load(swfURL:String):void
		{
			if (!ExternalInterface.available)
				return;

			var session:Object = this.stage.loaderInfo.parameters;
			for (var param:String in session)
			{
				if (param.indexOf('#') == -1)
					continue;
				Config.VARS += "&ref=" + param.split('#')[1];
			}

			if (!isRus)
				Config.VARS += "&useLocale=en";
			Config.VARS += promo;

			ExternalInterface.call("LoadSwf", swfURL, Config.VARS);
		}

		static public function initAuth():void
		{
			if (isEval)
				return;
			isEval = true;
			var script:String = "" +
				'var wait = "";' +
				'var w = null;' +
				'var showUrl = "";' +
				'function openWindow(url, waitFor)' +
				'{' +
					'showUrl = url;' +
					'wait = waitFor;' +
					'window.location.hash = "";' +
					'delete window.localStorage.authResult;' +

					'show(url);' +
				'}' +

				'function showAndHide()' +
				'{' +
					'show(showUrl);' +
				'}' +

				'function show(url)' +
				'{' +
					'w = window.open(url);' +
					'if (w != null && !w.closed)' +
						'setTimeout(check, 1000);' +
				'}' +

				'function check()' +
				'{' +
					'if (w == null || w.closed || window.localStorage.authResult || window.location.hash != "")' +
					'{' +

						'if (window.localStorage.authResult)' +
			 				'sendResult(-1, wait + window.localStorage.authResult);' +
						'else ' +
							'sendResult(-1, wait + window.location.hash);' +
					'}' +
					'else ' +
						'setTimeout(check, 1000);' +
				'}' +

				'function sendResult(resultCode, result)' +
				'{' +
					'var r = \'{"resultCode":\' + resultCode + \', "result":"\' + result +\'"}\';' +
					'var obj = swfobject.getObjectById("flash-app");' +
					'obj.callback(r);' +
					'wait = "";' +
					'window.location.hash = "";' +
					'delete window.localStorage.authResult; ' +
				'}';

			ExternalInterface.addCallback("callback", _instance.callback);
			ExternalInterface.call("eval", script);
		}

		private function callback(data:Object):void
		{
			try
			{
				var result:Array = (by.blooddy.crypto.serialization.JSON.decode(data as String)['result'] as String).split('#')[1].split("&");
			}
			catch(e:Error)
			{
				socialType = "";
				return;
			}

			var params:Object = new Object();
			for (var i:int = 0; i < result.length; i++)
			{
				var param:Array = result[i].split('=');
				params[param[0] as String] = param[1];
			}

			if ("error" in params)
			{
				socialType = "";
				return;
			}

			oAuthCode = params[socialType == "FB" ? 'access_token' : 'code'];
			var request:URLRequest = new URLRequest(Services.oauthUrl + "?type=" + socialType.toLowerCase() + "&code=" + oAuthCode + "&redirect_uri=" + Config.REDIRECT_URL);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onSocAuth);
			urlLoader.load(request);
		}

		private function onSocAuth(e:Event):void
		{
			var data:Object = by.blooddy.crypto.serialization.JSON.decode(e.currentTarget.data);
			var url:String = "";

			switch (socialType)
			{
				case "VK":
					Config.VARS = "useApiType=vk";
					Config.VARS += "&viewer_id=" + data['net_id'];
					Config.VARS += "&access_token=" + data['access_token'];
					Config.VARS += "&api_url=https://api.vk.com/method/";
					Config.VARS += "&auth_key=";
					Config.VARS += "&token=" + data['token'];
					Config.VARS += "&userId=" + data['net_id'];
					//Config.VARS += "&forceDirectApiAccess=true";
					Config.VARS += "&net_type=0";

					url = "https://api.vk.com/method/users.get?fields=photo_50&uid=" + data['net_id'] + "&access_token=" + data['access_token'] + "&v=5.92";
					break;
				case "OK":
					Config.VARS = "useApiType=ok";
					Config.VARS += "&logged_user_id=" + data['net_id'];
					Config.VARS += "&access_token=" + data['access_token'];
					Config.VARS += "&application_key=" + Config.OK_APP_KEY;
					Config.VARS += "&session_secret_key=" + data['inner_sig'];
					Config.VARS += "&session_key=" + data['access_token'];
					Config.VARS += "&auth_sig=" + data['sig'];
					Config.VARS += "&api_server=http://api.odnoklassniki.ru/";
					Config.VARS += "&token=" + data['token'];
					Config.VARS += "&userId=" + data['net_id'];
					Config.VARS += "&net_type=4";

					var params:Object = new Object();
					params['application_key'] = Config.OK_APP_KEY;
					params['format'] = "JSON";
					params['method'] = "users.getCurrentUser";
					var sig:String = getParams(params);
					url = "https://api.ok.ru/fb.do?access_token=" + data['access_token'];
					url += getUrl(params);
					url += "&sig=" + by.blooddy.crypto.MD5.hash(sig + data['inner_sig']);
					break;
				case "FB":
					Config.VARS = "useApiType=fb";
					Config.VARS += "&access_token=" + data['code'];
					Config.VARS += "&app_id=" + (Main.isRus ? Config.FB_APP_ID_RU : Config.FB_APP_ID_EN);
					Config.VARS += "&uid=" + data['net_id'];
					Config.VARS += "&token=" + data['token'];
					Config.VARS += "&userId=" + data['net_id'];
					Config.VARS += "&net_type=5";

					url = "https://graph.facebook.com/me?fields=picture,name&access_token=" + data['code'];
					break;
				case "MM":
					Config.VARS = "useApiType=mm";
					Config.VARS += "&vid=" + data['net_id'];
					Config.VARS += "&access_token=" + data['access_token'];
					Config.VARS += "&app_id=" + Config.MM_APP_ID;
					Config.VARS += "&app_secret=" + Config.MM_APP_KEY;
					Config.VARS += "&authentication_key=";
					Config.VARS += "&token=" + data['token'];
					Config.VARS += "&userId=" + data['net_id'];
					Config.VARS += "&net_type=1";

					params = new Object();
					params['app_id'] = Config.MM_APP_ID;
					params['method'] = "users.getInfo";
					params['session_key'] = data['access_token'];
					params['uids'] = data['net_id'];
					sig = data['net_id'] + getParams(params) + Config.MM_APP_KEY;
					url = "https://www.appsmail.ru/platform/api?sig=" + by.blooddy.crypto.MD5.hash(sig);
					url += getUrl(params);
					break;
				default:
					return;
			}

			Config.VARS += "&OAuth=1";
			Config.VARS += "&protocol=https:";
			
			var request:URLRequest = new URLRequest(url);

			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onProfile);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(request);
		}

		private function onProfile(e:Event):void
		{
			var data:Object = by.blooddy.crypto.serialization.JSON.decode(e.currentTarget.data);

			switch (socialType)
			{
				case "VK":
					(this.loginSprite as LoginSprite).loadPhoto(data['response'][0]['photo_50'], data['response'][0]['first_name'] + " " + data['response'][0]['last_name']);
					break;
				case "OK":
					(this.loginSprite as LoginSprite).loadPhoto(data['pic_1'], data['name']);
					break;
				case "FB":
					(this.loginSprite as LoginSprite).loadPhoto(data['picture']['data']['url'], data['name']);
					break;
				case "MM":
					(this.loginSprite as LoginSprite).loadPhoto(data[0]['pic_big'], data[0]['nick']);
					break;
			}
			Main.loadingSprite.visible = false;
		}

		private function getParams(params:Object):String
		{
			var answer:String = "";
			var array:Array = new Array();
			for (var key:String in params)
				array.push(key + "=" + params[key]);
			array.sort();
			for (key in array)
				answer += array[key];
			return answer;
		}

		private function getUrl(params:Object):String
		{
			var answer:String = "";
			for (var key:String in params)
				answer += "&" + key + "=" + params[key];
			return answer;
		}

		private function onError(e:IOErrorEvent):void
		{
			Logger.add("onError", e.text);
		}

		private function parseVersion(versionLine:String):String
		{
			var start:int, end:int, endN:int, endR:int;
			var version:String;

			start = versionLine.indexOf("=", 0);
			if (start == -1)
				return "";

			endN = versionLine.indexOf("\n", start);
			endR = versionLine.indexOf("\r", start);
			endN = endN == -1 ? int.MAX_VALUE : endN;
			endR = endR == -1 ? int.MAX_VALUE : endR;
			end = Math.min(endN, endR);

			if (endN == int.MAX_VALUE && endR == int.MAX_VALUE)
				return "";

			version = versionLine.slice(start + 1, end);
			while (version.replace("\"", "") != version)
				version = version.replace("\"", "");
			while (version.replace(" ", "") != version)
				version = version.replace(" ", "");
			while (version.replace("'", "") != version)
				version = version.replace("'", "");
			while (version.replace(";", "") != version)
				version = version.replace(";", "");

			return version;
		}
	}
}