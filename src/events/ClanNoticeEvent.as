package events
{
	import flash.events.Event;

	public class ClanNoticeEvent extends Event
	{
		static public const CLAN_NEWS_CHANGED:String = "ClanNoticeEvent.CLAN_NEWS_CHANGED";
		static public const CLAN_SUBLEADERS_CHANGED:String = "ClanNoticeEvent.CLAN_SUBLEADERS_CHANGED";
		static public const CLAN_TRANSACTIONS_UPDATE:String = "ClanNoticeEvent.CLAN_TRANSACTIONS_UPDATE";

		public function ClanNoticeEvent(type:String):void
		{
			super(type, false, true);
		}

		public override function clone():Event
		{
			return new ClanNoticeEvent(type);
		}

		public override function toString():String
		{
			return formatToString("ClanNoticeEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}