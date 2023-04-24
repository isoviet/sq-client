package
{
	import flash.utils.ByteArray;

	import protocol.PacketServer;

	public class ClanInfoParser
	{
		//счетчик - должен инициализироваться раньше данных
		static private var type:uint = 0;

		static public const INFO:uint = (1 << type);
		static public const NEWS:uint = (1 << ++type);
		static public const LEADER_ID:uint = (1 << ++type);
		static public const SIZE:uint = (1 << ++type);
		static public const STATE:uint = (1 << ++type);
		static public const RANK:uint = (1 << ++type);
		static public const RANK_RANGE:uint = (1 << ++type);
		static public const PLACES:uint = (1 << ++type);
		static public const BAN:uint = (1 << ++type);
		static public const TOTEMS:uint = (1 << ++type);
		static public const TOTEMS_RANGS:uint = (1 << ++type);
		static public const TOTEMS_BONUSES:uint = (1 << ++type);
		static public const STATISICS:uint = (1 << ++type);
		static public const BLACKLIST:uint = (1 << ++type);
		static public const LEVEL_LIMITER:uint = (1 << ++type);
		static public const ALL:uint = all;
		static public const ADMIN_BALANCE:uint = (1 << ++type);

		static public const FORMATS:Object = {
			(INFO.toString()):		["SSS", "info", 3],
			(NEWS.toString()):		["S", "news"],
			(LEADER_ID.toString()):		["I", "leader_id"],
			(SIZE.toString()):		["I", "size"],
			(STATE.toString()):		["B", "state"],
			(RANK.toString()):		["BII", "rank", 3],
			(RANK_RANGE.toString()):	["I", "rank_range"],
			(PLACES.toString()):		["I", "places"],
			(BAN.toString()):		["I", "ban"],
			(TOTEMS.toString()):		["[BIB]I", "totems", 2],
			(TOTEMS_RANGS.toString()):	["[BBII]", "totems_rangs"],
			(TOTEMS_BONUSES.toString()):	["[BB]", "totems_bonuses"],
			(STATISICS.toString()):		["[III]", "statistics"],
			(BLACKLIST.toString()):		["[I]", "blacklist"],
			(LEVEL_LIMITER.toString()):	["B", "level_limiter"],
			(ADMIN_BALANCE.toString()):	["II", "balance", 2]
		};

		static public function parse(data:ByteArray, mask:uint):Array
		{
			data.position = 0;

			var format:String = "[I";
			var fields:Array = ["id", 1];
			var dataLength:int = 1;

			for (var i:int = 0; i <= ClanInfoParser.type; i++)
			{
				var bit:uint = 1 << i;

				if ((mask & bit) == 0)
					continue;

				if (!(bit in FORMATS))
					break;

				format += FORMATS[bit][0];

				fields.push(FORMATS[bit][1]);

				var count:int = (FORMATS[bit].length > 2 ? FORMATS[bit][2] : 1);
				fields.push(count);
				dataLength += count;
			}

			format += "]";

			Logger.add("Parsing clan_info format " + format + " for mask " + mask);

			var output:Array = [];

			PacketServer.readData(data, format, output);

			if (output.length == 0)
				return [];

			output = output.pop();

			Logger.add("Parsing clan_info contains " + output.length + " fields for " + (output.length / dataLength) + " clans");

			var result:Array = [];
			for (i = 0; i < output.length; i += dataLength)
			{
				var dataP:Object = {};
				var dataId:int = i;

				for (var key:int = 0; key < fields.length; key += 2)
				{
					if (fields[key + 1] == 1)
					{
						dataP[fields[key]] = output[dataId++];
						continue;
					}

					dataP[fields[key]] = [];
					for (var j:int = 0; j < fields[key + 1]; j++)
						dataP[fields[key]].push(output[dataId++]);
				}

				if ("info" in dataP)
				{
					dataP['name'] = dataP['info'][0];
					dataP['photo'] = dataP['info'][1];
					dataP['emblem'] = dataP['info'][2];
				}

				if ("balance" in dataP)
				{
					dataP['coins'] = dataP['balance'][0];
					dataP['acorns'] = dataP['balance'][1];
				}

				result.push(dataP);
			}

			return result;
		}

		static private function get all():uint
		{
			var result:uint = 0;

			for (var i:uint = 0; i <= type; i++)
			{
				result |= 1 << i;
			}

			return result;
		}
	}
}