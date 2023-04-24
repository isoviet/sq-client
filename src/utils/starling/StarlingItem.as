package utils.starling
{
	public class StarlingItem
	{
		private var _item:*;
		private var _dispose: Boolean = true;
		private var _userData: *;

		public function StarlingItem(child:*, dispose: Boolean = true, userData: * = null)
		{
			item = child;
			_dispose = dispose;
			_userData = userData;
		}

		public function get item():*
		{
			return _item;
		}

		public function set item(value:*):void
		{
			_item = value;
		}

		public function get dispose(): Boolean
		{
			return _dispose;
		}

		public function set dispose(value: Boolean):void
		{
			_dispose = value;
		}

	}
}