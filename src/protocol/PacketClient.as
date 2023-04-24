package protocol
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import utils.UInt64;

	public dynamic class PacketClient extends ByteArray
	{
		static private var type:int = 0;

		// айдишники пакетов должны иметь тип uint, чтобы их имена показывались в логах

		static public const ADMIN_REQUEST_NET:uint = ++type;	// Запрос админ-данных
		static public const ADMIN_REQUEST_INNER:uint = ++type;	// Запрос админ-данных
		static public const ADMIN_REQUEST_CLAN:uint = ++type;	// Запрос данных клана

		static public const ADMIN_EDIT_PLAYER:uint = ++type;	// Редактирование игрока администратором
		static public const ADMIN_EDIT_CLAN:uint = ++type;	// Редактирование клана администратором

		static public const ADMIN_CLEAR:uint = ++type;		// Сброс пользователя
		static public const ADMIN_CLOSE_CLAN:uint = ++type;	// Закрытие клана администратором

		static public const ADMIN_MESSAGE:uint = ++type;	// Глобальное сообщение от администратора
		static public const SESSION_REQUEST:uint = ++type;	// Пакет для работы GA

		static public const HELLO:uint = ++type;
		static public const LOGIN:uint = ++type;
		static public const PLAY:uint = ++type;			// Want to play
		static public const PLAY_CANCEL:uint = ++type;		// Want to refuse
		static public const PLAY_WITH:uint = ++type;		// Want to play
		static public const SPY_FOR:uint = ++type;		// Want to spy
		static public const PLAY_ROOM:uint = ++type;
		static public const LEAVE:uint = ++type;			// Want to leave play room
		static public const REQUEST:uint = ++type;		// Want to request player info
		static public const REQUEST_NET:uint = ++type;		// Want to request player info by net_id
		static public const INFO:uint = ++type;			// Want to send player's info

		static public const REFILL:uint = ++type;		// Want to refill account
		static public const BAN:uint = ++type;			// Want to block player
		static public const BUY:uint = ++type;			// Want to buy something

		static public const PING:uint = ++type;
		static public const LATENCY:uint = ++type;
		static public const COUNT:uint = ++type;

		static public const FLAGS_SET:uint = ++type;
		static public const INVITE:uint = ++type;

		static public const CLEAR_TEMPORARY:uint = ++type;
		static public const ACHIEVEMENT:uint = ++type;
		static public const GUARD:uint = ++type;

		static public const REPOST_NEWS:uint = ++type;

		static public const REQUEST_AWARD:uint = ++type;

		static public const RENAME:uint = ++type;

		//35
		static public const SIGN_XSOLLA:uint = ++type;

		static public const BIRTHDAY_CELEBRATE:uint = ++type;

		static public const EVERY_DAY_BONUS_GET:uint = ++type;

		static public const PRODUCE_REQUEST:uint = ++type;

		static public const STORAGE_SET:uint = ++type;
		static public const TRAINING_SET:uint = ++type;

		static public const PROMO_CODE:uint = ++type;
		static public const BUNDLE_NEWBIE_ACTIVATE:uint = ++type;

		static public const HOLIDAY_LOTTERY:uint = ++type;

		static public const RATING_REQUEST:uint = ++type;
		static public const RATING_REQUEST_TOP:uint = ++type;

		static public const SOCIAL_FRIENDS:uint = ++type;
		static public const FRIENDS_ADD:uint = ++type;
		static public const FRIENDS_REMOVE:uint = ++type;
		static public const FRIENDS_RETURN:uint = ++type;
		static public const FRIENDS_ONLINE:uint = ++type;

		static public const DAILY_QUEST_REQUEST:uint = ++type;
		static public const DAILY_QUEST_ADD:uint = ++type;
		static public const DAILY_QUEST_COMPLETE:uint = ++type;

		static public const CHAT_MESSAGE:uint = ++type;
		static public const CHAT_COMMAND:uint = ++type;

		static public const COLLECTION_ASSEMBLE:uint = ++type;
		static public const COLLECTION_EXCHANGE_ADD:uint = ++type;
		static public const COLLECTION_EXCHANGE_REMOVE:uint = ++type;
		static public const COLLECTION_EXCHANGE:uint = ++type;

		static public const CLOTHES_REQUEST_CLOSEOUTS:uint = ++type;
		static public const CLOTHES_WEAR:uint = ++type;
		static public const CLOTHES_SET_SLOT:uint = ++type;

		static public const GIFT_SEND:uint = ++type;
		static public const GIFT_ACCEPT:uint = ++type;

		static public const DEFERRED_BONUS_ACCEPT:uint = ++type;

		static public const EVENT_REMOVE:uint = ++type;

		static public const ROUND_ALIVE:uint = ++type;		// Player alive
		static public const ROUND_HERO:uint = ++type;		// Player state
		static public const ROUND_CAST_BEGIN:uint = ++type;	// Want to cast
		static public const ROUND_CAST_END:uint = ++type;	// Want to cast
		static public const ROUND_NUT:uint = ++type;		// Player has taken the nut
		static public const ROUND_HOLLOW:uint = ++type;		// Player finished with nut
		static public const ROUND_DIE:uint = ++type;		// Player died
		static public const ROUND_RESPAWN:uint = ++type;		// Player respawned
		static public const ROUND_SYNC:uint = ++type;		// World state
		static public const ROUND_WORLD:uint = ++type;		// World state
		static public const ROUND_SKILL:uint = ++type;		// World state
		static public const ROUND_SKILL_ACTION:uint = ++type;
		static public const ROUND_SKILL_SHAMAN:uint = ++type;
		static public const ROUND_COMMAND:uint = ++type;
		static public const ROUND_ELEMENT:uint = ++type;
		static public const ROUND_VOTE:uint = ++type;
		static public const ROUND_SMILE:uint = ++type;
		static public const ROUND_ZOMBIE:uint = ++type;

		static public const MAPS_LIST:uint = ++type;
		static public const MAPS_GET:uint = ++type;
		static public const MAPS_ADD:uint = ++type;
		static public const MAPS_EDIT:uint = ++type;
		static public const MAPS_REMOVE:uint = ++type;
		static public const MAPS_CLEAR_RATING:uint = ++type;
		static public const MAPS_CHECK:uint = ++type;

		static public const CLAN_CREATE:uint = ++type;
		static public const CLAN_INFO:uint = ++type;
		static public const CLAN_RENAME:uint = ++type;
		static public const CLAN_ACCEPT:uint = ++type;
		static public const CLAN_LEAVE:uint = ++type;
		static public const CLAN_INVITE:uint = ++type;
		static public const CLAN_JOIN:uint = ++type;
		static public const CLAN_KICK:uint = ++type;
		static public const CLAN_CLOSE:uint = ++type;
		static public const CLAN_DONATION:uint = ++type;
		static public const CLAN_REQUEST:uint = ++type;
		static public const CLAN_SUBSTITUTE:uint = ++type;
		static public const CLAN_UNSUBSTITUTE:uint = ++type;
		static public const CLAN_GET_TRANSACTIONS:uint = ++type;
		static public const CLAN_GET_APPLICATION:uint = ++type;
		static public const CLAN_GET_MEMBERS:uint = ++type;
		static public const CLAN_GET_ROOMS:uint = ++type;
		static public const CHAT_ENTER:uint = ++type;
		static public const CHAT_LEAVE:uint = ++type;
		static public const CLAN_NEWS:uint = ++type;
		static public const CLAN_TOTEM:uint = ++type;
		static public const CLAN_ADD_IN_BLACKLIST:uint = ++type;
		static public const CLAN_REMOVE_FROM_BLACKLIST:uint = ++type;
		static public const CLAN_LEVEL_LIMITER:uint = ++type;

		static public const COLOR:uint = ++type;

		static public const DISCOUNT_USE:uint = ++type;

		static public const INTERIOR_CHANGE:uint = ++type;

		static public const LEARN_SHAMAN_SKILL:uint = ++type;
		static public const CHANGE_SHAMAN_BRANCH:uint = ++type;

		static public const TRANSFER:uint = ++type;

		static public const AB_GUI_ACTION:uint = ++type;

		static public const NY_MODE_TAKE:uint = ++type;
		static public const NY_MODE_PLACE:uint = ++type;

		static public const ADMIN_REQUEST_PROMO:uint = ++type;
		static public const ADMIN_EDIT_PROMO:uint = ++type;
		static public const ADMIN_ADD_PROMO:uint = ++type;

		static public const SERVICE_CLICK:uint = ++type;

		// AB_GUI
		static public const AB_GUI_SHOW:int = 0;
		static public const AB_GUI_USE:int = 1;

		// Buy
		static public const BUY_ENERGY_BIG:int = 3;
		static public const BUY_MANA_BIG:int = 5;
		static public const BUY_SHAMAN:int = 6;
		static public const BUY_HARE:int = 10;
		static public const BUY_ITEMS:int = 14;
		static public const BUY_ITEM_SET:int = 15;
		static public const BUY_CLAN_ROOM:int = 17;
		static public const BUY_DRAGON:int = 18;
		static public const BUY_ITEMS_FAST:int = 19;
		static public const BUY_DAILY_REJECT:int = 25;
		static public const BUY_CLAN_PLACE:int = 27;
		static public const BUY_CLAN_TOTEM:int = 29;
		static public const BUY_COLLECTION_ITEM:int = 30;
		static public const BUY_MISC:int = 40;
		static public const BUY_VIP:int = 45;
		static public const BUY_DISCOUNT:int = 46;
		static public const BUY_DECORATION:int = 47;
		static public const BUY_SHAMAN_SKILL:int = 48;
		static public const BUY_SHAMAN_BRANCH_RESET:int = 49;
		static public const BUY_SHAMAN_BRANCH:int = 50;
		static public const BUY_MANA_REGENERATION:int = 60;

		static public const BUY_ACCESSORY:int = 61;
		static public const BUY_SKIN:int = 62;
		static public const BUY_PACKAGE:int = 63;
		static public const BUY_PACKAGE_DAY:int = 64;

		// Sync
		static public const SYNC_ALL:int = 0;
		static public const SYNC_PLAYER:int = 1;

		//Nut
		static public const NUT_PICK:int = 0;
		static public const NUT_LOST:int = 1;

		// Ban_reason
		static public const BAN_REASON_WARNING:int = 1;
		static public const BAN_REASON_CHAT_SWEARING:int = 2;
		static public const BAN_REASON_PROFILE_SWEARING:int = 3;
		static public const MAP_VIOLATION:int = 4;
		static public const BAN_REASON_SOFTWARE_USING:int = 5;
		static public const AUTO_BAN:int = 6;
		static public const COLLECTION_AUTOBAN:int = 7;
		static public const BROKEN_WORLD_AUTOBAN:int = 8;
		static public const CHAT_VIOLATION:int = 9;
		static public const CHECKPOINTS_AUTOBAN:int = 10;
		static public const REPLAY_BAN:int = 11;

		// Ban_type
		static public const BAN_TYPE_NONE:int = 0;
		static public const BAN_TYPE_GAG:int = 1;
		static public const BAN_TYPE_BAN:int = 2;

		// Cast
		static public const CAST_SHAMAN:int = 0;
		static public const CAST_SQUIRREL:int = 1;

		// Clan
		static public const CLAN_ACCEPT_REJECT:int = 0;
		static public const CLAN_ACCEPT_INVITE:int = 1;

		// Chat
		static public const CHAT_ROOM:int = 0;
		static public const CHAT_CLAN:int = 1;
		static public const CHAT_COMMON:int = 2;
		static public const CHAT_NEWBIE:int = 3;

		// Chat Commands
		static public const CHAT_COMMAND_ENTER:int = 0;
		static public const CHAT_COMMAND_LEAVE:int = 1;

		// Counters
		static public const COUNT_BANK_OPENS:int = 36;
		static public const COUNT_BANK_PURCHASE:int = 37;
		static public const FULLSCREEN:int = 68;
		static public const CHANGE_ROOM:int = 91;
		static public const SHOP:int = 212;
		static public const INVITE_FRIENDS:int = 216;
		static public const FPS_ROUND:int = 229;
		static public const FPS_LOCATION:int = 230;
		static public const FPS_MAP:int = 231;
		static public const LEVEL_REPOST:int = 244;
		static public const SHAMAN_LEVEL_REPOST:int = 245;
		static public const CLICK_CHAT_BUTTON:int = 266;
		static public const CAN_REPOST:int = 273;
		static public const MAKE_REPOST:int= 274;
		static public const REPOST_FOLLOW:int = 275;
		static public const COUNT_OFFER_OK:int = 285;
		static public const VIRALITY_REPOST:int = 326;
		static public const TRAINING_POINTS:int = 345;
		static public const EXCHANGE_USED:int = 356;
		static public const MAP_DUPLICATE:int = 359;
		static public const PLANET_SHOW:int = 360;
		static public const DIALOG_CTR:int = 361;
		static public const NEWS_SITE_REDIRECT:int = 376;

		static private const FORMATS:Array = [
			"",					// MIN_TYPE(0);

			// Admin
			"BLB",					// ADMIN_REQUEST_NET(1); type:B, net_id:L, field:B
			"IB",					// ADMIN_REQUEST_INNER(2); inner_id:I, field:B
			"IB",					// ADMIN_REQUEST_CLAN(3); clan_id:I, field:B
			"IBA",					// ADMIN_EDIT_PLAYER(4); inner_id:I, field:B, data:A
			"IBA",					// ADMIN_EDIT_CLAN(5); id:I, field:B, data:A
			"I",					// ADMIN_CLEAR(6); inner_id:I
			"I",					// ADMIN_CLOSE_CLAN(7); clan_id:I
			"S",					// ADMIN_MESSAGE(8); message:S
			"IIB",					// SESSION_REQUEST(9); net_id_first:I, net_id_second:I, type:B

			"",					// HELLO(10);
			"LBBSII,S",				// LOGIN(11); net_id:L, type:B, isOAuth:B, auth_key:S, tag:I, referrer:I, session_key:S
			"B,B",					// PLAY(12); location_id:B, sublocation_id:B
			"",					// PLAY_CANCEL(13);
			"I",					// PLAY_WITH(14); player_id:I
			"I",					// SPY_FOR(15); player_id:I
			"I",					// PLAY_PRIVATE(16); room_id:I
			"",					// LEAVE(17);
			"[I]I",					// REQUEST(18); [player_id:I], mask:I
			"[L]BI",				// REQUEST_NET(19); [net_id:L], type:B, mask:I
			"SBISSS,S",				// INFO(20); name:S, sex:B, bday:I, photo:S, profile:S, email:S, country:S
			"",					// REFILL(21);
			"IBB",					// BAN(22); target_id:I, reason:B, repeated:B
			"III,II",				// BUY(23); good_id:I, coins_cost:I, nuts_cost:I, target_id:I, data:I
			"B",					// PING(24); is_cheater:B
			",I",					// LATENCY(25); latency:I
			"I,L",					// COUNT(26); type:I, data:L
			"BB",					// FLAGS_SET(27); flag:B, value:B
			"L",					// INVITE(28); inviter_id:L
			"B",					// CLEAR_TEMPORARY(29);
			"BB,I",					// ACHIEVEMENT(30); type:B, value:B
			"S",					// GUARD(31); answer:S
			"B,W",					// REPOST_NEWS(32); type:B, news_id:W,
			"",					// REQUEST_AWARD(33);
			"S",					// RENAME(34); name:S
			"[SS]",					// SIGN_XS(35); key:S, values:S
			"",					// BIRTHDAY_CELEBRATE(36);
			"",					// DAILY_BONUS_AWARD(37);
			"BB",					// PRODUCE_REQUEST(38); type:B, command:B

			"BA",					// STORAGE_SET(39); type:B, data:A
			"BB",					// TRAINING_SET(40); step:B, value:B
			"S",					// PROMO_CODE(41); code:S
			"",					// BUNDLE_NEWBIE_ACTIVATE(42);

			"",					// HOLIDAY_LOTTERY(43);

			"",					// RATING_REQUEST(44);
			"B",					// RATING_REQUEST_TOP(45); type:B

			// Friends
			"[L]",					// SOCIAL_FRIENDS(46); [friend_id:L]
			"[I]",					// FRIENDS_ADD(47); [friend_id:I]
			"I",					// FRIENDS_REMOVE(48); friend_id:I
			"[I]",					// FRIENDS_RETURN(49); friend_id:I
			"",					// FRIENDS_ONLINE(50);

			// Daily Quest
			"",					// DAILY_QUEST_REQUEST(51);
			"BB",					// DAILY_QUEST_ADD(52); index:B, score:B
			"B",					// DAILY_QUEST_COMPLETE(53); index:B

			// Chat
			"BS",					// CHAT_MESSAGE(54); chat_type:B, message:S
			"BB",					// CHAT_COMMAND(55); command:B, chat_type:B

			// Collection
			"BB",					// COLLECTION_ASSEMBLE(56); type:B, id:B
			"[B]",					// COLLECTION_EXCHANGE_ADD(57); [id:B]
			"[B]",					// COLLECTION_EXCHANGE_REMOVE(58); [id:B]
			"IBB",					// COLLECTION_EXCHANGE(59); target_id:I, my_item:B, his_item:B

			"",					// CLOTHES_REQUEST_CLOSEOUTS(60);
			"BWB",					// CLOTHES_WEAR(61); kind:B, clothes_id:W, is_weared:B
			"WW",					// CLOTHES_SET_SLOT(62); package:W, skill:W

			// Gift
			"[I]",					// GIFT_SEND(63); player_id:I
			"BI",					// GIFT_ACCEPT(64); status:B, id:I

			"I",					// DEFERRED_BONUS_ACCEPT(65); bonus_id:I

			// Event
			"L",					// EVENT_REMOVE(66); id:L

			// Round
			"",					// ROUND_ALIVE(67);
			"BFFFF,B",				// ROUND_HERO(68); state:B, pos_x:F, pos_y:F, velocity_x:F, velocity_y:F, health:B
			"BS",					// ROUND_CAST_BEGIN(69); type:B, data:S
			"BBB",					// ROUND_CAST_END(70); cast_type:B, item_id:B, result:B
			"B",					// ROUND_NUT(71); action:B
			"B,I",					// ROUND_HOLLOW(72); type:B, protected_checkpoints:I
			"FFB,I",				// ROUND_DIE(73); pos_x:F, pos_y:F, reason:B, killer:I
			",B",					// ROUND_RESPAWN(74); type:B
			"B[WFFFFFF]",				// ROUND_SYNC(75); type:B, [object_id:W, pos_x:F, pos_y:F, angle:F, velocity_x:F, velocity_y:F, torque:F]
			"IA",					// ROUND_WORLD(76); target_id:I, data:A
			"BBIS",					// ROUND_SKILL(77); id:B, state:B, target_id:I, script:S
			"BI,I",					// ROUND_SKILL_ACTION(78); id:B, target_id:I, data:I
			"BB",					// ROUND_SKILL_SHAMAN(79); skill_id:B, target_id:I
			"S",					// ROUND_COMMAND(80); data:S
			"B",					// ROUND_ELEMENT(81); element_index:B
			"IB",					// ROUND_VOTE(82); map_id:I, is_positive:B
			"B",					// ROUND_SMILE(83); smile_id:B
			"I",					// ROUND_ZOMBIE(84); player_id:I

			// Maps
			"BBB",					// MAPS_LIST(85); location_id:B, sublocation_id:B, mode:B
			"I",					// MAPS_GET(86); map_id:I
			"BWIA,BB",				// MAPS_ADD(87); mode:B, duration:W, length:I, data:A, location_id:B, sublocation_id:B
			"IBBBB,WIA",				// MAPS_EDIT(88); map_id:I, location_id:B, sublocation_id:B, mode:B, folder:B, duration:W, length:I, data:A
			"I",					// MAPS_REMOVE(89); map_id:I
			"I",					// MAPS_CLEAR_RATING(90); map_id:I
			",II",					// MAPS_CHECKS(91); moderator_id:I, count:I

			// Clan
			"S",					// CLAN_CREATE(92); name:S
			"SS",					// CLAN_INFO(93); photo:S, emblem:S
			"S",					// CLAN_RENAME(94); name:S
			"[I]B",					// CLAN_ACCEPT(95); player_id:I, result:B
			"",					// CLAN_LEAVE(96);
			"I",					// CLAN_INVITE(97); player_id:I
			"I",					// CLAN_JOIN(98); clan_id:I
			"I",					// CLAN_KICK(99); player_id:I
			"",					// CLAN_CLOSE(100);
			"II",					// CLAN_DONATION(101); coins:I, nuts:I
			"[I]I",					// CLAN_REQUEST(102); [clan_id:I], mask:I
			"I",					// CLAN_SUBSTITUTE(103); substitute_id:I
			"I",					// CLAN_UNSUBSTITUTE(104); substitute_id:I
			"",					// CLAN_GET_TRANSACTIONS(105);
			"",					// CLAN_GET_REQUESTS(106);
			"I",					// CLAN_GET_MEMBERS(107); clan_id:I
			"",					// CLAN_GET_ROOMS(108);
			"",					// CLAN_CHAT_ENTER(109);
			"",					// CLAN_CHAT_LEAVE(110);
			"S",					// CLAN_NEWS(111); news:S
			"BB",					// CLAN_TOTEM(112); slot:B, totem:B
			"I",					// CLAN_ADD_IN_BLACKLIST(113); players_id:I
			"I",					// CLAN_REMOVE_FROM_BLACKLIST(114); player_id:I
			"B",					// CLAN_LEVEL_LIMITER(115); level:B

			// Vip
			"B",					// VIP_COLOR(116); color:B

			// Discount
			"BI",					// DISCOUNT_USE(117); type:B, package_id:I

			"[BB]",					// INTERIOR_CHANGE(118); decoration_id:B, installed:B

			// Shaman game
			"B",					// LEARN_SHAMAN_SKILL(119); skill_id:B
			"B",					// CHANGE_SHAMAN_BRANCH(120); branch_id:B

			// Transfer
			"B,LSS",				// TRANSFER(121); command:B, net_id:L, auth_key:S, session_key:S

			"B",					// AB_GUI_ACTION(122); action:B

			"B",					// NY_MODE_TAKE(123); index:B
			"",					// NY_MODE_PLACE(124);

			"",					// ADMIN_REQUEST_PROMO(125);
			"SW",					// ADMIN_EDIT_PROMO(126); code:S, max_count:W
			"SBW",					// ADMIN_ADD_PROMO(127); code:S, bonus:B, max_count:W
			"W"					// SERVICE_CLICK(128); index:W
		];

		private static var packageIDs:Object = null;

		private var _type:int;
		private var _name:String;

		public function PacketClient(type:int):void
		{
			super();

			if (type <= 0 || type >= FORMATS.length)
				throw new Error("Unknown client packet type " + type);

			try {
				this._name = getNamePackage(type);
			} catch(e:*) {
				this._name = "undefined";
			}

			this._type = type;
			this.endian = Endian.LITTLE_ENDIAN;

			writeShort(type);
		}

		private function getNamePackage(type:int):String
		{
			if(!packageIDs)
			{
				packageIDs = {};

				var classXml:XMLList = describeType(getDefinitionByName(getQualifiedClassName(this)))..constant;
				for each(var item:XML in classXml)
				{
					if(item.@type != 'uint')
						continue;
					packageIDs[PacketClient[item.@name].toString()] = item.@name;
				}
			}
			return packageIDs[type.toString()] == null ? "undefined" : packageIDs[type.toString()];
		}

		public function load(rest:Array):void
		{
			var format:String = FORMATS[this._type];

			var optional:Boolean = false;

			var groupPos:int = 0;
			var groupLength:int = 0;

			var container:Array = rest;

			for (var i:int = 0; i < format.length; i++)
			{
				var symbol:String = format.charAt(i);

				if (symbol == ',')
				{
					if (optional || groupPos != 0)
						throw new Error("Bad signature for client packet " + this._type);

					optional = true;
					continue;
				}

				if (symbol == ']')
				{
					if (groupPos == 0)
						throw new Error("Bad signature for client packet " + this._type);

					groupLength--;

					if (groupLength != 0)
					{
						i = groupPos - 1;
						continue;
					}

					groupPos = 0;
					container = rest;
					continue;
				}

				if (symbol == '[')
				{
					if (groupPos != 0)
						throw new Error("Bad signature for server packet " + this._type);

					var last:int = getGroupLast(format, i);

					container = (rest.shift() as Array).slice();

					var count:int = last - i - 1;

					if (container.length % count != 0)
						throw new Error("Group incomplete for client packet " + this._type);

					groupLength = container.length / count;
					writeInt(groupLength);

					if (groupLength != 0)
					{
						groupPos = i + 1;
						continue;
					}

					i = last;
					container = rest;
					continue;
				}

				if (container.length == 0)
				{
					if (optional && groupPos == 0)
						break;
					throw new Error("No data for client packet " + this._type);
				}

				var value:* = container.shift();

				switch (symbol)
				{
					case 'A':
						writeInt(value.length);
						writeBytes(value);
						break;
					case 'S':
						writeUTF(value);
						writeByte(0);
						break;
					case 'F':
						writeFloat(value);
						break;
					case 'L':
						var result:UInt64 = new UInt64(String(value));
						result.write(this);
						break;
					case 'I':
						writeInt(value);
						break;
					case 'W':
						writeShort(value);
						break;
					case 'B':
						writeByte(value);
						break;
				}
			}

			if (rest.length)
				throw new Error("Data " + rest.length + " left in client packet " + this._type);
		}

		public function get type():int
		{
			return this._type;
		}

		private function getGroupLast(format:String, first:int):int
		{
			for (var last:int = first + 1; last < format.length; last++)
			{
				if (format.charAt(last) != ']')
					continue;
				if (last == first + 1)
					break;
				return last;
			}

			throw new Error("Bad signature for client packet " + this._type);
		}

		public function get name():String
		{
			return _name;
		}
	}
}