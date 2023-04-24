package locale
{
	import flash.utils.ByteArray;

	public class Locale
	{
		private var defaultLocale:String;
		private var langPack:ByteArray;

		private var strings:Object = null;

		public function Locale(defaultLocale:String, langPack:ByteArray)
		{
			this.defaultLocale = defaultLocale;
			this.langPack = langPack;
		}

		static public function replace(input:String, params:Array):String
		{
			for (var i:* in params)
			{
				while (true)
				{
					var prev:String = input;
					input = input.replace("{" + i + "}", params[i]);
					if (prev == input)
						break;
				}
			}

			return input;
		}

		public function gls(input:String, params:Array):String
		{
			return replace(get(input), params);
		}

		private function get(input:String):String
		{
			if (Config.LOCALE == this.defaultLocale)
				return input;

			if (this.strings == null)
				this.strings = loadStrings();

			if (!(input in this.strings))
			{
				Logger.add("Warning: String not found:\'" + input + "\'");
				return input;
			}

			var result:String = this.strings[input][Config.LOCALE];
			if (result == "NAN")
				Logger.add("Warning: Locale string not found! '" + input + "' Locale:" + Config.LOCALE);

			if (result.match(new RegExp("[А-Яа-яЁё]", "g")).length > 0)
				Logger.add("Warning: Locale string contains RU characters! '" + input + "' Locale:" + Config.LOCALE);

			return result;
		}

		private function loadStrings():Object
		{
			var strings:Object = {};
			var ba:ByteArray = this.langPack;

			var s:String = ba.readUTFBytes(ba.length);
			var splitResult:Array = s.split(new RegExp("(\t)|(\n)"));

			var length:int = int(splitResult.length / 6) * 6;
			for (var i:int = 0; i < length; i += 6)
			{
				splitResult[i] = (splitResult[i] as String).replace(new RegExp("\\\\n", "g"), "\n");
				splitResult[i] = (splitResult[i] as String).replace(new RegExp("\\\\t", "g"), "\t");
				splitResult[i] = (splitResult[i] as String).replace(new RegExp("\\\\\"", "g"), "\"");
				splitResult[i] = (splitResult[i] as String).replace(new RegExp("\\\\\-", "g"), "\-");
				splitResult[i] = (splitResult[i] as String).replace(new RegExp("(\\\\){2}", "g"), "\\");
				splitResult[i + 3] = (splitResult[i + 3] as String).replace(new RegExp("\\\\n", "g"), "\n");
				splitResult[i + 3] = (splitResult[i + 3] as String).replace(new RegExp("\\\\t", "g"), "\t");
				splitResult[i + 3] = (splitResult[i + 3] as String).replace(new RegExp("\\\\\"", "g"), "\"");
				splitResult[i + 3] = (splitResult[i + 3] as String).replace(new RegExp("\\\\\-", "g"), "\-");
				splitResult[i + 3] = (splitResult[i + 3] as String).replace(new RegExp("(\\\\){2}", "g"), "\\");

				strings[splitResult[i]] = {};
				strings[splitResult[i]][Config.LOCALE] = splitResult[i + 3];
			}

			return strings;
		}
	}
}