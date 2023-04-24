package tape.list.events
{
	import flash.events.Event;

	import tape.list.ListData;

	public class ListDataEvent extends Event
	{
		static public const UPDATE:String = "ListDataEvent.UPDATE";
		static public const SORTED:String = "ListDataEvent.SORTED";

		public var data:ListData;

		public function ListDataEvent(type:String, data:ListData):void
		{
			super(type);

			this.data = data;
		}
	}
}