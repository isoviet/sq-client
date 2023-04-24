package events
{
	import flash.events.Event;

	public class ApplicationsUpdateEvent extends Event
	{
		static public const NAME:String = "onAplicationsCountChanged";

		public var count:int;

		public function ApplicationsUpdateEvent(count:int):void
		{
			super(NAME);

			this.count = count;
		}
	}
}