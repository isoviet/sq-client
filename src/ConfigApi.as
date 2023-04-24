package
{
	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;

	import dialogs.DialogEmailRequest;
	import dialogs.bank.DialogBankFB;
	import dialogs.bank.DialogBankFS;
	import dialogs.bank.DialogBankMM;
	import dialogs.bank.DialogBankOK;
	import dialogs.bank.DialogBankSA;
	import dialogs.bank.DialogBankVK;

	import by.blooddy.crypto.CRC32;

	import com.ApiConfig;
	import com.api.Player;
	import com.utils.StringUtil;

	public class ConfigApi extends ApiConfig
	{
		public function ConfigApi(paremeters:Object, loaderInfo:LoaderInfo):void
		{
			this.parameters = paremeters;
			this.loaderInfo = loaderInfo;

			applicationName = gls("Трагедия белок");

			noName = gls("Без имени");

			screenshotUploadUrl = Config.SCREENSHOT_UPLOAD_URL;
			photoSaveUrl = Config.PHOTO_SAVE_URL;

			defaultPhoto = new NonPhotoImage();
			defaultApi = Config.DEFAULT_API;

			playerClass = Player;

			emailDialog = DialogEmailRequest;

			// Vkontakte
			vk_type = Config.API_VK_ID;
			vk_savePhoto = false;
			vk_copyFields = ["name", "sex"];
			vk_saveFields = ["profile", "bdate", "photo_big", "city", "country"];
			vk_groupAddress = "https://vk.com/belkigame";
			vk_bankDialog = DialogBankVK;
			vk_appAddress = "https://vk.com/squirrels_game";
			vk_likesAddress =  "https:\/\/vk.com\/app2404568";
			CONFIG::debug{
				vk_likesAddress =  "http:\/\/vk.com\/app2656163";
			}

			vk_groupId = 28538688;
			vk_requestFields = "uid,first_name,sex,bdate,photo_big,screen_name,city,country";
			vk_photoUrl = "photo_big";

			// Facebook
			fb_type = Config.API_FB_ID;
			fb_savePhoto = false;
			fb_copyFields = ["name", "sex"];
			fb_saveFields = ["profile", "bdate", "photo_big", "country"];
			fb_groupAddress = (Config.isRus ? "https://www.facebook.com/squirrelstragedy/" : "https://www.facebook.com/belkigame");
			fb_appAddress = (Config.isRus ? "https://apps.facebook.com/squirrelstragedy/": "https://apps.facebook.com/tragedyofsquirrels/");
			fb_groupId = (Config.isRus ? "302416696482094" : "137323319735776");
			fb_bankDialog = DialogBankFB;
			fb_inviteFriendMessage = gls("Увлекательная игра Трагедия Белок, присоединяйся!");
			fb_appId = Config.API_FB_APP;
			fb_requestFields = "id,first_name,last_name,gender,birthday,locale,picture,link,location";
			fb_buy_url = Config.API_FB_BUY_URL;
			fb_crossAppId = (Config.isEng ? "106813929457679" : "");

			// FotoStrana
			fs_type = Config.API_FS_ID;
			fs_savePhoto = false;
			fs_copyFields = ["name", "sex"];
			fs_saveFields = ["profile", "bdate", "photo_big"];
			fs_groupAdress = "https://fotostrana.ru/community/43306/";
			fs_groupId = 43306;
			fs_bankDialog = DialogBankFS;
			fs_requestFields = "user_name,sex,birthday,photo_big,user_link";
			fs_photoUrl = "photo_big";

			// Mail.ru
			mm_type = Config.API_MM_ID;
			mm_savePhoto = false;
			mm_copyFields = ["name", "sex"];
			mm_saveFields = ["profile", "bdate", "photo_big", "country"];
			mm_groupAddress = "https://my.mail.ru/community/squirrels_game/";
			mm_groupId = "8847861727607833664";
			mm_bankDialog = DialogBankMM;
			mm_appAddress = "https://my.mail.ru/apps/648036";
			mm_secret = Config.API_MM_SECRET;
			mm_photoUrl = "pic_big";
			mm_inviteFriendMessage = "Увлекательная игра Трагедия Белок, присоединяйся!";

			// Odnoklassniki
			ok_type = Config.API_OK_ID;
			ok_savePhoto = false;
			ok_copyFields = ["name", "sex"];
			ok_saveFields = ["profile", "bdate", "photo_big", "country"];
			ok_groupAddress = "https://www.odnoklassniki.ru/group/51869321068777";
			ok_groupId = "52192660979156";
			ok_bankDialog = DialogBankOK;
			ok_appAddress = "https://www.odnoklassniki.ru/game/squirrels";
			ok_requestFields = "uid,first_name,name,gender,birthday,location,pic_2,url_profile";
			ok_photoUrl = "pic_2";

			// StandAlone
			sa_type = Config.API_SA_ID;
			sa_savePhoto = false;
			sa_copyFields = ["name", "sex", "email"];
			sa_saveFields = ["profile", "bdate", "photo_big"];
			sa_groupAddress = "https://forum.itsrealgames.com/forum/10-трагедия-белок/";
			sa_bankDialog = DialogBankSA;
			sa_appId = Config.API_SA_APP;
			sa_bankId = Config.isRus ? 7246 : 10106;
			sa_offerId = 3029;
			sa_apiUrl = Config.API_SA_URL;

			uploadHandler = function(player:Player):Boolean
			{
				if (player.photoBig.indexOf("/saved/") != -1)
					return true;

				var bytes:ByteArray = new ByteArray();
				bytes.writeUTFBytes(player.self['photo_big']);

				var validUrl:String = Config.PHOTOS_BASE + (player.id % Config.UID_CACHE_SIZE) + "/" + player.id + "/" + CRC32.hash(bytes) + ".png";

				trace("uploadHandler: " + player.photoBig + " != " + validUrl);

				return (player.photoBig != validUrl);
			};

			nameStripFunction = function(name:String):String
			{
				name = StringUtil.stripHTML(name);

				name = name.replace(new RegExp(/[^a-zA-Z0-9а-яА-ЯёЁ \]\[]/g), "");
				name = name.substr(0, 15);

				if ((new RegExp("^ +$")).test(name))
					return "";

				return name;
			};
		}
	}
}