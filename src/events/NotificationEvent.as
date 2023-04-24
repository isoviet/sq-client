package events
{
	import flash.events.Event;

	public class NotificationEvent extends Event
	{
		static public const SHOW:String = "NotificationEvent.SHOWED";
		static public const HIDE:String = "NotificationEvent.HIDED";

		public var notificationType:int;

		public function NotificationEvent(type:String, notificationType:int)
		{
			super(type);

			this.notificationType = notificationType;
		}
	}
}