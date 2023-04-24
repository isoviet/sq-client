package utils
{
	public class ArrayUtil
	{
		static public function valuesToUnic(ids:Array):Array
		{
			var unic:Array = new Array();

			var existValues:Object = new Object();

			for (var i:int = 0; i < ids.length; i++)
			{
				if (typeof existValues[ids[i]] == "undefined" || existValues[ids[i]] == null)
					unic.push(ids[i]);

				existValues[ids[i]] = ids[i];
			}

			return unic;
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

		static public function generateByteFromExistingInt(haveId:Array, maxCount:int):Array
		{
			var byteArray:Array = new Array();

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

			var result:Array = new Array();

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
	}
}