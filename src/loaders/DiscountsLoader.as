package loaders
{
	import flash.events.Event;

	public class DiscountsLoader extends LoaderBase
	{
		CONFIG::inner
		{
			[Embed(source = "../../content/ru/discounts.swf", mimeType = "application/octet-stream")]
			static private var DISCOUNTS:Class;
		}
		CONFIG::external
		{
			static private const DISCOUNTS:String = "discounts";
		}

		static private var _instance:DiscountsLoader = null;

		public function DiscountsLoader():void
		{
			_instance = this;
		}

		static public function load(callback:Function = null):void
		{
			_instance.loadDiscounts(callback);
		}

		static public function get loaded():Boolean
		{
			return _instance.loaded;
		}

		override protected function onLoaded(e:Event):void
		{
			super.onLoaded(e);

			super.loaded = true;

			doCallbacks();
		}

		private function loadDiscounts(callback:Function = null):void
		{
			super.load(DISCOUNTS, callback);
		}
	}
}