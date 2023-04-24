package
{
	import game.gameData.PromoManager;

	import utils.WallTool;

	public class Referrers
	{
		static private const BLOCK_SIZE:int = 10000;
		static private const ACTIONS_START:int = 100;
		static private const ADVERTS_START:int = 1000;

		static private const INDEXES:Object = {
			'vk': 0,
			'mm': 1,
			'ok': 2,
			'fb': 3,
			'fs': 4
		};

		static private const REFERRERS_VK:Object = {
			'catalog_ads': 1,
			'catalog_popular': 2,
			'friends_feed': 3,
			'wall_view': 4,
			'wall_view_inline': 4,
			'group': 5,
			'request': 6,
			'quick_search': 7,
			'user_apps': 8,
			'menu': 9,
			'notification': 10,
			'notification_realtime': 11,
			'app_suggestions': 12,
			'featured': 13,
			'profile_status': 14,
			'top_grossing': 15,
			'join_request': 16,
			'friends_apps': 17,
			'collections': 18,
			'catalog_new': 19
		};

		static private const REFERRERS_MM:Object = {
			'stream.install': 1,
			'stream.publish': 2,
			'invitation': 3,
			'catalog': 4,
			'suggests': 5,
			'left_menu_suggest': 6,
			'new apps': 7,
			'guestbook': 8,
			'agent': 9,
			'search': 10,
			'left_menu': 11,
			'promo': 12,
			'mailru_featured': 13,
			'widget': 14,
			'installed_apps': 15,
			'banner_catalog': 16,
			'notification': 17,
			'friends_apps': 18,
			'advertisement': 19,
			'left_promo': 20,
			'feedpromo': 21
		};

		static private const REFERRERS_OK:Object = {
			'catalog': 1,
			'banner': 2,
			'friend_invitation': 3,
			'friend_feed': 4,
			'friend_notification': 5,
			'new_apps': 6,
			'top_apps': 7,
			'app_search_apps': 8,
			'user_apps': 9,
			'app_notification': 10,
			'friend_apps': 11,
			'user_apps_bottom_app_main': 12,
			'app_block': 13
		};

		// https://fbdevwiki.com/wiki/Ref
		static private const REFERRERS_FB:Object = {
			'aggregation': 1,
			'appcenter': 2,
			'appcenter_request': 3,
			'bookmark_apps': 4,
			'bookmark_favorites': 5,
			'bookmark_seeall': 6,
			'canvasbookmark': 7,
			'canvasbookmark_more': 8,
			'canvasbookmark_recommended': 9,
			'dashboard_bookmark': 10,
			'dashboard_toplist': 11,
			'dialog_permission': 12,
			'ego': 13,
			'feed': 14,
			'nf': 15,
			'feed_achievement': 16,
			'feed_highscore': 17,
			'feed_music': 18,
			'feed_opengraph': 19,
			'feed_passing': 20,
			'feed_playing': 21,
			'feed_video': 22,
			'games_my_recent': 23,
			'games_friends_apps': 24,
			'hovercard': 25,
			'message': 26,
			'mf': 27,
			'notification': 28,
			'other_multiline': 29,
			'pymk': 30,
			'recent_activity': 31,
			'reminders': 32,
			'request': 33,
			'search': 34,
			'ticker': 35,
			'timeline_og': 36,
			'timeline_news': 37,
			'timeline_passing': 38,
			'timeline_recent': 39,
			'sidebar_bookmark': 40,
			'sidebar_recommended': 41,
			'bookmarks': 42,
			'games_featured': 43,
			'featured_game ': 44,
			'notif': 45,
			'ts': 46,
			'rua': 47,
			'feed_music ': 48,
			'timeline': 49
		};

		static public function get():int
		{
			var session:Object = PreLoader.session;
			if (!(session['useApiType'] in INDEXES))
				return -1;

			var blockStart:int = BLOCK_SIZE * INDEXES[session['useApiType']];

			switch (session['useApiType'])
			{
				case "vk":
				{
					/**
					Стандартная реферная ссылка: https://vk.com/bottle_game#ref=4
					Всё, что после # находится в session['hash']
					Рекламная ссылка предоставляет session['referrer'] в виде ad_13468847
					*/

					if (!("hash" in session))
						session['hash'] = "unknown";

					PromoManager.promoCode = getParam(session["hash"], "promo");

					var action:int = WallTool.getActionsId(session['hash']);
					if (action > 0)
						return action + blockStart + ACTIONS_START;

					var code:int = parseInt(getParam(session["hash"], "ref"));
					if (code > 0 && code < BLOCK_SIZE - ADVERTS_START)
						return code + blockStart + ADVERTS_START;

					if (!("referrer" in session))
						session['referrer'] = "unknown";

					//if (session['referrer'] in Config.ADVERTS_VK)
					//	return Config.ADVERTS_VK[session['referrer']] + blockStart + ADVERTS_START;

					if (session['referrer'] in REFERRERS_VK)
						return REFERRERS_VK[session['referrer']] + blockStart;

					return blockStart;
				}
				case "mm":
				{
					/**
					Стандартная реферная ссылка: http://my.mail.ru/apps/543574#ref=8
					Всё, что после # находится в session['hash']
					В рекламе используются стандартные ссылки
					*/

					if (!("hash" in session))
						session['hash'] = "";

					PromoManager.promoCode = getParam(session["hash"], "promo");

					action = WallTool.getActionsId(session['hash']);
					if (action > 0)
						return action + blockStart + ACTIONS_START;

					code = parseInt(getParam(session["hash"], "ref"));
					if (code > 0 && code < BLOCK_SIZE - ADVERTS_START)
						return code + blockStart + ADVERTS_START;

					if (!("referer_type" in session))
						session['referer_type'] = "unknown";

					if (session['referer_type'] in REFERRERS_MM)
						return REFERRERS_MM[session['referer_type']] + blockStart;

					return blockStart;
				}
				case "ok":
				{
					/**
					Стандартная реферная ссылка: http://www.odnoklassniki.ru/app/bottle?ref=16
					Всё, что после ? находится в session['custom_args']
					В рекламе используются стандартные ссылки
					*/

					if (!("custom_args" in session))
						session['custom_args'] = "";

					PromoManager.promoCode = getParam(session["custom_args"], "promo");

					action = WallTool.getActionsId(session['custom_args']);
					if (action > 0)
						return action + blockStart + ACTIONS_START;

					code = parseInt(getParam(session["custom_args"], "ref"));
					if (code > 0 && code < BLOCK_SIZE - ADVERTS_START)
						return code + blockStart + ADVERTS_START;

					if (!("refplace" in session))
						session['refplace'] = "unknown";

					if (session['refplace'] in REFERRERS_OK)
						return REFERRERS_OK[session['refplace']] + blockStart;

					return blockStart;
				}
				case "fs":
				{
					/**
					Стандартная реферная ссылка: http://fotostrana.ru/app/bottle/?ref=3
					Все параметры лежат в session
					В рекламе используются стандартные ссылки
					*/

					if (!("ref" in session))
						session['ref'] = "";

					if (!("custom_args" in session))
						session['custom_args'] = "";

					if ("promo" in session)
						PromoManager.promoCode = session["promo"];

					action = WallTool.getActionsId(session['custom_args']);
					if (action > 0)
						return action + blockStart + ACTIONS_START;

					code = parseInt(session["ref"]);
					if (code > 0 && code < BLOCK_SIZE - ADVERTS_START)
						return code + blockStart + ADVERTS_START;

					return blockStart;
				}
				case "fb":
				{
					/**
					Стандартная реферная ссылка: https://apps.facebook.com/bottles/?ref=1
					Все параметры лежат в session
					В рекламе используются стандартные ссылки
					*/

					if (!("ref" in session))
						session['ref'] = "";

					if (!("custom_args" in session))
						session['custom_args'] = "";

					if ("promo" in session)
						PromoManager.promoCode = session["promo"];

					action = WallTool.getActionsId(session['custom_args']);
					if (action > 0)
						return action + blockStart + ACTIONS_START;

					code = parseInt(session["ref"]);
					if (code > 0 && code < BLOCK_SIZE - ADVERTS_START)
						return code + blockStart + ADVERTS_START;

					if (!("fb_source" in session))
						session['fb_source'] = "unknown";

					if (session['fb_source'] in REFERRERS_FB)
						return REFERRERS_FB[session['fb_source']] + blockStart;

					return blockStart;
				}
				case 'sa':
				{
					if ("promo" in session)
						PromoManager.promoCode = session["promo"];
					return -1;
				}
			}

			return -1;
		}

		static public function isFromWall():Boolean
		{
			var ids:Array = [3, 1003, 10002, 20004, 20013, 20101, 30014, 30101, 40101];
			return ids.indexOf(get()) != -1;
		}

		static private function getParam(args:String, key:String):String
		{
			var params:Array = args.split("&");
			for (var i:int = 0; i < params.length; i++)
			{
				var param:Array = params[i].split("=");
				if (param[0] == key)
					return param[1];
			}
			return "";
		}
	}
}