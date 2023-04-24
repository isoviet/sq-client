package game.mainGame.events
{
	import flash.events.Event;

	import game.mainGame.CastItem;

	public class CastItemEvent extends Event
	{
		static public const ITEM_ADD:String = "CastItemEvent.ITEM_ADD";
		static public const ITEM_CHANGE:String = "CastItemEvent.ITEM_CHANGE";
		static public const ITEM_END:String = "CastItemEvent.AMOUNT_END";
		static public const TAPE_UPDATE:String = "CastItemEvent.TAPE_UPDATE";

		public var castItem:CastItem = null;

		public function CastItemEvent(type:String, item:CastItem):void
		{
			super(type);

			this.castItem = item;
		}

		public override function clone():Event
		{
			return new CastItemEvent(type, this.castItem);
		}

		public override function toString():String
		{
			return formatToString("CastItemEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}