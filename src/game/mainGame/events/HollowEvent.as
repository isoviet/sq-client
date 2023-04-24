package game.mainGame.events
{
	import flash.events.Event;

	public class HollowEvent extends Event
	{
		static public const HOLLOW:String = "HollowEvent.hollow";

		public var player:Hero;
		public var hollowType:int = -1;

		public function HollowEvent(hero:Hero, hollowType:int):void
		{
			super(HOLLOW);
			this.player = hero;
			this.hollowType = hollowType;
		}
	}
}