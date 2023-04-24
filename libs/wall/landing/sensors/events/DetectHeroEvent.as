package landing.sensors.events
{
	import flash.events.Event;

	public class DetectHeroEvent extends Event
	{
		static public const DETECTED:String = "DetectHeroEvent.detected";

		public var hero:wHero;

		public function DetectHeroEvent(hero:wHero):void
		{
			super(DETECTED);

			this.hero = hero;
		}

	}

}