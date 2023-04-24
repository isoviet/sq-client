package views
{
	import utils.PhotoLoader;

	public class ClanPhotoLoader extends PhotoLoader
	{
		static private const IMAGE_SIZE:int = 50;

		public function ClanPhotoLoader(url:String, x:int, y:int, size:int = IMAGE_SIZE):void
		{
			super(url, x, y, size, size, DefaultClanPhoto);
		}
	}
}