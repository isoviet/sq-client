package utils.starling.collections
{
	import utils.starling.StarlingItem;

	public class DrawObjectCollection
	{
		protected var objects:Object = {};

		public function add(className:String, item:*, dispose: Boolean = true, from:String = ''): StarlingItem
		{
			prepareForClassName(className);
			var starlingItem: StarlingItem = new StarlingItem(item, dispose);
			objects[className].push(starlingItem);
			return starlingItem;
		}

		public function remove(className:String, item:*, dispose: Boolean = true):void
		{
			if (objects[className] is Vector.<StarlingItem>){
				delete objects[className];
			}
		}

		public function getItem(className:String):Vector.<StarlingItem>
		{
			prepareForClassName(className);
			return objects[className];
		}

		public function existClass(className:String):Boolean
		{
			return objects[className] && objects[className].length ? true : false;
		}

		protected function prepareForClassName(className:String):void
		{
			if (!objects[className])
			{
				objects[className] = new Vector.<StarlingItem>();
			}
		}
	}
}