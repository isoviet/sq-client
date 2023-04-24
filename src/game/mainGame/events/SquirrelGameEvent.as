package game.mainGame.events
{
	import flash.events.Event;

	public class SquirrelGameEvent extends Event
	{
		static public const UPDATE_BONUS:String = "SquirrelGameEvent.UPDATE_BONUS";

		public function SquirrelGameEvent(type:String):void
		{
			super(type);
		}
	}
}