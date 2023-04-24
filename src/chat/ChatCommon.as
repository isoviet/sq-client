package chat
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import fl.events.ScrollEvent;

	import buttons.ButtonTab;
	import dialogs.DialogShop;
	import events.ButtonTabEvent;
	import events.GameEvent;
	import events.ScreenEvent;
	import footers.FooterTop;
	import game.gameData.SettingsStorage;
	import game.gameData.VIPManager;
	import loaders.RuntimeLoader;
	import menu.MenuProfile;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.Screens;
	import sounds.GameSounds;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBan;
	import protocol.packages.server.PacketChatHistory;

	import utils.TextFieldUtil;

	public class ChatCommon extends ChatTabs
	{
		static private var _instance:ChatCommon = null;
		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private const CHAT_NEWBIE_LEVEL:int = 7;

		private var commonTab:ButtonTab = null;
		private var newbieTab:ButtonTab = null;

		private var chatOff:Boolean = false;

		private var autoScroll:Boolean = true;
		private var _readOnly:Boolean = false;

		public function ChatCommon()
		{
			_instance = this;

			super();

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);

			Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, onHide);
			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onShow);

			Connection.listen(onPacket, [PacketChatHistory.PACKET_ID, PacketBan.PACKET_ID]);
		}

		static public function listen(event:String, listener:Function):void
		{
			dispatcher.addEventListener(event, listener);
		}

		static public function forget(event:String, listener:Function):void
		{
			dispatcher.removeEventListener(event, listener);
		}

		static public function toggleChat(value:Boolean):void
		{
			if (!_instance)
				new ChatCommon();

			_instance.toggleChat(value);
		}

		static public function get isShowed():Boolean
		{
			if (!_instance)
				return false;

			return _instance.visible;
		}

		static public function setGag():void
		{
			if (_instance == null)
				return;

			_instance.setGag();
		}

		override public function add(chat:ChatData):void
		{
			super.add(chat);

			Connection.sendData(PacketClient.CHAT_COMMAND, PacketClient.CHAT_COMMAND_ENTER, (chat as ChatCommonData).type);
		}

		override protected function init():void
		{
			addChild(new ChatInputBg).cacheAsBitmap = true;

			this.inputBox = new TextField();
			this.inputBox.text = " ";
			this.inputBox.type = TextFieldType.INPUT;
			this.inputBox.wordWrap = false;
			this.inputBox.multiline = false;
			this.inputBox.x = 28;
			this.inputBox.y = 377;
			this.inputBox.width = 215;
			this.inputBox.height = 20;
			TextFieldUtil.embedFonts(this.inputBox);
			addChild(this.inputBox);

			this.inputFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0xC9FFFF, true);

			var direction:TextField = new TextField();
			direction.x = 11;
			direction.y = 378;
			direction.selectable = false;
			direction.autoSize = TextFieldAutoSize.LEFT;
			direction.defaultTextFormat = inputFormat;
			TextFieldUtil.embedFonts(direction);
			direction.text = " > ";
			addChild(direction);

			this.inputFormat.indent = direction.textWidth - 15;

			var buttonSend:ButtonChatSend = new ButtonChatSend();
			buttonSend.x = 252;
			buttonSend.y = 367;
			buttonSend.addEventListener(MouseEvent.CLICK, send);
			addChild(buttonSend);

			super.init();

			this.scrollPane.setStyle("thumbUpSkin", ChatThumbUpSkin);
			this.scrollPane.setStyle("thumbDownSkin", ChatThumbOverSkin);
			this.scrollPane.setStyle("thumbOverSkin", ChatThumbOverSkin);
			this.scrollPane.setStyle("trackUpSkin", ChatTrackSkin);
			this.scrollPane.setStyle("trackDownSkin", ChatTrackSkin);
			this.scrollPane.setStyle("trackOverSkin", ChatTrackSkin);
			this.scrollPane.setStyle("downArrowDownSkin", ChatDownArrowSkin);
			this.scrollPane.setStyle("downArrowOverSkin", ChatDownArrowSkin);
			this.scrollPane.setStyle("downArrowUpSkin", ChatDownArrowSkin);
			this.scrollPane.setStyle("upArrowDownSkin", ChatUpArrowSkin);
			this.scrollPane.setStyle("upArrowOverSkin", ChatUpArrowSkin);
			this.scrollPane.setStyle("upArrowUpSkin", ChatUpArrowSkin);
			this.scrollPane.setStyle("thumbIcon", ChatThumbIcon);

			this.scrollPane.setSize(285, 345);
			this.scrollPane.y = 12;

			this.commonTab = new ButtonTab(new ChatCommonTab);
			this.commonTab.x = 297;
			this.commonTab.y = 22;

			this.newbieTab = new ButtonTab(new ChatNewbieTab);
			this.newbieTab.x = 297;
			this.newbieTab.y = 67;

			this.tabs.x = 0;
			this.tabs.y = 0;
			this.tabs.insert(this.commonTab);
			this.tabs.insert(this.newbieTab);
			this.tabs.addEventListener(ButtonTabEvent.SELECT, onTabSelect);

			if (Game.self.moderator)
			{
				add(new ChatCommonData(PacketClient.CHAT_COMMON));
				this.tabs.setSelected(this.commonTab);
			}
			else
			{
				this.tabs.visible = false;
				var shape:Shape = new Shape();
				shape.graphics.lineStyle(1,0xFFFFFF);
				shape.graphics.moveTo(297, 21);
				shape.graphics.lineTo(297, 115);
				addChild(shape);
				add(new ChatCommonData(Experience.selfLevel > CHAT_NEWBIE_LEVEL ? PacketClient.CHAT_COMMON : PacketClient.CHAT_NEWBIE));
			}

			if (Game.gagTime > 0)
				setGag();

			this.readOnly = (!VIPManager.haveVIP) && !Game.self.moderator && Experience.selfLevel > CHAT_NEWBIE_LEVEL;

			FooterTop.addChat(this);

			Game.stage.focus = this.inputBox;

			this.y = -410;

			if (Game.self.moderator || Experience.selfLevel <= CHAT_NEWBIE_LEVEL)
				return;

			VIPManager.addEventListener(GameEvent.VIP_START, onVip);
			VIPManager.addEventListener(GameEvent.VIP_END, onVip);
		}

		override protected function onKeyDown(e:KeyboardEvent):void
		{
			if (this._readOnly)
				return;

			super.onKeyDown(e);
		}

		override protected function sendMessage(text:String):void
		{
			Connection.sendData(PacketClient.CHAT_MESSAGE, (this.currentChat as ChatCommonData).type, text);
			GameSounds.play("message_send");
		}

		override protected function onNewMessage(e:Event):void
		{
			this.autoScroll = this.autoScroll || (Math.abs(this.scrollPane.verticalScrollBar.scrollPosition - this.scrollPane.verticalScrollBar.maxScrollPosition) < 0.01);

			super.onNewMessage(e);
			if (this.autoScroll)
				this.scrollPane.verticalScrollPosition = this.scrollPane.maxVerticalScrollPosition;
		}

		override protected function onTabSelect(e:ButtonTabEvent):void
		{
			switch (e.button)
			{
				case this.commonTab:
					this.currentChat = this.chats[0];
					break;
				case this.newbieTab:
					if (!(1 in this.chats))
						add(new ChatCommonData(PacketClient.CHAT_NEWBIE));

					this.currentChat = this.chats[1];
					break;
			}

			this.autoScroll = true;
		}

		override protected function onScroll(e:ScrollEvent):void
		{
			super.onScroll(e);
			this.autoScroll = false;
		}

		override protected function set blockChat(value:Boolean):void
		{
			super.blockChat = value;
			if (!value && this._readOnly)
				this.readOnly = true;
		}

		private function toggleChat(value:Boolean):void
		{
			SettingsStorage.save(SettingsStorage.CHAT_SETTINGS, {'chatState': value});

			if (this.visible == value)
				return;

			this.visible = value;

			dispatcher.dispatchEvent(new GameEvent(GameEvent.CHANGED));

			if (value)
			{
				Game.stage.focus = this.inputBox;
				if (!this._readOnly)
					this.inputBox.text = "";
				if (this.chatOff)
				{
					for (var i:int = 0; i < this.chats.length; i++)
						Connection.sendData(PacketClient.CHAT_COMMAND, PacketClient.CHAT_COMMAND_ENTER, (this.chats[i] as ChatCommonData).type);
				}
				this.chatOff = false;
			}
			else
			{
				Game.stage.focus = Game.stage;
			}
		}

		private function set readOnly(value:Boolean):void
		{
			this._readOnly = value;

			if (!this.blockChat)
			{
				this.inputBox.type = value ? TextFieldType.DYNAMIC : TextFieldType.INPUT;
				this.inputBox.text = value ? gls("Необходим VIP статус") : "";
				this.inputBox.selectable = !value;
				value ? this.inputBox.addEventListener(MouseEvent.CLICK, showShop) : this.inputBox.removeEventListener(MouseEvent.CLICK, showShop);
			}

			for (var i:int = 0; i < this.chats.length; i++)
			{
				if ((this.chats[i] as ChatCommonData).type == PacketClient.CHAT_COMMON)
				{
					(this.chats[i] as ChatCommonData).readOnly = value;
					break;
				}
			}
		}

		private function send(e:MouseEvent):void
		{
			if (this.blockChat || this._readOnly)
				return;

			var message:String = this.inputBox.text;
			this.inputBox.text = "";
			processMessage(message);
		}

		private function clear():void
		{
			for (var i:int = 0; i < this.chats.length; i++)
				(this.chats[i] as ChatCommonData).flush();
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (!(e.screen is ScreenGame || e.screen is ScreenSchool || e.screen is ScreenEdit))
				return;

			toggleChat(false);
			exitChat();
			FooterTop.toggleChatButton();
		}

		private function exitChat():void
		{
			if (this.chatOff)
				return;

			this.chatOff = true;

			for (var j:int = 0; j < this.chats.length; j++)
				Connection.sendData(PacketClient.CHAT_COMMAND, PacketClient.CHAT_COMMAND_LEAVE, (this.chats[j] as ChatCommonData).type);
			clear();
		}

		private function onVip(e:GameEvent):void
		{
			this.readOnly = !VIPManager.haveVIP;
		}

		private function showShop(e:MouseEvent):void
		{
			RuntimeLoader.load(function():void
			{
				DialogShop.selectTape(DialogShop.VIP);
			});
		}

		private function onPacket(packet: AbstractServerPacket):void
		{
			if (this.chatOff)
				return;

			switch (packet.packetId)
			{
				case PacketChatHistory.PACKET_ID:
					var chatHistory: PacketChatHistory = packet as PacketChatHistory;

					for (var i:int = 0; i < this.chats.length; i++)
					{
						if ((this.chats[i] as ChatCommonData).type != chatHistory.chatType)
							continue;

						(this.chats[i] as ChatCommonData).loadHistory(chatHistory.messages);
						return;
					}
					break;
				case PacketBan.PACKET_ID:
					var ban: PacketBan = packet as PacketBan;

					if ((Game.selfId != ban.targetId) && (Game.selfId != ban.moderatorId) && !Game.self['moderator'])
						return;

					var moderator:Player = (ban.moderatorId != 0) ? Game.getPlayer(ban.moderatorId) : null;

					this.currentChat.addMessage(new CommonBanMessage(Game.getPlayer(ban.targetId), moderator, ban.duration, ban.type, ban.reason));
					break;
			}
		}

		private function onHide(event:MouseEvent):void
		{
			var target:DisplayObject = event.target as DisplayObject;
			var flag:Boolean = true;
			while (target != null)
			{
				if (target is ChatCommon || target is MenuProfile)
				{
					flag = false;
					break;
				}

				target = target.parent;
			}

			if(flag == true && this.visible == true)
				FooterTop.toggleChatButton(false);
		}

		private function onShow(event:KeyboardEvent):void
		{
			if(event.charCode == Keyboard.ENTER && this.visible == false
				&& !(Game.stage.focus is TextField))
				FooterTop.toggleChatButton(true);
		}
	}
}