package events
{
	import flash.events.Event;

	import clans.Clan;

	public class ClanEvent extends Event
	{
		static public const NAME:String = "onClanLoaded";

		public var clan:Clan;
		public var fromCache:Boolean;

		public function ClanEvent(clan:Clan, fromCache:Boolean):void
		{
			super(NAME);

			this.clan = clan;
			this.fromCache = fromCache;
		}
	}
}