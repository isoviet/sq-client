package events
{
	import flash.events.Event;

	public class DiscountEvent extends Event
	{
		static public const START:String = "DISCOUNT_START";
		static public const END:String = "DISCOUNT_END";

		static public const BONUS_START:String = "BONUS_START";
		static public const BONUS_END:String = "BONUS_END";

		public var id:int = -1;

		public function DiscountEvent(id:int, isStart:Boolean = true, isBonus:Boolean = false):void
		{
			super((isBonus ? "BONUS_" : "DISCOUNT_") + (isStart ? "START" : "END"));

			this.id = id;
		}
	}
}