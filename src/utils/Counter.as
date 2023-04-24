package utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Counter extends EventDispatcher
	{
		private var _count:int = 0;

		public function Counter(count:int = 0):void
		{
			this.count = count;
		}

		public function get count():int
		{
			return this._count;
		}

		public function set count(value:int):void
		{
			if (this._count == value)
				return;

			this._count = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}