package chat
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import events.ScreenEvent;
	import screens.ScreenDisconnected;
	import screens.Screens;

	import utils.DateUtil;
	import utils.StringUtil;

	public class ChatBase extends Sprite
	{
		static private const FLOOD_BLOCK_TIME:int = 15;

		static private const FLOOD_COUNT_LIMIT:int = 4;
		static private const FLOOD_COUNT_TIME:int = 4 * 1000;

		static private const FLOOD_LENGTH_LIMIT:int = 200;
		static private const FLOOD_LENGTH_TIME:int = 4 * 1000;

		protected var maxInputChars:int = 50;

		protected var inputBox:TextField = null;
		protected var inputFormat:TextFormat;
		protected var gagFormat:TextFormat;

		protected var messagesQueue:Array = [];

		protected var blockTimer:Timer = new Timer(1000, 1);
		protected var _blockChat:Boolean = false;

		public function ChatBase()
		{
			init();
		}

		public function setGag():void
		{
			if (Game.gagTime == 0)
				return;

			this.blockTimer.repeatCount = Game.gagTime - getTimer() / 1000;
			this.blockTimer.delay = 1000;
			this.blockTimer.reset();
			this.blockTimer.start();

			this.blockChat = true;
			onBlockTick();
		}

		protected function set blockChat(value:Boolean):void
		{
			this._blockChat = value;
		}

		protected function get blockChat():Boolean
		{
			return this._blockChat;
		}

		protected function init():void
		{
			this.blockTimer.addEventListener(TimerEvent.TIMER, onBlockTick);
			this.blockTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onBlockComplete);

			this.inputBox.restrict = "a-zA-Z а-яёА-ЯЁ`[0-9]\\-=~!@#$%\\^&*()_+[]\\\\{}|,./<>?;':\"№";
			this.inputBox.maxChars = maxInputChars;
			this.inputBox.defaultTextFormat = inputFormat;
			this.inputBox.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
		}

		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER || this.blockChat)
				return;

			var message:String = this.inputBox.text;
			this.inputBox.text = "";
			processMessage(message);
		}

		protected function sendMessage(text:String):void
		{}

		protected function processMessage(text:String):void
		{
			var message:String = WordFilter.filter(text);
			message = StringUtil.stripHTML(message);

			if (checkFlood(message))
				return;

			if (message == "")
				return;

			sendMessage(message);
		}

		protected function onBlockTick(e:TimerEvent = null):void
		{
			if (!this.gagFormat)
				this.gagFormat = new TextFormat(this.inputFormat.font, this.inputFormat.size, 0xFF0000, this.inputFormat.bold);

			this.inputBox.defaultTextFormat = this.gagFormat;
			this.inputBox.type = TextFieldType.DYNAMIC;
			this.inputBox.text = gls("Чат заблокирован на {0}", DateUtil.durationString(blockTimer.repeatCount - blockTimer.currentCount));
			this.inputBox.selectable = false;

			this.blockChat = true;
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (e.screen is ScreenDisconnected)
				this.visible = false;
		}

		private function checkFlood(input:String):Boolean
		{
			if (this.blockTimer.running)
				return true;

			var currentTime:Number = new Date().getTime();

			while (this.messagesQueue.length != 0)
			{
				if (currentTime - this.messagesQueue[0]['time'] < FLOOD_LENGTH_TIME)
					break;

				this.messagesQueue.shift();
			}

			this.messagesQueue.push({'length': input.length, 'time': currentTime});

			var length:int = 0, count:int = 0;

			for each (var data:Object in this.messagesQueue)
			{
				if (currentTime - data['time'] < FLOOD_LENGTH_TIME)
					length += data['length'];

				if (currentTime - data['time'] < FLOOD_COUNT_TIME && data['length'] != 0)
					count++;
			}

			if (count >= FLOOD_COUNT_LIMIT || length >= FLOOD_LENGTH_LIMIT)
			{
				this.blockTimer.repeatCount = FLOOD_BLOCK_TIME;
				this.blockTimer.reset();
				this.blockTimer.start();
				onBlockTick();
				return true;
			}
			return false;
		}

		private function onBlockComplete(e:TimerEvent):void
		{
			this.inputBox.text = "";
			this.inputBox.type = TextFieldType.INPUT;
			this.inputBox.defaultTextFormat = this.inputFormat;
			this.inputBox.selectable = true;

			this.blockChat = false;

			if (!this.visible)
				return;

			Game.stage.focus = this.inputBox;
		}
	}
}