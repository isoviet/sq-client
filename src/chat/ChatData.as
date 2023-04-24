package chat
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class ChatData extends Sprite
	{
		public var waitMessages:Vector.<ChatMessage> = new Vector.<ChatMessage>;
		public var messages:Vector.<ChatMessage> = new Vector.<ChatMessage>;
		public var scrollPos:int = 0;

		public function ChatData():void
		{}

		public function dispose():void
		{
			this.messages = new Vector.<ChatMessage>;

			for (var i:int = 0; i < this.waitMessages.length; i++)
				this.waitMessages[i].removeEventListener("MESSAGE_UPDATE", processWaitMessages);

			this.waitMessages = new Vector.<ChatMessage>;

			clearText();
		}

		public function clearText():void
		{}

		public function setWidth(value:int):void
		{}

		public function sendMessage(text:String):void
		{}

		public function addMessage(message:ChatMessage, force:Boolean = false):void
		{
			if (force)
			{
				message.removeEventListener("MESSAGE_UPDATE", processWaitMessages);

				this.messages.push(message);
				onMessageAdd(message);
				return;
			}

			if (this.waitMessages.indexOf(message) != -1)
				return;

			this.waitMessages.push(message);
			message.addEventListener("MESSAGE_UPDATE", processWaitMessages);
			processWaitMessages();
		}

		public function onShow():void
		{}

		protected function onMessageAdd(message:ChatMessage):void
		{
			if (message) {/*unused*/}

			dispatchEvent(new Event("CHANGED"));
		}

		private function processWaitMessages(e:Event = null):void
		{
			while (this.waitMessages.length != 0 && this.waitMessages[0].canAdd)
				addMessage(this.waitMessages.shift(), true);
		}
	}
}