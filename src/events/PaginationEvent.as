package events
{
	import flash.events.Event;

	public class PaginationEvent extends Event
	{
		static public const NAME:String = "pagination";

		public var number:int;

		public function PaginationEvent(number:int):void
		{
			super(NAME);

			this.number = number;
		}
	}
}