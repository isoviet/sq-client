package events 
{
	import flash.events.Event;

	public class MovieClipPlayCompleteEvent extends Event
	{
		static public const SHAMAN:String = "shamanPlayComplete";
		static public const DEATH:String = "deathPlayComplete";

		public function MovieClipPlayCompleteEvent(type:String):void
		{
			super(type);
		}
	}
}