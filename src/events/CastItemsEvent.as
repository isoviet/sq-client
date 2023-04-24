package events
{
	import flash.events.Event;

	public class CastItemsEvent extends Event
	{
		static public const UPDATE:String = "CastItemsEvent.UPDATE";

		public var items:Array = null;

		public function CastItemsEvent(type:String, items:Array):void
		{
			super(type);

			this.items = items;
		}
	}
}