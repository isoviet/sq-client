package game.mainGame.events
{
	import flash.events.Event;

	public class AchieveEvent extends Event
	{
		static public const DOUBLE_KILL:String = "AchieveEvent.doubleKill";
		static public const TRIPLE_KILL:String = "AchieveEvent.tripleKill";
		static public const MEGA_KILL:String = "AchieveEvent.megaKill";
		static public const FIRST_BLOOD:String = "AchieveEvent.firstBlood";
		static public const INVULNERABLE:String = "AchieveEvent.invulnerable";
		static public const RAMBO:String = "AchieveEvent.rambo";
		static public const COMEBACK:String = "AchieveEvent.comeback";
		static public const REVENGE:String = "AchieveEvent.revenge";
		static public const SNIPER:String = "AchieveEvent.sniper";

		public function AchieveEvent(type:String):void
		{
			super(type);
		}

		public override function clone():Event
		{
			return new AchieveEvent(type);
		}

		public override function toString():String
		{
			return formatToString("AchieveEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}