package utils
{
	import flash.utils.ByteArray;

	public final class UInt64
	{
		private var high:Number = 0;
		private var low:Number = 0;

		public function UInt64(buffer:*, high: Number = 0, low: Number = 0):void
		{
			this.high = high;
			this.low = low;

			if (buffer is ByteArray)
				readByteArray(buffer);
			else if (buffer is String)
				readString(buffer);
		}

		static public function to64(low:uint, high:uint):UInt64
		{
			var answer:UInt64 = new UInt64(null);
			answer.low = low;
			answer.high = high;

			return answer;
		}

		private function readByteArray(buffer:ByteArray):void
		{
			this.low = buffer.readUnsignedInt();
			this.high = buffer.readUnsignedInt();
		}

		private function readString(buffer:String):void
		{
			for (var i:int = 0; i < buffer.length; i++)
			{
				var sym:int = int(buffer.charAt(i));

				this.low *= 10;
				this.high *= 10;

				this.low += sym;

				if (this.low < 0xFFFFFFFF)
					continue;

				var left:uint = uint(this.low / 0x100000000);
				this.high += left;

				this.low = uint(this.low);
			}
		}

		public function get highValue(): Number
		{
			return high;
		}

		public function set highValue(value: Number): void
		{
			high = value;
		}

		public function get lowValue(): Number
		{
			return low;
		}

		public function set lowValue(value: Number): void
		{
			low = value;
		}

		public function write(buffer:ByteArray):void
		{
			buffer.writeUnsignedInt(this.low);
			buffer.writeUnsignedInt(this.high);
		}

		public function toHex():String
		{
			var lowS:String = '00000000' + this.low.toString(16);
			lowS = lowS.substr(lowS.length - 8, 8);

			var result:String = '0000000000' + this.high.toString(16) + lowS;
			result = result.substr(result.length - 10, 10).toUpperCase();

			return result;
		}

		public function toString():String
		{
			if (this.high == 0)
				return String(this.low);

			var result:String = "";

			var lowCopy:Number = this.low;
			var highCopy:Number = this.high;

			while (highCopy != 0)
			{
				var left:Number = highCopy % 10;
				highCopy = uint(highCopy / 10);

				lowCopy += left * 0x100000000;

				result = String(lowCopy % 10) + result;
				lowCopy = uint(lowCopy / 10);
			}

			return String(lowCopy) + result;
		}
	}
}