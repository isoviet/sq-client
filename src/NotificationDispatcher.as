package
{
	import flash.events.EventDispatcher;

	import events.NotificationEvent;

	public class NotificationDispatcher extends EventDispatcher
	{
		static private var _instance:NotificationDispatcher;

		public function NotificationDispatcher()
		{
			super();
		}

		static public function get instance():NotificationDispatcher
		{
			return _instance ||= new NotificationDispatcher();
		}

		static public function show(id:int):void
		{
			instance.dispatchEvent(new NotificationEvent(NotificationEvent.SHOW, id));
		}

		static public function hide(id:int):void
		{
			instance.dispatchEvent(new NotificationEvent(NotificationEvent.HIDE, id));
		}
	}
}