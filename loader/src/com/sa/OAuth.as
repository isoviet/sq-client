package com.sa
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import by.blooddy.crypto.MD5;
	import by.blooddy.crypto.serialization.JSON;
	import com.utils.DateUtil;

	public class OAuth
	{
		static public var profile:Object = null;
		static public var data:Object = null;

		static public function request():void
		{
			var url:String = "";

			switch (Main.socialType)
			{
				case "VK":
					url = "https://api.vk.com/method/users.get?fields=photo_50,bdate,sex&uid=" + data['user_id'] + "&access_token=" + data['access_token'] + "&v=5.92";
					break;
				case "OK":
					var params:Object = new Object();
					params['application_key'] = Config.OK_APP_KEY;
					params['format'] = "JSON";
					params['method'] = "users.getCurrentUser";

					var sig:String = getParams(params);
					url = "http://api.odnoklassniki.ru/fb.do?access_token=" + data['access_token'];
					url += getUrl(params);
					url += "&sig=" + by.blooddy.crypto.MD5.hash(sig + data['sig']);
					break;
				case "FB":
					url = "https://graph.facebook.com/me?fields=picture,name,gender,birthday&access_token=" + data['access_token'];
					break;
				case "MM":
					params = new Object();
					params['app_id'] = Config.MM_APP_ID;
					params['method'] = "users.getInfo";
					params['session_key'] = data['access_token'];
					params['uids'] = data['user_id'];
					sig = data['user_id'] + getParams(params) + Config.MM_APP_KEY;
					url = "https://www.appsmail.ru/platform/api?sig=" + by.blooddy.crypto.MD5.hash(sig);
					url += getUrl(params);
					break;
				default:
					return;
			}
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onProfile);
			urlLoader.load(request);
		}

		static private function onProfile(e:Event):void
		{
			var data:Object = by.blooddy.crypto.serialization.JSON.decode(e.currentTarget.data);
			profile = new Object();
			switch (Main.socialType)
			{
				case "VK":
					data = data['response'][0];
					profile['name'] = data['first_name'] + " " + data['last_name'];
					profile['image'] = data['photo_50'];
					profile['sex'] = data['sex'];
					profile['bdate'] = ("bdate" in data) ? DateUtil.getTime(data['bdate']) : 0;
					break;
				case "OK":
					profile['name'] = data['name'];
					profile['image'] = data['pic_1'];
					profile['sex'] = (data['gender'] == "male") ? 2 : 1;
					profile['bdate'] = DateUtil.getTime(data['birthday']);
					break;
				case "FB":
					profile['name'] = data['name'];
					profile['image'] = data['picture']['data']['url'];
					profile['sex'] = (data['gender'] == "male") ? 2 : 1;
					profile['bdate'] = ("birthday" in data) ? DateUtil.getTime(data['birthday']) : 0;
					break;
				case "MM":
					data = data[0];
					profile['name'] = data['nick'];
					profile['image'] = data['pic_big'];
					profile['sex'] = (data['sex'] == 0) ? 2 : 1;
					profile['bdate'] = ("birthday" in data) ? DateUtil.getTime(data['birthday']) : 0;
					break;
			}
			Services.connect();
		}

		static private function getParams(params:Object):String
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

		static private function getUrl(params:Object):String
		{
			var answer:String = "";
			for (var key:String in params)
				answer += "&" + key + "=" + params[key];
			return answer;
		}
	}

}