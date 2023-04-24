package events
{
	import flash.events.Event;

	public class PostEvent extends Event
	{
		static public const REMOVE_EVENT:String = "PostEvent.REMOVE_EVENT";

		public var id:int = -1;

		public function PostEvent(id:int):void
		{
			super(REMOVE_EVENT);

			this.id = id;
		}
	}
}