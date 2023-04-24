package chat
{
	import flash.events.Event;

	import fl.containers.ScrollPane;
	import fl.events.ScrollEvent;

	import buttons.ButtonTabGroup;
	import events.ButtonTabEvent;

	public class ChatTabs extends ChatBase
	{
		protected var tabs:ButtonTabGroup = null;

		protected var scrollPane:ScrollPane = null;

		protected var chats:Vector.<ChatData> = new Vector.<ChatData>;
		protected var _currentChat:ChatData;

		public function ChatTabs()
		{
			super();
		}

		public function add(chat:ChatData):void
		{
			this.chats.push(chat);
			if (!_currentChat)
				this.currentChat = chat;
		}

		public function get currentChat():ChatData
		{
			return _currentChat;
		}

		public function set currentChat(value:ChatData):void
		{
			if (_currentChat == value || value == null)
				return;

			if (_currentChat)
				_currentChat.removeEventListener("CHANGED", onNewMessage);

			_currentChat = value;
			_currentChat.setWidth(this.scrollPane.width - 20);
			_currentChat.addEventListener("CHANGED", onNewMessage);

			this.scrollPane.source = _currentChat;
			this.scrollPane.update();

			this.currentChat.onShow();
			this.scroll = this.currentChat.scrollPos;
		}

		override protected function init():void
		{
			super.init();

			this.scrollPane = new ScrollPane();
			this.scrollPane.verticalScrollBar.addEventListener(ScrollEvent.SCROLL, onScroll);
			addChild(this.scrollPane);

			this.tabs = new ButtonTabGroup();
			addChild(this.tabs);
		}

		protected function onScroll(e:ScrollEvent):void
		{
			if (this.currentChat)
				this.currentChat.scrollPos = this.scroll;
		}

		protected function onTabSelect(e:ButtonTabEvent):void
		{
			this.scroll = 0;
		}

		protected function onNewMessage(e:Event):void
		{
			this.scrollPane.update();
		}

		protected function get scroll():Number
		{
			return this.scrollPane.maxVerticalScrollPosition - this.scrollPane.verticalScrollPosition;
		}

		protected function set scroll(value:Number):void
		{
			try
			{
				this.scrollPane.verticalScrollPosition = this.scrollPane.maxVerticalScrollPosition - value;
			}
			catch (e:Error)
			{}
		}
	}
}