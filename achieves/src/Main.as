package
{
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import mx.events.Request;

	public class Main extends Sprite
	{
		CONFIG::release {
			static public const APP_ID:String = "103918979735374";
			static public const APP_SECRET:String = "64b4c5f779cd076a6a3a25501302f7ed";
			static public const ACH_ADDRESS:String = "https://squirrels2.itsrealgames.com/release/achievements/";
		}
		CONFIG::debug {
			static public const APP_ID:String = "130880430367150";
			static public const APP_SECRET:String = "5a09384f81e7b6c30c16c40aa8cad7d0";
			static public const ACH_ADDRESS:String = "https://squirrels.itsrealgames.com/test/fb_rus/achievements/";
		}

		private var appAccessToken:String = "";

		public function Main():void
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var requestToken:URLRequest = new URLRequest("https://graph.facebook.com/oauth/access_token?client_id=" + APP_ID + "&client_secret=" + APP_SECRET + "&grant_type=client_credentials");

			try
			{
				var loader:URLLoader = new URLLoader(requestToken);
				loader.addEventListener(Event.COMPLETE, onCompleteRequestToken);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			} catch (e:Error){}
		}

		private function registerAchievements():void
		{
			for (var i:int = 2; i <= 155; i++)
				registerAchievement(ACH_ADDRESS + "level" + i + ".html", i);
		}

		private function registerAchievement(url:String, displayOrder:int):void
		{
			var requestPost:URLRequest = new URLRequest("https://graph.facebook.com/" + APP_ID + "/achievements");

			requestPost.method = URLRequestMethod.POST;

			var urlVariabels:URLVariables = new URLVariables();
			var variables:Object = {
				'access_token': this.appAccessToken,
				'achievement': url,
				'display_order': displayOrder
			};

			for (var key:* in variables)
				urlVariabels[key] = variables[key];
			requestPost.data = urlVariabels;

			try
			{
				var loader:URLLoader = new URLLoader(requestPost);
				loader.addEventListener(Event.COMPLETE, onCompleteRequestPost);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			} catch (e:Error){}
		}

		private function onError(e:Event):void
		{
			trace(e.currentTarget.data);
		}

		private function onCompleteRequestToken(e:Event):void
		{
			trace(e.currentTarget.data);

			var params:Array = e.currentTarget.data.split("=", 2);
			this.appAccessToken = params[1];

			registerAchievements();
		}

		private function onCompleteRequestPost(e:Event):void
		{
			trace(e.currentTarget.data);
		}
	}
}