package chat
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.StyleSheet;
	import flash.utils.Timer;

	import buttons.ButtonToggle;
	import events.ChatEvent;
	import events.ScreenEvent;
	import footers.Footers;
	import screens.ScreenGame;
	import screens.Screens;
	import statuses.Status;

	import com.api.Player;
	import com.greensock.TweenMax;

	public class ChatDead extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
			}
			.name {
				font-weight: bold;
			}
			a {
				text-decoration: underline;
			}
			a:hover {
				text-decoration: none;
			}
			.service_message {
				color: #72300B;
				font-weight: bold;
			}
			.name_shaman {
				color: #0078EA;
				font-weight: bold;
			}
		]]>).toString();

		static public const GENERAL_MESSAGE:int = 0;

		static private const CLAN_MESSAGE:int = 1;
		static private const MAX_CHAT_MESSAGES:int = 5;
		static private const MAX_HISTORY_MESSAGES:int = 15;
		static private const BOTTOM_OFFEST_MESSAGE: int = - 92;

		static private var _instance:ChatDead = null;

		private var style:StyleSheet = new StyleSheet();
		private var timer:Timer = new Timer(10 * 1000, 1);

		private var messages:Array = [];
		private var history:Array = [];

		private var chatButton:ButtonToggle = null;
		private var historyButton:ButtonToggle = null;

		private var spriteCommon:Sprite = new Sprite();
		private var spriteModerators:Sprite = new Sprite();

		private var tween:TweenMax = null;

		static public function get instance():ChatDead
		{
			if (!_instance)
				new ChatDead();
			return _instance;
		}

		public function ChatDead():void
		{
			_instance = this;

			init();

			this.x = 10;
			this.y = 520;

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
		}

		public function clearMessages():void
		{
			this.timer.stop();
			this.timer.reset();

			removeAll();
			hideHistory();
			this.historyButton.off();
		}

		public function sendBanMessage(banned:Player, moderator:Player, banTime:int, banType:int, banReason:int):void
		{
			addMessage(new ChatBanMessage(banned, moderator, banTime, banType, banReason));
		}

		public function sendMessage(playerId:int, text:String, type:int = GENERAL_MESSAGE):void
		{
			var player:Player = Game.getPlayer(playerId);

			switch (type)
			{
				case CLAN_MESSAGE:
					addMessage(new ChatDeadMessage(player, text, true));
					break;
				case GENERAL_MESSAGE:
					addMessage(new ChatDeadMessage(player, text, false, true));
					break;
				default:
					sendServiceMessage(playerId, text, type);
			}
		}

		public function sendServiceMessage(playerId:int, text:String, type:int, amount:int = 0):void
		{
			var player:Player = Game.getPlayer(playerId);

			if (type == ChatDeadServiceMessage.WOMEN_DAY && Game.self['moderator'])
				return;

			var message:ChatDeadServiceMessage = new ChatDeadServiceMessage(player, text, type, amount);
			if (!Game.self['moderator'] && (type == ChatDeadServiceMessage.MY_FRIENDS || type == ChatDeadServiceMessage.PLAYING_FRIENDS || type == ChatDeadServiceMessage.FRIEND_JOIN_WAITING))
			{
				if (!('moderator' in player))
					message.addEventListener(ChatEvent.REMOVE, removeMessage, false, 0, true);
				else
				{
					if (player['moderator'])
						return;
				}
			}
			addMessage(message);
		}

		private function init():void
		{
			this.style.parseCSS(CSS);

			this.chatButton = new ButtonToggle(new ButtonFooterChatOff, new ButtonFooterChatOn, true);
			this.chatButton.x = 20;
			this.chatButton.y = 2;
			this.chatButton.addEventListener(MouseEvent.CLICK, toggleChat);
			new Status(this.chatButton.buttonOff, gls("Развернуть чат"));
			new Status(this.chatButton.buttonOn, gls("Скрыть чат"));

			this.historyButton = new ButtonToggle(new HistoryOff, new HistoryOn, false);
			this.historyButton.y = Game.starling.stage.stageHeight - 100;
			this.historyButton.x = 55;
			this.historyButton.addEventListener(MouseEvent.CLICK, toggleHistory);
			this.historyButton.visible = false;
			new Status(this.historyButton.buttonOff, gls("Показать историю чата"));
			new Status(this.historyButton.buttonOn, gls("Скрыть историю чата"));
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, hideMessage);

			addChild(this.spriteCommon);

			this.spriteModerators.visible = false;
			addChild(this.spriteModerators);

			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
			onChangeScreenSize();
		}

		private function onChangeScreenSize(e: Event = null): void
		{
			this.chatButton.x = Footers.instance.x + 20;
			this.chatButton.y = Game.starling.stage.stageHeight - 50;

			this.x = Footers.instance.x + 20;
			this.y = this.chatButton.y + BOTTOM_OFFEST_MESSAGE;

			this.historyButton.x = this.chatButton.x + 35;
			this.historyButton.y = this.chatButton.y;
		}

		private function toggleChat(e:MouseEvent):void
		{
			if (!this.chatOn)
			{
				this.spriteCommon.visible = false;
				hideHistory();
				return;
			}
			this.spriteCommon.visible = true;
			this.historyButton.visible = (this.history.length > 0) && this.chatOn;
			toggleHistory();
		}

		private function toggleHistory(e:MouseEvent = null):void
		{
			this.spriteModerators.visible = this.historyOn && this.historyButton.visible;
		}

		private function hideHistory():void
		{
			this.historyButton.visible = false;
			toggleHistory();
		}

		private function removeAll():void
		{
			for (var i:int = 0; i < this.messages.length; i++)
				(this.messages[i] as ChatDeadMessage).dispose();
			this.messages.splice(0);

			for (i = 0; i < this.history.length; i++)
				(this.history[i] as ChatDeadMessage).dispose();
			this.history.splice(0);

			while (this.spriteCommon.numChildren > 0)
				this.spriteCommon.removeChildAt(0);

			while (this.spriteModerators.numChildren > 0)
				this.spriteModerators.removeChildAt(0);
		}

		private function addMessage(message:ChatDeadMessage):void
		{
			if (message.isNull)
				return;
			this.spriteCommon.addChild(message);

			this.timer.reset();
			this.timer.start();

			this.messages.push(message);

			if (this.messages.length > MAX_CHAT_MESSAGES)
			{
				if (this.tween != null)
					this.tween.kill();
				removeLastMessage();
			}

			updateMessages();
		}

		private function hideMessage(e:TimerEvent):void
		{
			if (this.messages[0] == null)
				return;

			this.timer.stop();

			if (this.chatOn)
				this.tween = TweenMax.to(this.messages[0], 1, {'alpha': 0, 'onComplete': restart});
			else
				restart();
		}

		private function removeLastMessage():void
		{
			if (this.messages.length == 0 || this.messages[0] == null)
				return;

			var message:ChatDeadMessage = this.messages.shift();

			if (this.spriteCommon.contains(message))
				this.spriteCommon.removeChild(message);

			if (!(message is ChatDeadServiceMessage))
			{
				message.alpha = 1;
				this.history.push(message);
				this.spriteModerators.addChild(message);
			}

			updateHistory();

			if (this.history.length <= MAX_HISTORY_MESSAGES)
				return;

			if (this.spriteModerators.contains(this.history[0]))
				this.spriteModerators.removeChild(this.history[0]);

			(this.history.shift() as ChatDeadMessage).dispose();
		}

		private function restart():void
		{
			removeLastMessage();

			this.timer.reset();
			this.timer.start();
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (e.screen is ScreenGame)
			{
				Game.gameSprite.addChild(this.chatButton);
				Game.gameSprite.addChild(this.historyButton);
				return;
			}

			if (Game.gameSprite.contains(this.chatButton))
				Game.gameSprite.removeChild(this.chatButton);

			if (Game.gameSprite.contains(this.historyButton))
				Game.gameSprite.removeChild(this.historyButton);
		}

		private function updateHistory():void
		{
			for (var i:int = 0, length:int = this.history.length; i < length; i++)
				this.history[i].y = -((this.history.length - 1 - i) + this.messages.length + 1) * ChatDeadMessage.MESSAGE_HEIGHT;

			this.historyButton.visible = (this.history.length > 0) && this.chatOn;
		}

		private function updateMessages():void
		{
			for (var i:int = 0; i < this.messages.length; i++)
				this.messages[i].y = -(this.messages.length - 1 - i) * ChatDeadMessage.MESSAGE_HEIGHT;

			updateHistory();
		}

		private function removeMessage(e:ChatEvent):void
		{
			this.messages.splice(this.messages.indexOf(e.message), 1);
			if (this.spriteCommon.contains(e.message))
				this.spriteCommon.removeChild(e.message);
			e.message.removeEventListener(ChatEvent.REMOVE, removeMessage);
			e.message.dispose();
			updateMessages();
		}

		private function get chatOn():Boolean
		{
			return !this.chatButton.buttonOff.visible;
		}

		private function get historyOn():Boolean
		{
			return !this.historyButton.buttonOff.visible;
		}
	}
}