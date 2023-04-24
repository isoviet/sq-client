package utils
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;

	public class StringUtil
	{

		static private const NUMERALS:Array = [
			gls("первым"),
			gls("вторым"),
			gls("третьим"),
			gls("четвертым"),
			gls("пятым"),
			gls("шестым"),
			gls("седьмым"),
			gls("восьмым"),
			gls("девятым"),
			gls("десятым"),
			gls("одиннадцатым"),
			gls("двенадцатым"),
			gls("тринадцатым"),
			gls("четырнадцатым"),
			gls("пятнадцатым")
		];

		static private const WORDS:Object = {
			'балл':		[gls("баллов"), gls("балл"), gls("балла")],
			'день':		[gls("дней"), gls("день"), gls("дня")],
			'час':		[gls("часов"), gls("час"), gls("часа")],
			'минуту':	[gls("минут"), gls("минуту"), gls("минуты")],
			'минута':	[gls("минут"), gls("минута"), gls("минуты")],
			'секунду':	[gls("секунд"), gls("секунду"), gls("секунды")],
			'голос':	["голосов", "голос", "голоса"],
			'рубль':	[gls("рублей"), gls("рубль"), gls("рубля")],
			'побед':	[gls("побед"), gls("победа"), gls("победы")],
			'единица':	[gls("единиц"), gls("единица"), gls("единицы")],
			'друг':		[gls("друзей"), gls("друг"), gls("друга")],
			'ваш':		[gls("ваших"), gls("ваш"), gls("ваших")],
			'раунд':	[gls("раундов"), gls("раунд"), gls("раунда")],
			'OK':		["OK", "OK", "OK"],
			'мэйлик':	["мейликов", "мейлик", "мейлика"],
			'орехов':	[gls("орехов"), gls("орех"), gls("ореха")],
			'монет':	[gls("монет"), gls("монета"), gls("монеты")],
			'монетку':	[gls("монеток"), gls("монетку"), gls("монетки")],
			'твой друг':	[gls("твоих друзей"), gls("твой друг"), gls("твоих друга")],
			'играть':	[gls("играют"), gls("играет"), gls("играют")],
			'звезда':	[gls("звезд"), gls("звезда"), gls("звезды")],
			'подарок':	[gls("подарков"), gls("подарок"), gls("подарка")],
			'ФМ':		["ФМ", "ФМ", "ФМ"],
			'предмет':	[gls("предметов"), gls("предмет"), gls("предмета")],
			'кредит':	[gls("кредитов"), gls("кредит"), gls("кредита")],
			'участник':	[gls("участников"), gls("участник"), gls("участника")],
			'белка':	[gls("белок"), gls("белка"), gls("белки")],
			'человек':	[gls("человек"), gls("человек"), gls("человека")],
			'заряд':	[gls("зарядов"), gls("заряд"), gls("заряда")],
			'штука':	[gls("штук"), gls("штука"), gls("штуки")],
			'маны':		[gls("маны"), gls("ману"), gls("маны")],
			'перо':		[gls("перьев"), gls("перо"), gls("пера")],
			'очко':		[gls("очков"), gls("очко"), gls("очка")],
			'бонусное очко':[gls("бонусных очков"), gls("бонусное очко"), gls("бонусных очка")],

			'случайного друга':		[gls("случайных друзей"), gls("случайного друга"), gls("случайных друзей")]
		};

		static public function getNumerals(value:int):String
		{
			return NUMERALS[value - 1];
		}

		static public function stripHTML(value:String):String
		{
			value = XML(new XMLNode(XMLNodeType.TEXT_NODE, value)).toXMLString();
			value = StringUtil.trim(value);

			return value;
		}

		static public function removeHtmlTags(value:String):String
		{
			value = value.replace(new RegExp("<[^><]*>", "gi"), "");
			return value;
		}

		static public function word(value:String, count:int):String
		{
			if (!(value in WORDS))
				return "";

			var values:Array = WORDS[value];

			if (count % 100 >= 10 && count % 100 <= 20 && Config.isRus)
				return values[0];

			var remaind:int = count % 10;

			if (remaind == 1)
				return values[1];
			if (remaind >= 2 && remaind <= 4 && Config.isRus)
				return values[2];
			return values[0];
		}

		static public function short(value:String, maxCount:int):String
		{
			if (value.length <= maxCount)
				return value;

			return value.substr(0, maxCount - 1);
		}

		static public function shortByWidth(field:TextField, maxWidth:int):void
		{
			do
			{
				if (field.width <= maxWidth)
					break;

				field.text = field.text.substr(0, field.text.length - 1);
			}
			while (true);
		}

		static public function shortBySize(field:TextField, maxWidth:int):void
		{
			do
			{
				if (field.textWidth <= maxWidth)
					break;
				var format:TextFormat = field.getTextFormat();
				format.size = int(format.size) - 1;
				field.setTextFormat(format);
			}
			while (true);
		}

		static public function trim(input:String):String
		{
			return StringUtil.ltrim(StringUtil.rtrim(input));
		}

		static public function ltrim(input:String):String
		{
			var size:Number = input.length;
			for (var i:Number = 0; i < size; i++)
			{
				if (input.charCodeAt(i) > 32)
					return input.substring(i);
			}
			return "";
		}

		static public function rtrim(input:String):String
		{
			var size:Number = input.length;
			for (var i:Number = size; i > 0; i--)
			{
				if (input.charCodeAt(i - 1) > 32)
					return input.substring(0, i);
			}
			return "";
		}

		static public function formatDate(time:int, withDay:Boolean = false):String
		{
			if (withDay)
			{
				var days:int = int(time / (24 * 60 * 60));
				time = time % (24 * 60 * 60);
				var timeString:String = new Date(0, 0, 0, 0, 0, time).toTimeString().slice(0, 8);
				if (days > 0)
					timeString = days + " " + StringUtil.word("день", days) + " " + timeString;
			}
			else
			{
				var hours:int = int(time / (60 * 60));
				timeString = new Date(0, 0, 0, 0, 0, time).toTimeString().slice(2, 8);
				timeString = (hours > 9 ? hours : "0" + hours) + timeString;
			}

			return timeString;
		}

		static public function formatName(name:String, width:int):String
		{
			var field:TextField = new TextField();
			field.text = name;

			while (field.textWidth > width)
			{
				field.text = name;
				name = name.substr(0, name.length - 1);
			}
			return name;
		}

		static public function jointArray(array:Array, delimter:String = ", "):String
		{
			var result:String = "";
			for (var i:int = 0; i < array.length; i++)
			{
				result += array[i];
				if (i != array.length - 1)
					result += delimter;
			}
			return result;
		}

		static public function StringToByteArray(input:String):Array
		{
			var ba:ByteArray = new ByteArray();
			ba.writeUTF(input);
			ba.position = 0;
			var result:Array = [];
			while (ba.bytesAvailable > 0)
				result.push(ba.readByte());

			return result;
		}

		static public function ByteArrayToString(input:Array):String
		{
			var ba:ByteArray = new ByteArray();
			var array:Array = input.slice();
			while (array.length > 0)
				ba.writeByte(array.shift());
			ba.position = 0;

			return ba.readUTF();
		}

		static public function MapLength(map:String):int
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeUTFBytes(map);
			return byteArray.length;
		}

		static public function MapToByteArray(map:String):ByteArray
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeUTFBytes(map);
			byteArray.compress();
			return byteArray;
		}

		static public function ByteArrayToMap(byteArray:ByteArray):String
		{
			byteArray.uncompress();
			var map:String = byteArray.readUTFBytes(byteArray.length);
			return map;
		}
	}
}