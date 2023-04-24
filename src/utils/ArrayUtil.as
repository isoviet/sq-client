package utils
{
	public class ArrayUtil
	{
		static public function valuesToUnic(ids:Array):Array
		{
			var unic:Array = [];

			var existValues:Object = {};

			for (var i:int = 0; i < ids.length; i++)
			{
				if (typeof existValues[ids[i]] == "undefined" || existValues[ids[i]] == null)
					unic.push(ids[i]);

				existValues[ids[i]] = ids[i];
			}

			return unic;
		}

		static public function valuesToUnicVec(ids:Array):Vector.<int>
		{
			var unic:Vector.<int> = new Vector.<int>();

			var existValues:Object = {};

			for (var i:int = 0; i < ids.length; i++)
			{
				if (typeof existValues[ids[i]] == "undefined" || existValues[ids[i]] == null)
					unic.push(ids[i]);

				existValues[ids[i]] = ids[i];
			}

			return unic;
		}

		static public function arrayIntToVector(array:*):Vector.<int>
		{
			if (array is Vector)
				return array;

			var vec:Vector.<int> = new Vector.<int>();

			for (var i:int = 0, len: int = array.length; i < len; i++)
				vec[vec.length] = int(array[i]);

			return vec;
		}

		static public function compareArrays(array1:Array, array2:Array):Boolean
		{
			if (array1.length != array2.length)
				return false;

			for (var i:int = 0; i < array1.length; i++)
			{
				if (array1[i] != array2[i])
					return false;
			}

			return true;
		}

		static public function getDifference(a:Array, b:Array):Array
		{
			return a.filter(function(item:int, index:int, array:Array):Boolean
			{
				return b.indexOf(item) == -1;
			});
		}

		static public function generateByteFromExistingInt(haveId:Array, maxCount:int):Array
		{
			var byteArray:Array = [];

			var newLength:int = (maxCount + 7) / 8;

			for (var i:int = 0; i < newLength; i++)
			{
				var newByte:int = 0;
				byteArray.push(newByte);
			}

			for (i = 0; i < haveId.length; i++)
				byteArray[int(haveId[i] / 8)] |= 0x01 << (haveId[i] % 8);

			return byteArray;
		}

		static public function parseByteArray(bytes:Array):Array
		{
			if (bytes == null)
				return null;

			var result:Array = [];

			for (var i:int = 0; i < bytes.length; i++)
			{
				result.push(bytes[i] & 0x01);
				result.push(bytes[i] & 0x02);
				result.push(bytes[i] & 0x04);
				result.push(bytes[i] & 0x08);
				result.push(bytes[i] & 0x10);
				result.push(bytes[i] & 0x20);
				result.push(bytes[i] & 0x40);
				result.push(bytes[i] & 0x80);
			}

			return result;
		}

		static public function parseUIntArray(data:Array):Array
		{
			var newArray:Array = [];

			for (var i:int = 0; i < data.length; i++)
				newArray.push(int(data[i] & 0xFF));

			return newArray;
		}

		static public function parseUIntVector(data:Vector.<int>):Array
		{
			var newArray:Array = [];

			for (var i:int = 0; i < data.length; i++)
				newArray.push(int(data[i] & 0xFF));

			return newArray;
		}

		static public function parseIntVector(data:Vector.<int>):Array
		{
			var newArray:Array = [];

			for (var i:int = 0; i < data.length; i++)
				newArray.push(int(data[i]));

			return newArray;
		}

	}
}