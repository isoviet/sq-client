package sensors.events
{
	import flash.events.Event;

	public class DetectHeroEvent extends Event
	{
		static public const BEGIN_CONTACT:String = "BEGIN_CONTACT";
		static public const END_CONTACT:String = "END_CONTACT";

		static public const DETECTED:String = "DetectHeroEvent.detected";

		public var hero:Hero;
		public var state:String;
		public var showMovie:Boolean;

		public function DetectHeroEvent(hero:Hero, showMovie:Boolean = true, state:String = BEGIN_CONTACT):void
		{
			super(DETECTED);

			this.hero = hero;
			this.state = state;
			this.showMovie = showMovie;
		}
	}

}