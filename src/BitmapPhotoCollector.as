package
{
	import flash.display.BitmapData;

	public class BitmapPhotoCollector
	{
		static private const AGE:int = 2;

		static private var bitmapStorage:Object = {};

		static public function addBitmapData(url:String, bitmapData:BitmapData = null):BitmapData
		{
			if (url in bitmapStorage)
			{
				bitmapStorage[url]['age'] = AGE;
				return bitmapStorage[url]['data'];
			}

			if (!bitmapData)
				return null;

			bitmapStorage[url] = {};
			bitmapStorage[url]['data'] = bitmapData;
			bitmapStorage[url]['age'] = AGE;
			return bitmapData;
		}

		static public function clearBitmapData(all:Boolean = false):void
		{
			var clearIds:Array = [];

			for (var url:String in bitmapStorage)
			{
				if (bitmapStorage[url] == null || bitmapStorage[url]['data'] == null)
				{
					clearIds.push(url);
					continue;
				}

				bitmapStorage[url]['age']--;

				if (!all && bitmapStorage[url]['age'] > 0)
					continue;

				if ("data" in bitmapStorage[url])
				{
					bitmapStorage[url]['data'].dispose();
					bitmapStorage[url]['data'] = null;
					delete bitmapStorage[url]['data'];
				}

				bitmapStorage[url] = null;

				clearIds.push(url);
			}

			for each(url in clearIds)
				delete bitmapStorage[url];
		}
	}
}