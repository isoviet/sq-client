package views
{
	import flash.display.BitmapData;

	import utils.BitmapPhotoLoader;

	public class ClanIconLoader extends BitmapPhotoLoader
	{
		static private const IMAGE_SIZE:int = 10;
		static private const DEFAULT_IMAGE:BitmapData = new ClanEmblemRastered();

		public function ClanIconLoader(url:String, x:int, y:int):void
		{
			super(url, x, y, IMAGE_SIZE, IMAGE_SIZE, DEFAULT_IMAGE);
		}
	}
}