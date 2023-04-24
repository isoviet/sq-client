package events
{
	import flash.events.Event;

	public class NewBackgroundEvent extends Event
	{
		static public const NAME:String = "newBacground";

		public var id:int;

		public function NewBackgroundEvent(id:int):void
		{
			super(NAME);

			this.id = id;
		}
	}
}