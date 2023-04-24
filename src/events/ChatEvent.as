package events
{
	import flash.events.Event;

	import chat.ChatDeadMessage;

	public class ChatEvent extends Event
	{
		static public const REMOVE:String = "REMOVE";

		public var message:ChatDeadMessage;

		public function ChatEvent(message:ChatDeadMessage):void
		{
			super(REMOVE);

			this.message = message;
		}
	}
}