package events
{
	import flash.events.Event;

	public class LoggerEvent extends Event
	{
		static public var MESSAGE:String = "LoggerEvent.MESSAGE";
		public var message:String;
		public function LoggerEvent(type:String, message:String)
		{
			super(type);
			this.message = message;
		}
	}
}