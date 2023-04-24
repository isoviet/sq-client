package com.api
{
	import flash.events.Event;

	public class WallEvent extends Event
	{
		static public const WALL_SAVE:String = "wall save";
		static public const WALL_CANCEL:String = "wall cancel";

		public function WallEvent(name:String):void
		{
			super(name);
		}
	}
}