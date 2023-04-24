package landing.sensors
{
	import flash.events.Event;

	public class PortalSensorEvent extends Event
	{
		static public const CONTACT:String = "PortalSensorEvent.CONTACT";

		public var hero:wHero = null;

		public function PortalSensorEvent(type:String, hero:wHero):void
		{
			super(type);

			this.hero = hero;
		}
	}
}