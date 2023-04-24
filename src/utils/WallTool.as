package utils
{
	import flash.display.Bitmap;
	import flash.utils.getQualifiedClassName;

	import com.api.Player;
	import com.api.Services;
	import com.fb.Wall;
	import com.fs.Wall;
	import com.mm.Wall;
	import com.ok.Wall;
	import com.vk.Wall;

	import protocol.Connection;
	import protocol.PacketClient;

	public class WallTool
	{
		static public const ACTIONS:Array = ["wall_ref"];

		static public const WALL_AWARD:String = "WALL_AWARD";

		static public const WALL_COLLECTION_REGULAR:String = "WALL_COLLECTION_REGULAR";
		static public const WALL_COLLECTION_UNIQUE:String = "WALL_COLLECTION_UNIQUE";
		static public const WALL_COLLECTION_AWARD:String = "WALL_COLLECTION_AWARD";
		static public const WALL_COLLECTION_EXCHANGE:String = "WALL_COLLECTION_EXCHANGE";

		static public const WALL_EXP:String = "WALL_EXP";
		static public const WALL_SHAMAN_EXP:String = "WALL_SHAMAN_EXP";
		//static public const WALL_SHAMAN_SKILL:String = "WALL_SHAMAN_SKILL";
		//static public const WALL_SHAMAN_BRANCH:String = "WALL_SHAMAN_BRANCH";

		static public const WALL_PRESENT:String = "WALL_PRESENT";
		//static public const WALL_NEW_PACKAGE:String = "WALL_NEW_PACKAGE";

		//static public const WALL_SHAMAN_CERTIFICATE:String = "WALL_SHAMAN_CERTIFICATE";
		static public const WALL_BATTLE_RESULT:String = "WALL_BATTLE_RESULT";
		static public const WALL_FRIEND_RATING:String = "WALL_FRIEND_RATING";
		static public const WALL_NEWS:String = "WALL_NEWS";

		static public const MAP_APPROVED:String = "MAP_APPROVED";

		//static public const WALL_QUEST:String = "WALL_QUEST";

		//static public const WALL_CLAN_CREATE:String = "WALL_CLAN_CREATE";
		//static public const WALL_CLAN_LEVEL:String = "WALL_CLAN_LEVEL";

		static public const WALL_EVERY_DAY_BONUS:String = "WALL_EVERY_DAY_BONUS";
		static public const WALL_RATING_LEAGUE:String = "WALL_RATING_LEAGUE";

		static public const WALL_GOLDEN_CUP:String = "WALL_GOLDEN_CUP";

		static public const WALL_PROMO:String = "WALL_PROMO";

		static public const WALL_HOLYDAY:String = "WALL_HOLYDAY";

		static public const WALL_SILVANA:String = "WALL_SILVANA";
		static public const WALL_RAPUNCEL:String = "WALL_RAPUNCEL";
		static public const WALL_DRUID:String = "WALL_DRUID";
		static public const WALL_BEAR:String = "WALL_BEAR";

		static public const WALL_AMUR:String = "WALL_AMUR";

		static public function imageUrl(type:String, id:int):String
		{
			switch (type)
			{
				case WALL_AWARD:
					return Config.IMAGES_URL + "repost_awards/" + getQualifiedClassName(Award.DATA[id]['image']) + ".png";
				case WALL_EXP:
					return Config.IMAGES_URL + "repost_level/New_level_" + id + ".png";
				case WALL_SHAMAN_EXP:
					return Config.IMAGES_URL + "repost_shaman/New_level_" + id + ".png";
				case WALL_PRESENT:
					return Config.IMAGES_URL + "Present_" + id + ".png";
				/*case WALL_QUEST:
					return Config.IMAGES_URL + "quest/Quest_" + id + ".png";*/
				/*case WALL_SHAMAN_CERTIFICATE:
					return Config.IMAGES_URL + "Certificate_" + id + ".png";*/
				case WALL_COLLECTION_REGULAR:
					return Config.IMAGES_URL + "regular/Collection_regular_" + id + ".png";
				case WALL_COLLECTION_UNIQUE:
					return Config.IMAGES_URL + "repost_unique/Collection_unique_" + id + ".png";
				case WALL_COLLECTION_AWARD:
					return Config.IMAGES_URL + "repost_award/Collection_award_" + id + ".png";
				case WALL_FRIEND_RATING:
					return Config.IMAGES_URL + "Friends_rating_" + id + ".png";
				case MAP_APPROVED:
					return Config.IMAGES_URL + "map_approved.png";
				/*case WALL_NEW_PACKAGE:
					return Config.IMAGES_URL + "repost_package/Package_" + id + ".png";*/
				case WALL_EVERY_DAY_BONUS:
					return Config.IMAGES_URL + "repost_bonus/every_day_bonus_" + id + ".png";
				case WALL_RATING_LEAGUE:
					return Config.IMAGES_URL + "repost_rating/new_league_" + id + ".png";
				case WALL_HOLYDAY:
					return Config.IMAGES_URL + "halloween_package_2015.png";

				case WALL_SILVANA:
					return Config.IMAGES_URL + "sring_2016/spring_package_2016_1.png";
				case WALL_RAPUNCEL:
					return Config.IMAGES_URL + "sring_2016/spring_package_2016_2.png";
				case WALL_DRUID:
					return Config.IMAGES_URL + "sring_2016/spring_package_2016_3.png";
				case WALL_BEAR:
					return Config.IMAGES_URL + "sring_2016/spring_package_2016_4.png";
				case WALL_GOLDEN_CUP:
					return Config.IMAGES_URL + "golden_cup.png";
				case WALL_AMUR:
					return Config.IMAGES_URL + "amur_2016/amur_" + id +".png"
			}
			return "";
		}

		static public function place(player:Player, type:String, id:int, image:Bitmap, text:String, url:String = "", withLinks:Boolean = true, callback:Function = null, actionsArray:Array = null):void
		{
			if (!('nid' in player))
			{
				player.addEventListener(PlayerInfoParser.NET_ID, function(player:Player):void
				{
					place(player, type, id, image, text, url, withLinks);
				});
				Game.request([player.id], PlayerInfoParser.NET_ID);
				return;
			}

			Connection.sendData(PacketClient.COUNT, PacketClient.MAKE_REPOST, Game.self['type']);

			FullScreenManager.instance().fullScreen = false;

			url = url == "" ? WallTool.imageUrl(type, id) : url;
			actionsArray = [{'text': gls("Играть в Трагедию Белок"), 'href': ACTIONS[0] + "=" + String(Game.selfId)}];
			var actions:Array = getActions(actionsArray);

			if (com.api.Services.wall is com.vk.Wall)
			{
				var vkWall:com.vk.Wall = com.api.Services.wall as com.vk.Wall;
				vkWall.placeVK(player['nid'], image, text + (withLinks ? " http://vk.com/squirrels_game#ref=3" : ""), callback);
			}

			if (com.api.Services.wall is com.mm.Wall)
			{
				var mmWall:com.mm.Wall = com.api.Services.wall as com.mm.Wall;
				mmWall.placeMM(player['nid'], "Трагедия белок", text + (withLinks ? " http://my.mail.ru/apps/648036" : ""), url, callback, actions);
			}

			if (com.api.Services.wall is com.fb.Wall)
			{
				var fbWall:com.fb.Wall = com.api.Services.wall as com.fb.Wall;
				fbWall.placeFB(player['nid'], url, gls("Трагедия белок"), "", text, actions, com.api.Services.config.fb_appAddress + "?fb_source=feed", "iframe", callback);
			}

			if (com.api.Services.wall is com.ok.Wall)
			{
				var okWall:com.ok.Wall = com.api.Services.wall as com.ok.Wall;
				okWall.placeOK(text + (withLinks ? " http://www.odnoklassniki.ru/game/squirrels?" + ACTIONS[0] + "=" + Game.selfId : ""), url, "Рассказать всем друзьям?", callback, actions);
			}

			if (com.api.Services.wall is com.fs.Wall)
			{
				var fsWall:com.fs.Wall = com.api.Services.wall as com.fs.Wall;
				fsWall.placeFS(text, url, callback, actions);
			}
		}

		static public function getActionsId(params:*):int
		{
			if (params is String)
			{
				var result:Array = params.split("=");
				for (i = 0; i < ACTIONS.length; i++)
				{
					if (result[0] == ACTIONS[i])
						return i + 1;
				}
			}
			else
			{
				for (var i:int = 0; i < ACTIONS.length; i++)
				{
					if (ACTIONS[i] in params)
						return i + 1;
				}
			}
			return 0;
		}

		static public function get canPost():Boolean
		{
			return Game.self.type != Config.API_SA_ID;
		}

		static private function getActions(actions:Array):Array
		{
			if (actions == null)
				return actions;

			switch (Game.self.type)
			{
				case Config.API_FB_ID:
					return [{'name': actions[0]['text'], 'link': Services.config.fb_appAddress + "?custom_args=" + actions[0]['href']}];
				case Config.API_FS_ID:
					return [actions[0]['text'], {'custom_args': actions[0]['href']}];
				default:
					return actions;
			}
		}
	}
}