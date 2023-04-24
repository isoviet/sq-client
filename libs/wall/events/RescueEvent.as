package events 
{
	import flash.events.Event;

	public class RescueEvent extends Event
	{
		static public const RESCUE:String = "hostigesRescued";

		public function RescueEvent(type:String):void
		{
			super(type);
		}
	}
}