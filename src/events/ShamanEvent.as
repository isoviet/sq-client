package events
{
	import flash.events.Event;

	public class ShamanEvent extends Event
	{
		static public const NAME:String = "Shaman.make";

		public var className:Class;

		public function ShamanEvent(className:Class):void
		{
			super(NAME);

			this.className = className;
		}
	}
}