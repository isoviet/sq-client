package tape.list.events
{
	import flash.events.Event;

	import tape.list.ListElement;

	public class ListElementEvent extends Event
	{
		static public const CHANGED:String = "ListElementEvent.CHANGED";

		public var listElement:ListElement;

		public function ListElementEvent(type:String, listElement:ListElement):void
		{
			super(type);

			this.listElement = listElement;
		}
	}
}