package
{
	public class Config
	{
		static public const RU_LOCALE:String = "ru";
		static public const EN_LOCALE:String = "en";

		CONFIG::release
		{
			static public const CONFIG_URL:Object = {
				(RU_LOCALE.toString()): "https://squirrels2.itsrealgames.com/config_release.xml",
				(EN_LOCALE.toString()): "https://squirrelseng.realcdn.ru/config_release.xml"
			};
		}
		CONFIG::debug
		{
			static public const CONFIG_URL:Object = {
				(RU_LOCALE.toString()): "https://squirrels.itsrealgames.com/test/config_debug.xml",
				(EN_LOCALE.toString()): "https://squirrels.itsrealgames.com/test/config_debug.xml"
			};
		}

		static public const URL_UPDATE_PLAYER:String = "https://get.adobe.com/ru/flashplayer/";
		static public const MIN_VERSION_PLAYER:int = 11;

		static public const VERSION_MAJOR:int = 1;
		static public const VERSION_MINOR:int = 694;

		static public const DEFAULT_API:String = "vk";

		static public const NAME_MAX_LENGTH:int = 15;
		static public const UID_CACHE_SIZE:int = 199;

		static public const GAME_WIDTH:int = 900;
		static public const GAME_HEIGHT:int = 620;

		static public var DEBUG:Boolean;

		static public var SERVER_HOST:String;
		static public var SERVER_PORT:Array;

		static public var ERRORS_URL:String;
		static public var PHOTO_SAVE_URL:String;
		static public var SCREENSHOT_UPLOAD_URL:String;
		static public var EMBLEM_UPLOAD_URL:String;

		static public var PHOTOS_BASE:String;

		static public var WALL_URL:String;
		static public var IMAGES_URL:String;
		static public var PREVIEWS_URL:String;
		static public var PREVIEWS_CAST_URL:String;
		static public var PREVIEWS_CLOTHES_URL:String;

		static public var HISTORY_MOVIE_URL:String;
		static public var HISTORY_HARE_MOVIE_URL:String;
		static public var SOUNDS_URL:String;
		static public var SOUNDS_CONFIG_URL:String;
		static public var CONTENT_URL:String;
		static public var ACHIEVEMENTS_URL:String;
		static public var ACHIEVES_IMAGES_URL:String;

		static public var LOCALE:String = RU_LOCALE;
		static public var PROTOCOL:String = "https:";

		static public var API_VK_ID:int;

		static public var API_MM_ID:int;
		static public var API_MM_SECRET:String;

		static public var API_OK_ID:int;
		static public var API_OK_SECRET:String;

		static public var API_FB_ID:int;
		static public var API_FB_APP:String;
		static public var API_FB_BUY_URL:String;
		static public var API_FB_PRODUCTS_URL:String;

		static public var API_FS_ID:int;
		static public var API_FS_PRODUCTS_URL:String;

		static public var API_SA_ID:int;
		static public var API_SA_URL:String;

		CONFIG::release{static public var API_SA_APP:int = 1;}
		CONFIG::debug{static public var API_SA_APP:int = 2;}

		static public function get isRus():Boolean
		{
			return LOCALE == RU_LOCALE;
		}

		static public function get isEng():Boolean
		{
			return LOCALE == EN_LOCALE;
		}

		static public function load(config:XML):void
		{
			DEBUG = (config['debug'] != "0");

			SERVER_HOST = config['host'];

			try
			{
				SERVER_PORT = parsePorts(config['ports']);
			}
			catch(e:Error)
			{}

			CONFIG::debug{SERVER_PORT = [22227];}

			ERRORS_URL = PROTOCOL + config['urls']['errors'];

			PHOTOS_BASE = PROTOCOL + config['urls']['photo']['base'];
			PHOTO_SAVE_URL = PROTOCOL + config['urls']['photo']['save'];

			WALL_URL = PROTOCOL + config['urls']['wall'];
			SOUNDS_URL = PROTOCOL + config['urls']['sounds'];
			SOUNDS_CONFIG_URL = PROTOCOL + config['urls']['soundsConfig'];

			CONTENT_URL = PROTOCOL + config['urls']['content'];
			IMAGES_URL = PROTOCOL + config['urls']['images'];

			PREVIEWS_URL = PROTOCOL + config['urls']['previews'];
			PREVIEWS_CAST_URL = PROTOCOL + config['urls']['previewsCast'];
			PREVIEWS_CLOTHES_URL = PROTOCOL + config['urls']['previewsClothes'];

			SCREENSHOT_UPLOAD_URL = PROTOCOL + config['urls']['screenshot'];
			EMBLEM_UPLOAD_URL = PROTOCOL + config['urls']['emblem'];

			HISTORY_MOVIE_URL = PROTOCOL + config['urls']['history'];
			HISTORY_HARE_MOVIE_URL = PROTOCOL + config['urls']['historyHare'];

			ACHIEVEMENTS_URL = "http:" + config['urls']['achievements'];
			ACHIEVES_IMAGES_URL = PROTOCOL + config['urls']['achievesImages'];

			API_VK_ID = int(config['networks']['vk']['@id']);

			API_MM_ID = int(config['networks']['mm']['@id']);
			API_MM_SECRET = config['networks']['mm']['secret'];

			API_OK_ID = int(config['networks']['ok']['@id']);
			API_OK_SECRET = config['networks']['ok']['secret'];

			API_FB_ID = int(config['networks']['fb']['@id']);
			API_FB_APP = config['networks']['fb']['app'];
			API_FB_BUY_URL = config['networks']['fb']['buy_url'];
			API_FB_PRODUCTS_URL = config['networks']['fb']['products_url'];

			API_FS_ID = int(config['networks']['fs']['@id']);
			API_FS_PRODUCTS_URL = config['networks']['fs']['products_url'];

			API_SA_ID = int(config['networks']['sa']['@id']);
			API_SA_URL = config['networks']['sa']['api_url'];
		}

		static private function parsePorts(portsString:String):Array
		{
			var shuffle:Array = (portsString.split("|")[0] as String).replace(" ", "").split(",");

			var queue:Array = portsString.split("|").length > 0 ? (portsString.split("|")[1] as String).replace(" ", "").split(",") : [];

			for (var index:* in queue)
				queue[index] = int(queue[index]);

			return [int(shuffle[int(Math.random() * shuffle.length)])].concat(queue);
		}
	}
}