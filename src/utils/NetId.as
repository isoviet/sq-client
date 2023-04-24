package utils
{
	import flash.utils.ByteArray;

	public final class NetId
	{
		private var high: UInt64 = null;
		private var low: UInt64 = null;

		public function NetId(buffer:*)
		{
			if (buffer is ByteArray)
			{
				this.high = new UInt64(buffer);
				this.low = new UInt64(buffer);
			}
			else if (buffer is String)
			{
				var ints: Vector.<Number> = stringToInts(buffer);

				this.high = new UInt64(null, ints[0], ints[1]);
				this.low = new UInt64(null, ints[2], ints[3]);
			}
		}

		public function write(buffer:ByteArray):void
		{
			this.high.write(buffer);
			this.low.write(buffer);
		}

		public function toString():String
		{
			return (IntsToString(this.high.highValue, this.high.lowValue, this.low.highValue, this.low.lowValue));
		}

		// Приватные функции

		// Функции для парсинга
		// Длинное деление
		private function longDivision(divident: Vector.<Number>, quotient: Number): Object
		{
			var i: Number = 0;
			var dividentPart: Number = 0;
			var resultDigits: Vector.<Number> = new Vector.<Number>();
			var nextDigit: Number = 0;

			do
			{
				dividentPart = dividentPart * 10 + divident[i];
				if (dividentPart >= quotient)
				{
					nextDigit = (dividentPart / quotient) | 0;
					resultDigits.push(nextDigit);
					dividentPart = dividentPart - nextDigit * quotient;
				}
				else if (resultDigits.length)
					resultDigits.push(0);

				i++;
			}
			while (i < divident.length);

			return {
				result : resultDigits,
				modulo : dividentPart
			};
		}

		// преобразование строки в 4 uint32 числа
		private function stringToInts(str: String): Vector.<Number>
		{
			var inputVec: Vector.<Number> = null;

			var result: Vector.<Number> = new <Number>[0, 0, 0, 0];
			var intIndex: Number = result.length - 1;

			var wordIndex: Number = 0;
			var offset: Number = 1;

			inputVec = stringSanitize(str);

			var div: Object;
			do
			{
				div = longDivision(inputVec, 0x10000);
				inputVec = div.result;

				result[intIndex] += div.modulo * offset;

				wordIndex++;
				offset *= 0x10000;

				if (wordIndex >= 2 || !inputVec.length)
				{
					wordIndex = 0;
					offset = 1;
					intIndex--;
				}
			}

			while(inputVec.length);

			return result;
		}

		// чистка строки и преобразование ее в массив цифр
		private function stringSanitize(string: String): Vector.<Number>
		{
			var digits: Vector.<Number> = new Vector.<Number>();

			for (var i: Number = 0, length: Number = string.length; i < length; ++i)
			{
				if (string.charCodeAt(i) < 48 || string.charCodeAt(i) > 57)
					return digits;

				digits.push(parseInt(string.charAt(i)));
			}

			return digits;
		}

		// функции для преобразования в строку
		// преобразование uint32 числа в массив цифр
		private function numberToArray(number: Number): Vector.<Number>
		{
			var result: Vector.<Number> = new Vector.<Number>();

			while (number != 0)
			{
				result.push(number % 10);
				number = Math.floor(number / 10);
			}

			return result;
		}

		// преобразование строки-числа в массив цифр
		private function stringToArray(number: String): Vector.<Number>
		{
			var result: Vector.<Number> = new Vector.<Number>();

			for (var i: Number = 0, len: Number = number.length; i < len; i++)
				result.unshift(parseInt(number.charAt(i), 10));

			return result;
		}

		// длинное умножение
		private function longMultiply(a: Vector.<Number>, b: Vector.<Number>): Vector.<Number>
		{
			var i: Number = 0;
			var j: Number = 0;
			var remainder: Number = 0;
			var result: Vector.<Number> = new Vector.<Number>();

			for (i = 0; i < a.length; ++i)
			{
				for (remainder = 0, j = 0; j < b.length || remainder > 0; ++j)
				{
					result.length = Math.max(i + j + 1, result.length);

					result[i + j] = (remainder += (result[i + j] || 0) + a[i] * (b.length > j ? b[j] : 0)) % 10;
					remainder = Math.floor(remainder / 10);
				}
			}

			return result;
		}

		// длинное суммирование
		private function LongSum(a: Vector.<Number>, b: Vector.<Number>): Vector.<Number>
		{
			var i: Number = 0;
			var remainder: Number = 0;
			var length: Number = Math.max(a.length, b.length);

			for (i = 0; i < length || remainder > 0; ++i)
			{
				a.length = Math.max(i + 1, a.length);
				a[i] = (remainder += (a.length > i ? a[i] : 0) + (b.length > i ? b[i] : 0)) % 10;
				remainder = Math.floor(remainder / 10);
			}

			return a;
		}

		// массив цифр в строку
		private  function arrayToString(array: Vector.<Number>): String
		{
			if (array.length === 0)
				return '0';

			var string: String = '';

			for (var i: Number = 0, length: Number = array.length; i < length; i++)
				string = array[i] + string;

			return string;
		}

		// преобразование в строку
		private function IntsToString(highHigh: Number, highLow: Number, lowHigh: Number, lowHow: Number): String
		{
			var highHighV: Vector.<Number> = longMultiply(numberToArray(highHigh), stringToArray('79228162514264337593543950336')); // high_high * 0x1000000000000000000000000
			var highLowV: Vector.<Number> = longMultiply(numberToArray(highLow), stringToArray('18446744073709551616')); // high_low *	0x10000000000000000
			var lowHighV: Vector.<Number> = longMultiply(numberToArray(lowHigh), stringToArray('4294967296')); // low_high *0x100000000
			var lowLowV: Vector.<Number> = numberToArray(lowHow);

			return arrayToString(LongSum(LongSum(highHighV, highLowV), LongSum(lowHighV, lowLowV)));
		}

		public function isShort(): Boolean
		{
			return this.high.highValue === 0 && this.high.lowValue === 0;
		}
	}
}