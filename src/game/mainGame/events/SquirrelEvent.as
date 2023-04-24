package game.mainGame.events
{
	import flash.events.Event;

	public class SquirrelEvent extends Event
	{
		static public const ACORN:String = "SquirrelEvent.acorn";
		static public const SHAMAN:String = "SquirrelEvent.shaman";
		static public const SCRAT:String = "SquirrelEvent.scrat";
		static public const HARE:String = "SquirrelEvent.hare";
		static public const DRAGON:String = "SquirrelEvent.dragon";
		static public const RESET:String = "SquirrelEvent.reset";
		static public const RESPAWN:String = "SquirrelEvent.respawn";
		static public const HIDE:String = "SquirrelEvent.hide";
		static public const DIE:String = "SquirrelEvent.die";
		static public const LEAVE:String = "SquirrelEvent.leave";
		static public const JOIN:String = "SquirrelEvent.join";
		static public const TEAM:String = "SquirrelEvent.team";
		static public const EMOTION:String = "SquirrelEvent.emotion";
		static public const OLYMPIC_COIN:String = "SquirrelEvent.olympicCoin";
		static public const GHOST:String = "SquirrelEvent.ghost";
		static public const RESPAWN_POINT:String = "SquirrelEvent.respawnPoint";

		public var player:Hero;

		public function SquirrelEvent(type:String, player:Hero):void
		{
			super(type);

			this.player = player;
		}
	}
}