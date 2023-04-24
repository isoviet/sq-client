package chat
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;

	import menu.MenuProfile;

	import protocol.Connection;
	import protocol.packages.server.PacketChatMessage;
	import protocol.packages.server.structs.PacketChatHistoryMessages;

	public class ChatCommonData extends ChatData
	{
		static private const MESSAGE_WIDTH:int = 235;

		static private const DELETE_COUNT:int = 50;
		static private const MAX_HEIGHT:int = 5000;

		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #C9FFFF;
				text-align: left;
			}
			.justify {
				text-align: justify;
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
			.complain {
				text-decoration: none;
			}
			.service_message {
				color: #F7CF81;
			}
			.vip_message {
				color: #FEFE00;
			}
			.name_shaman {
				color: #A6DAF7;
				font-weight: bold;
			}
			.name_leader {
				color: #FF0000;
				font-weight: bold;
			}
			.name_moderator {
				color: #7CF772;
				font-weight: bold;
			}
			.color0 {
				color: #FFFFFF;
				font-weight: bold;
			}
			.color1 {
				color: #FF5A3A;
				font-weight: bold;
			}
			.color2 {
				color: #FFA800;
				font-weight: bold;
			}
			.color3 {
				color: #FFF12A;
				font-weight: bold;
			}
			.color4 {
				color: #FFC8FF;
				font-weight: bold;
			}
			.color5 {
				color: #66F2FF;
				font-weight: bold;
			}
			.color6 {
				color: #66A6FF;
				font-weight: bold;
			}
			.color7 {
				color: #EF66FF;
				font-weight: bold;
			}
		]]>).toString();

		public var type:int;

		public var readOnly:Boolean = false;

		private var style:StyleSheet = null;

		private var banIcon:ChatBanIcon = null;

		private var textFields:Array = [];

		public function ChatCommonData(type:int)
		{
			this.type = type;

			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			Connection.listen(onPacket, [PacketChatMessage.PACKET_ID]);

			this.banIcon = new ChatBanIcon();
			this.banIcon.visible = false;
			addChild(this.banIcon);
		}

		override public function clearText():void
		{
			for (var i:int = this.textFields.length - 1; i >= 0; i--)
			{
				removeChild(this.textFields[i]);
				this.textFields[i].removeEventListener(MouseEvent.MOUSE_DOWN, onLink);
				this.textFields[i].removeEventListener(MouseEvent.MOUSE_OVER, onOver);
				this.textFields[i].removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			}

			this.textFields.splice(0);
		}

		public function loadHistory(data: Vector.<PacketChatHistoryMessages>):void
		{
			for (var i:int = 0; i < data.length; i++)
				addMessage(new CommonMessage(Game.getPlayer(data[i].playerId), data[i].message));

			addMessage(new CommonMessage(null, gls("<span class = 'justify'>Добро пожаловать в чат. Пожалуйста, соблюдай правила.\nЗнакомьcя, общайся, приглашай друзей.</span>")));
		}

		public function flush():void
		{
			dispose();

			this.graphics.clear();
		}

		override protected function onMessageAdd(message:ChatMessage):void
		{
			drawMessage(message as CommonMessage);
			deleteOldMessages();
			super.onMessageAdd(message);
		}

		private function drawMessage(message:CommonMessage):void
		{
			var textField:GameField = new GameField("", 0, 0, this.style);
			if (message.canBan)
			{
				textField.addEventListener(MouseEvent.MOUSE_OVER, onOver);
				textField.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			}

			textField.addEventListener(MouseEvent.MOUSE_UP, onLink, false, 0, true);
			textField.htmlText = message.text;
			textField.userData = message;
			textField.wordWrap = true;
			textField.width = MESSAGE_WIDTH;
			textField.x = 12;
			textField.y = this.textFields.length > 0 ? (this.textFields[this.textFields.length - 1].y + this.textFields[this.textFields.length - 1].height) : 0;
			addChild(textField);
			this.textFields.push(textField);
		}

		private function onOver(e:MouseEvent):void
		{
			if (this.readOnly)
				return;

			var rect:Rectangle = (e.target as GameField).getBounds(this);

			this.banIcon.x = rect.x + rect.width + 4;
			this.banIcon.y = rect.y + int(rect.height / 2 - this.banIcon.height / 2);
			this.banIcon.visible = true;

			this.graphics.beginFill(0xD43838, 0.5);
			this.graphics.drawRoundRect(rect.x, rect.y, rect.width, rect.height, 5, 5);
			this.graphics.endFill();
		}

		private function onOut(e:MouseEvent):void
		{
			this.banIcon.visible = false;
			this.banIcon.y = 0;
			this.graphics.clear();
		}

		private function onLink(e:MouseEvent):void
		{
			if (!(e.target as GameField).userData || !((e.target as GameField).userData is CommonMessage))
				return;

			var id: int = CommonMessage((e.target as GameField).userData).userId;
			if (Game.selfId == id)
				return;

			MenuProfile.showMenu(id);
		}

		private function deleteOldMessages():void
		{
			if (this.height < MAX_HEIGHT || this.textFields.length <= DELETE_COUNT)
				return;

			for (var i:int = 0; i < this.textFields.length; i++)
			{
				if (i < DELETE_COUNT)
				{
					removeChild(this.textFields[i]);
					this.textFields[i].removeEventListener(MouseEvent.MOUSE_DOWN, onLink);
					this.textFields[i].removeEventListener(MouseEvent.MOUSE_OVER, onOver);
					this.textFields[i].removeEventListener(MouseEvent.MOUSE_OUT, onOut);
				}
				else
					this.textFields[i].y = (i == DELETE_COUNT) ? 0 : (this.textFields[i - 1].y + this.textFields[i - 1].height);
			}

			this.textFields.splice(0, DELETE_COUNT);
		}

		private function onPacket(packet:PacketChatMessage):void
		{
			if (packet.chatType != this.type)
				return;

			if (IgnoreList.isIgnored(packet.playerId))
				return;

			addMessage(new CommonMessage(Game.getPlayer(packet.playerId), packet.message));
		}
	}
}