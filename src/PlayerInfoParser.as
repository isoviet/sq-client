package
{
	import flash.utils.ByteArray;

	import protocol.PacketServer;
	import protocol.packages.server.structs.PacketLoginShamanInfo;

	import utils.ArrayUtil;

	public class PlayerInfoParser
	{
		//счетчик - должен инициализироваться раньше данных
		static private var type:uint = 0;

		static public const NET_ID:uint = (1 << type);
		static public const TYPE:uint = (1 << ++type);
		static public const MODERATOR:uint = (1 << ++type);
		static public const NAME:uint = (1 << ++type);
		static public const SEX:uint = (1 << ++type);
		static public const PHOTO:uint = (1 << ++type);
		static public const ONLINE:uint = (1 << ++type);
		static public const INFO:uint = (1 << ++type);
		static public const EXPERIENCE:uint = (1 << ++type);
		static public const WEARED:uint = (1 << ++type);
		static public const CLAN:uint = (1 << ++type);
		static public const COLLECTION_EXCHANGE:uint = (1 << ++type);
		static public const IS_GONE:uint = (1 << ++type);
		static public const CLAN_TOTEM:uint = (1 << ++type);
		static public const VIP_INFO:uint = (1 << ++type);
		static public const INTERIOR:uint = (1 << ++type);
		static public const SHAMAN_EXP:uint = (1 << ++type);
		static public const SHAMAN_SKILLS:uint = (1 << ++type);
		static public const RATING_INFO:uint = (1 << ++type);
		static public const RATING_HISTORY:uint = (1 << ++type);
		static public const RATING_HOLIDAY:uint = (1 << ++type);
		static public const TROPHIES:uint = (1 << ++type);

		static public const ALL:uint = all;

		static public const FORMATS:Object = {
			(NET_ID.toString()):			["L", "nid"],
			(TYPE.toString()):			["B", "type"],
			(MODERATOR.toString()):			["B", "moderator"],
			(NAME.toString()):			["S", "name"],
			(SEX.toString()):			["B", "sex"],
			(PHOTO.toString()):			["S", "photo_big"],
			(ONLINE.toString()):			["B", "online"],
			(INFO.toString()):			["ISI", "person_info", 3],
			(EXPERIENCE.toString()):		["I", "exp"],
			(WEARED.toString()):			["[W][W]", "weared", 2],
			(CLAN.toString()):			["I", "clan_id"],
			(COLLECTION_EXCHANGE.toString()):	["[B]", "collection_exchange"],
			(IS_GONE.toString()):			["B", "is_gone"],
			(CLAN_TOTEM.toString()):		["I", "clan_totem"],
			(VIP_INFO.toString()):			["BB", "vip_info", 2],
			(INTERIOR.toString()):			["[B]", "interior"],
			(SHAMAN_EXP.toString()):		["I", "shaman_exp"],
			(SHAMAN_SKILLS.toString()):		["[BBB]", "shaman_skills"],
			(RATING_INFO.toString()):		["III", "rating_info", 3],
			(RATING_HISTORY.toString()):		["[WI]", "rating_history"],
			(RATING_HOLIDAY.toString()):		["I", "rating_holiday"],
			(TROPHIES.toString()):			["[BWB]", "trophies"]
		};

		static public var replaceName:String = "";

		static public function parse(data:ByteArray, mask:uint):Array
		{
			data.position = 0;

			var format:String = "[I";
			var fields:Array = ["uid", 1];
			var dataLength:int = 1;

			for (var i:int = 0; i <= PlayerInfoParser.type; i++)
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

			Logger.add("Parsing info format " + format + " for mask " + mask);

			var output:Array = [];
			PacketServer.readData(data, format, output);

			if (output.length == 0)
				return [];

			output = output.pop();

			Logger.add("Parsing info contains " + output.length + " fields for " + (output.length / dataLength) + " players");

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
					}
					else
					{
						dataP[fields[key]] = [];
						for (var j:int = 0; j < fields[key + 1]; j++)
							dataP[fields[key]].push(output[dataId++]);
					}
				}

				if ("name" in dataP)
					dataP['name'] = dataP['name'] == "" ? replaceName : dataP['name'];

				if ("person_info" in dataP)
				{
					dataP['bdate'] = dataP['person_info'][0];
					dataP['profile'] = dataP['person_info'][1];
					dataP['referrer'] = dataP['person_info'][2];
				}

				CONFIG::client
				{
					if ("exp" in dataP)
						dataP['level'] = Experience.getRegularLevel(dataP['exp']);
					if ("collection_exchange" in dataP)
						dataP['collection_exchange'] = ArrayUtil.parseUIntArray(dataP['collection_exchange']);
					if ("shaman_exp" in dataP)
						dataP['shaman_level'] = ShamanExperience.getLevel(dataP['shaman_exp']);
				}

				if ("weared" in dataP)
				{
					dataP['weared_packages'] = dataP['weared'][0];
					dataP['weared_accessories'] = dataP['weared'][1];
					Logger.add("Player ", dataP['uid'], "packages:", dataP['weared_packages'], "accessories:", dataP['weared_accessories']);
				}

				if ("vip_info" in dataP)
				{
					dataP['vip_exist'] = dataP['vip_info'][0];
					dataP['vip_color'] = dataP['vip_info'][1];
				}

				if ("rating_info" in dataP)
				{
					dataP['rating_score'] = dataP['rating_info'][0];
					dataP['rating_player'] = dataP['rating_info'][1];
					dataP['rating_shaman'] = dataP['rating_info'][2];
				}

				if ("shaman_skills" in dataP)
				{
					var newData:Array = [];

					for (var k:int = 0; k < dataP['shaman_skills'].length; k += 3)
						newData.push([dataP['shaman_skills'][k], dataP['shaman_skills'][k + 1], dataP['shaman_skills'][k + 2]]);

					var temp:Array;
					for (var _i:int = 0; _i < newData.length - 1; _i++)
						for (var _j:int = 0; _j < newData.length - 1 - _i; _j++)
							if (newData[_j][0] > newData[_j + 1][0])
							{
								temp = newData[_j];
								newData[_j] = newData[_j + 1];
								newData[_j + 1] = temp;
							}
					var len:int = newData.length;
					var dataSkills:Vector.<PacketLoginShamanInfo> = new Vector.<PacketLoginShamanInfo>();
					var bytes:ByteArray = new ByteArray();
					for(var byteId:int = 0; byteId < len; byteId++)
					{
						bytes.writeByte(newData[byteId][0]);
						bytes.writeByte(newData[byteId][1]);
						bytes.writeByte(newData[byteId][2]);
						bytes.position = 0;
						dataSkills.push(new PacketLoginShamanInfo(bytes));
						bytes.clear();
					}
					dataP['shaman_skills'] = dataSkills;
				}
				result.push(dataP);
			}

			return result;
		}

		static private function get all():uint
		{
			var result:uint = 0;

			for (var i:uint = 0; i <= type; i++)
				result |= 1 << i;

			return result;
		}
	}
}