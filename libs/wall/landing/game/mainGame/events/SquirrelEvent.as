package landing.game.mainGame.events
{
	import flash.events.Event;

	public class SquirrelEvent extends Event
	{
		static public const HOLLOW:String = "SquirrelEvent.hollow";
		static public const ACORN:String = "SquirrelEvent.acorn";
		static public const DIE:String = "SquirrelEvent.die";
		static public const LEAVE:String = "SquirrelEvent.leave";
		static public const JOIN:String = "SquirrelEvent.join";

		public var player:wHero;

		public function SquirrelEvent(type:String, player:wHero):void
		{
			super(type);

			this.player = player;
		}
	}
}