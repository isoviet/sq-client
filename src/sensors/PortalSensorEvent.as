package sensors
{
	import flash.events.Event;

	public class PortalSensorEvent extends Event
	{
		static public const CONTACT:String = "PortalSensorEvent.CONTACT";

		public var hero:Hero = null;

		public function PortalSensorEvent(type:String, hero:Hero):void
		{
			super(type);

			this.hero = hero;
		}
	}
}