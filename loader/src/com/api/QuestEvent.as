package com.api
{
	import flash.events.Event;

	public class QuestEvent extends Event
	{
		static public const LIKED:String = "isLiked";
		static public const GROUP:String = "isGroup";

		public function QuestEvent(status:String):void
		{
			super(status);
		}
	}
}