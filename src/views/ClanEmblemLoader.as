package views
{
	import utils.PhotoLoader;

	public class ClanEmblemLoader extends PhotoLoader
	{
		static private const IMAGE_SIZE:int = 10;

		public function ClanEmblemLoader(url:String, x:int, y:int, size:int = IMAGE_SIZE):void
		{
			super(url, x, y, size, size, DefaultEmblemPhoto, true);
		}
	}
}