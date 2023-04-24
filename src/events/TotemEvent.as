package events
{
	import flash.events.Event;

	public class TotemEvent extends Event
	{
		static public const BUY_SLOT:String = "BUY";
		static public const CHANGE_TOTEM:String = "CHANGE";

		public var number:int = 0;

		public function TotemEvent(type:String, number:int = 0)
		{
			super(type);

			this.number = number;
		}
	}
}