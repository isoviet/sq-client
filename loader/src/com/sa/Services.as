package com.sa
{
	public class Services
	{
		static public var userId:int = -1;
		static public var sessionKey:String = "";
		static public var authKey:String = "";
		static public var appId:int = 1;

		static public var accessToken:String = "";

		static public var apiUrl:String = "https://games.itsrealgames.com/api.php";
		static public const OAUTH_URL_RU:String = "https://squirrelspay.realcdn.ru/oauth.php";
		static public const OAUTH_URL_EN:String = "https://squirrelseng.realcdn.ru/oauth.php";

		public function Services()
		{
			new Processor();
			new Provider();
		}

		static public function connect():void
		{
			Config.VARS = "useApiType=sa&userId=" + Services.userId;
			Config.VARS += "&sessionKey=" + Services.sessionKey;
			Config.VARS += "&authKey=" + Services.authKey;
			Config.VARS += "&net_type=32";
			Config.VARS += "&protocol=http:";
			Main.onLogin();
		}

		static public function get oauthUrl():String
		{
			return Main.isRus ? OAUTH_URL_RU : OAUTH_URL_EN;
		}
	}

}