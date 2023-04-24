package protocol
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import utils.UInt64;

	public dynamic class PacketServer extends Array
	{
		// Login
		static public const LOGIN_SUCCESS:int = 0;
		static public const LOGIN_FAILED:int = 1;
		static public const LOGIN_EXIST:int = 2;
		static public const LOGIN_BLOCKED:int = 3;
		static public const LOGIN_WRONG_VERSION:int = 4;

		//Editor
		static public const EDITOR_NONE:int = 0;
		static public const EDITOR_FULL:int = 1;
		static public const EDITOR_APPROVAL:int = 3;
		static public const EDITOR_APPROVAL_PLUS:int = 4;
		static public const EDITOR_SUPER:int = 5;

		// Play
		static public const PLAY_OFFLINE:int = 0;
		static public const PLAY_FAILED:int = 1;
		static public const NOT_EXIST:int = 2;
		static public const FULL_ROOM:int = 3;
		static public const NOT_IN_CLAN:int = 4;
		static public const UNAVAIABLE_LOCATION:int = 5;
		static public const LOW_ENERGY:int = 7;

		// Buy
		static public const BUY_SUCCESS:int = 0;
		static public const BUY_PRICE_CHANGED:int = 1;
		static public const BUY_NO_BALANCE:int = 2;
		static public const BUY_FAIL:int = 3;

		// Round
		static public const ROUND_WAITING:int = 0;
		static public const ROUND_STARTING:int = 1;
		static public const ROUND_PLAYING:int = 2;
		static public const ROUND_RESULTS:int = 3;
		static public const ROUND_START:int = 4;
		static public const ROUND_CUT:int = 5;

		// Events
		static public const MAIL_DEMO:int = -1;
		static public const MAP_APPROVED:int = 0;
		static public const MAP_REJECTED:int = 1;
		static public const CLAN_ACCEPT:int = 4;
		static public const CLAN_REJECT:int = 5;
		static public const CLAN_INVITE:int = 6;
		static public const CLAN_KICK:int = 7;
		static public const CLAN_CLOSE_EVENT:int = 8;
		static public const CLAN_NEWS_EVENT:int = 9;
		static public const CLAN_BLOCK_EVENT:int = 10;
		static public const FRIEND_QUEST_EVENT:int = 11;
		static public const EXCHANGE_EVENT:int = 12;
		static public const RETURNER_AWARD:int = 19;
		static public const MAP_RETURN:int = 21;
		static public const AMUR_MAIL:int = 22;

		// Exchange
		static public const EXCHANGE_SUCCESS:int = 0;
		static public const EXCHANGE_FAIL:int = 1;

		//Assemble
		static public const ASSEMBLE_SUCCESS:int = 0;
		static public const ASSEMBLE_FAIL:int = 1;

		//offers
		static public const OFFER_GOLDEN_CUP:int = 20;

		// Rooms
		static public const ROOM_NOT_EXIST_CLAN:int = 0;
		static public const ROOM_NOT_EXIST:int = 1;
		static public const ROOM_EXPIRED:int = 2;
		static public const ROOM_FULL:int = 3;

		// Skills
		static public const SKILL_DEACTIVATE:int = 0;
		static public const SKILL_ACTIVATE:int = 1;
		static public const SKILL_ERROR:int = 2;

		// Clan
		static public const CLAN_STATE_SUCCESS:int = 0;
		static public const CLAN_STATE_ERROR:int = 1;
		static public const CLAN_STATE_NO_BALANCE:int = 2;
		static public const CLAN_STATE_CLOSED:int = 3;
		static public const CLAN_STATE_BLOCKED:int = 4;
		static public const CLAN_STATE_BANNED:int = 6;
		static public const CLAN_BLACKLIST:int = 7;
		static public const CLAN_LOW_LEVEL:int = 8;

		static public const CLAN_TRANSACTION_DONATION:int = 0;
		static public const CLAN_TRANSACTION_ROOM:int = 1;
		static public const CLAN_TRANSACTION_RENAME:int = 2;
		static public const CLAN_TRANSACTION_PLACES:int = 3;
		static public const CLAN_TRANSACTION_BOOSTER:int = 4;
		static public const CLAN_TRANSACTION_TOTEM:int = 5;

		static public const CLAN_SUBSTITUTE_FIRE:int = 0;
		static public const CLAN_SUBSTITUTE_ADDED:int = 1;

		// Respawn
		static public const RESPAWN_CLAN_TOTEM:int = 0;
		static public const RESPAWN_LOW_LEVEL:int = 1;
		static public const RESPAWN_DRAGON:int = 2;
		static public const RESPAWN_DEATH:int = 3;
		static public const RESPAWN_FREE_HARD:int = 6;
		static public const RESPAWN_VIP:int = 7;
		static public const RESPAWN_HEAVENS_GATE:int = 9;
		static public const RESPAWN_IMMORTAL:int = 10;

		static public const RESPAWN_SUCCESS:int = 0;
		static public const RESPAWN_FAIL:int = 1;

		// Join
		static public const JOIN_PLAYING:int = 0;
		static public const JOIN_START:int = 1;

		// Beats
		static public const BEAST_DRAGON:int = 0;
		static public const BEAST_HARE:int = 1;

		//Compensation
		static public const SHAMAN_COMPENSATION:int = 0;
		static public const DRAGON_COMPENSATION:int = 1;

		// Award_reason
		static public const REASON_FRIEND_GIFT:int = 14;
		static public const REASON_HIPSTER_AWARDING:int = 15;
		static public const REASON_INVITER_REWARDING:int = 16;
		static public const REASON_NURSE_AWARDING:int = 20;
		static public const REASON_QUEST:int = 21;
		static public const REASON_RABBIT_KILLING:int = 22;
		static public const REASON_REFILLING:int = 24;
		static public const REASON_RETURNER_REWARDING:int = 25;
		static public const REASON_SHAMAN_KILLING:int = 30;
		static public const REASON_SHAMAN_RESCUING:int = 31;
		static public const REASON_SPENT:int = 33;
		static public const REASON_TRAINING:int = 34;
		static public const REASON_WINNING:int = 35;
		static public const REASON_ENERGY_RETURN:int = 36;
		static public const REASON_LEPRECHAUN_AWARDING:int = 38;
		static public const REASON_SHAMAN_SURRENDER:int = 43;
		static public const REASON_DAILY:int = 48;
		static public const REASON_DISCOUNT:int = 49;
		static public const REASON_GOLDEN_CUP:int = 50;
		static public const REASON_HOLIDAY_LOTTERY:int = 57;
		static public const REASON_HOLIDAY_TICKETS:int = 58;
		static public const REASON_GIFT:int = 60;
		static public const REASON_AMUR:int = 61;
		static public const REASON_CELEBRATE:int = 62;
		static public const REASON_HOT_WEEKEND:int = 63;
		static public const REASON_HOLIDAY_BOOSTER:int = 64;
		static public const REASON_HOT_WHEELS:int = 65;

		static public function readData(buffer:ByteArray, format:String, output:Array):void
		{
			var optional:Boolean = false;

			var groups:Array = [output];

			for (var i:int = 0; i < format.length; i++)
			{
				var symbol:String = format.charAt(i);

				var groupCur:Array = groups[groups.length - 1];

				if (symbol == ',')
				{
					if (optional || groupCur != output)
						throw new Error("Bad signature 2 for server packet");

					optional = true;
					continue;
				}

				if (symbol == ']')
				{
					if (groupCur == output)
						throw new Error("Bad signature 3 for server packet");

					groupCur.group_length--;

					if (groupCur.group_length != 0)
					{
						i = groupCur.group_pos;
						continue;
					}

					delete groupCur.group_length;
					delete groupCur.group_pos;

					groups.pop();
					continue;
				}

				if (buffer.bytesAvailable == 0)
				{
					if (optional && groupCur == output)
						break;
					throw new Error("No data for server packet");
				}

				if (symbol == '[')
				{
					var groupNew:Array = [];
					groupNew.group_length = buffer.readUnsignedInt();

					groupCur.push(groupNew);

					if (groupNew.group_length != 0)
					{
						groupNew.group_pos = i;
						groups.push(groupNew);
						continue;
					}

					i = getGroupLast(format, i);
					trace(i);

					continue;
				}

				switch (symbol)
				{
					case 'A':
						var length:uint = buffer.readUnsignedInt();
						var array:ByteArray = new ByteArrayGame();
						array.position = 0;
						array.endian = Endian.LITTLE_ENDIAN;
						if (length != 0)
							buffer.readBytes(array, 0, length);
						groupCur.push(array);
						break;
					case 'S':
						groupCur.push(buffer.readUTF());
						buffer.readByte();
						break;
					case 'F':
						groupCur.push(buffer.readFloat());
						break;
					case 'L':
						var result:UInt64 = new UInt64(buffer);
						groupCur.push(result.toString());
						break;
					case 'I':
						groupCur.push(buffer.readInt());
						break;
					case 'W':
						groupCur.push(buffer.readShort());
						break;
					case 'B':
						groupCur.push(buffer.readByte());
						break;
				}
			}
		}

		static private function getGroupLast(format:String, first:int):int
		{
			var left:int = 1;
			for (var last:int = first + 1; last < format.length; last++)
			{
				switch (format.charAt(last))
				{
					case ']':
						left--;
						break;
					case '[':
						left++;
						break;
				}

				if (left != 0)
					continue;
				if (last == first + 1)
					break;
				return last;
			}

			throw new Error("Bad signature 1 for server packet");
		}
	}
}