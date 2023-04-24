package utils.starling.collections
{
	import starling.display.Image;

	import utils.starling.StarlingItem;

	public class ImageCollection extends DrawObjectCollection
	{
		private static var _instance:ImageCollection;

		public static function getInstance():ImageCollection
		{
			if (!_instance)
			{
				_instance = new ImageCollection();
			}

			return _instance;
		}

		override public function add(className:String, item:*, dispose: Boolean = true, from: String = ''):StarlingItem
		{
			if (item is Image)
			{
				return super.add(className, item, dispose);
			}
			else
			{
				trace('error! ImageCollection items is not image!', item);
			}
			return null;
		}
	}
}