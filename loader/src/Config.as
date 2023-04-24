package
{
	import flash.utils.ByteArray;

	import by.blooddy.crypto.Base64;

	public class Config
	{
		[Embed(source="../Squirrels.skin", mimeType="application/octet-stream")]
		static private const skin:Class;

		static public const VERSION_URL_RU:String = "https://squirrels2.itsrealgames.com/release/config.js";
		static public const SWF_PATH_RU:String = "https://squirrels2.itsrealgames.com/release/client_release";

		static public const VERSION_URL_EN:String = "https://squirrelseng.realcdn.ru/release/config.js";
		static public const SWF_PATH_EN:String = "https://squirrelseng.realcdn.ru/release/client_release";

		static public const PHOTO_UPLOAD_URL:String = "https://games.itsrealgames.com/photo_upload.php";

		static public var VARS:String = "";

		static public const REDIRECT_URL:String = "https://games.itsrealgames.com/oauth";

		static public const VK_APP_ID:int = 3509943;
		static public const VK_SCOPE:String = "friends,photo";
		static public const VK_DISPALY:String = "touch";

		static public const MM_APP_ID:int = 702077;
		static public const MM_SCOPE:String = "photos guestbook stream messages events";
		static public const MM_DISPALY:String = "touch";
		static public const MM_APP_KEY:String = "2ca22221fe51f8ca73ccd6ae846f9275";

		static public const OK_APP_ID:int = 5849344;
		static public const OK_SCOPE:String = "VALUABLE ACCESS;SET STATUS;PHOTO CONTENT";
		static public const OK_DISPALY:String = "touch";
		static public const OK_APP_KEY:String = "CBACEKFBABABABABA";

		static public const FB_APP_ID_RU:String = "103918979735374";
		static public const FB_APP_ID_EN:String = "1388050514768942";
		static public const FB_SCOPE:String = "user_birthday, email, publish_actions, user_friends";
		static public const FB_DISPALY:String = "popup";

		static public const skinEncoded:String = Base64.encode(new skin() as ByteArray);
	}

}