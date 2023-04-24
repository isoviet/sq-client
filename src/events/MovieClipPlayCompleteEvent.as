package events
{
	import flash.events.Event;

	public class MovieClipPlayCompleteEvent extends Event
	{
		static public const SHAMAN:String = "Movie.shaman";
		static public const DEATH:String = "Movie.death";

		public function MovieClipPlayCompleteEvent(type:String):void
		{
			super(type);
		}
	}
}