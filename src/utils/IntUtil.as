package utils
{
	public class IntUtil
	{
		static public function randomInt(low:int, hight:int):int
		{
			return low + Math.round(Math.random() * (hight - low));
		}

		static public function round(number:Number, count:int = 0):Number
		{
			if (int(number) == number)
				return number;

			var base:int = Math.pow(10, count);

			return (Math.round(number * base) / base);
		}

		static public function parseDigits(value:int):Vector.<int>
		{
			var digits:Vector.<int> = new Vector.<int>();
			var length:int = value.toString().length - 1;
			var temp:int = 0;

			for (var i:int = length; i >= 0; i--)
			{
				var digit:int = int((value - temp) / Math.pow(10, i));
				digits.push(digit);
				temp += digit * Math.pow(10, i);
			}

			return digits;
		}
	}
}