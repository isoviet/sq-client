package landing.game
{
	import flash.display.DisplayObject;

	public class Backgrounds
	{
		static private const DATA:Array = [
			WallBackgroundImage
		];

		static public const SIMPLE:int = 0;

		static public function get():Array
		{
			return DATA;
		}

		static public function getImage(id:int):DisplayObject
		{
			var imageClass:Class = DATA[id];

			var image:DisplayObject = new imageClass();
			image.cacheAsBitmap = true;

			return image;
		}
	}
}