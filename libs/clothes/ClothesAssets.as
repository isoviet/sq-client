package
{
	public class ClothesAssets
	{
		[Embed(source = "swf/clothesMagick.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_0:Class;

		[Embed(source = "swf/clothesTo53.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_1:Class;

		[Embed(source = "swf/clothesTo102.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_2:Class;

		[Embed(source = "swf/clothesTo150.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_3:Class;

		[Embed(source = "swf/clothesTo202.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_4:Class;

		[Embed(source = "swf/clothesTo254.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_5:Class;

		[Embed(source = "swf/clothesTo303.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_6:Class;

		[Embed(source = "swf/clothesTo352.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_7:Class;

		[Embed(source = "swf/clothesTo403.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_8:Class;

		[Embed(source = "swf/clothesTo433.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_9:Class;

		[Embed(source = "swf/clothesTo444.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_10:Class;

		[Embed(source = "swf/clothesTo500.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_11:Class;

		[Embed(source = "swf/clothes11.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_12:Class;

		[Embed(source = "swf/clothes12.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_13:Class;

		[Embed(source = "swf/clothes13.swf", mimeType = "application/octet-stream")]
		static private var CLOTHES_14:Class;

		static public var DATA:Array = [CLOTHES_0, CLOTHES_1, CLOTHES_2, CLOTHES_3, CLOTHES_4, CLOTHES_5, CLOTHES_6, CLOTHES_7, CLOTHES_8, CLOTHES_9, CLOTHES_10, CLOTHES_11, CLOTHES_12, CLOTHES_13, CLOTHES_14];

		static public function getClassById(clothesId:int):Class
		{
			if (clothesId < 0)
				return DATA[0];

			if (clothesId <= 53)
				return DATA[1];

			if (clothesId <= 102)
				return DATA[2];

			if (clothesId <= 150)
				return DATA[3];

			if (clothesId <= 202)
				return DATA[4];

			if (clothesId <= 254)
				return DATA[5];

			if (clothesId <= 303)
				return DATA[6];

			if (clothesId <= 352)
				return DATA[7];

			if (clothesId <= 403)
				return DATA[8];

			if (clothesId <= 433)
				return DATA[9];

			if (clothesId <= 444)
				return DATA[10];

			if (clothesId <= 500)
				return DATA[11];

			if (clothesId <= 600)
				return DATA[12];

			if (clothesId <= 700)
				return DATA[13];

			if (clothesId <= 800)
				return DATA[14];

			return null;
		}
	}
}