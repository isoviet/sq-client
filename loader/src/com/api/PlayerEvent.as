package com.api
{
	import flash.events.Event;

	public class PlayerEvent extends Event
	{
		static public const NAME:String = "onPlayerLoaded";

		public var player:Player;

		public function PlayerEvent(player:Player):void
		{
			super(NAME);
			this.player = player;
		}
	}
}