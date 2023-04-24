package chat
{
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;

	import clans.ClanManager;
	import events.ClanNoticeEvent;
	import menu.MenuProfile;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketChatMessage;

	public class ClanChatData extends ChatData
	{
		static private const MAX_COUNT:int = 100;
		static private const DELETE_COUNT:int = 50;

		protected var widthText: int = 250;
		protected var text: TextField = new TextField();
		protected var poolField:Vector.<GameField> = new Vector.<GameField>;

		static private const CSS:String = (<![CDATA[
			.playerName {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
				font-weight: bold;
			}
			.leaderName {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #FF0000;
				font-weight: bold;
			}
			.subLeaderName {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #2E8A22;
				font-weight: bold;
			}
			.message {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
			}
			a {
				text-decoration: underline;
			}

			a:hover {
				text-decoration: none;
			}
		]]>).toString();

		protected var style:StyleSheet = new StyleSheet();

		public function ClanChatData():void
		{
			this.text.text = "";
			this.text.width = 100;
			this.text.height = 100;
			this.text.multiline = true;
			this.text.wordWrap = true;
			this.text.embedFonts = true;
			this.text.antiAliasType = AntiAliasType.ADVANCED;
			this.text.gridFitType = GridFitType.PIXEL;
			this.text.thickness = 100;
			this.text.sharpness = 0;

			style = new StyleSheet();
			style.parseCSS(CSS);
			addChild(this.text);
			listen();
			listenNotice();
		}

		override public function clearText():void
		{
			for (var i: int = 0, j: int = poolField.length; i < j; i++) {
				this.removeChild(poolField[i]);
				poolField[i].removeEventListener(MouseEvent.MOUSE_DOWN, onLink);
				poolField[i] = null;
			}
			poolField = new Vector.<GameField>;
		}

		override public function sendMessage(text:String):void
		{
			super.sendMessage(text);
			Connection.sendData(PacketClient.CHAT_MESSAGE, PacketClient.CHAT_CLAN, text);
		}

		override public function setWidth(value:int):void
		{
			if (widthText == value)
				return;

			super.setWidth(value);
			widthText = value;
			this.text.width = value;
			clearText();
			renderAll();

			for (var i: int = 0, j: int = poolField.length; i < j; i++) {
				poolField[i].width = value;
			}

		}

		override protected function onMessageAdd(message:ChatMessage):void
		{
			renderMessage(message);
			deleteOldMessages(MAX_COUNT, DELETE_COUNT);
			super.onMessageAdd(message);
		}

		protected function listen():void
		{
			Connection.listen(onPacket, PacketChatMessage.PACKET_ID);
		}

		protected function renderMessage(message:ChatMessage):void
		{
			var gameField: GameField = new GameField('', 0, 0, style);
			gameField.htmlText = "<textformat leading=\"0\">" + message.text + "</textformat>";
			gameField.width = widthText;
			gameField.multiline = true;
			gameField.wordWrap = true;
			gameField.embedFonts = true;
			gameField.userData = message.userId;
			gameField.antiAliasType = AntiAliasType.ADVANCED;
			gameField.gridFitType = GridFitType.PIXEL;
			gameField.thickness = 100;
			gameField.sharpness = 0;
			gameField.addEventListener(MouseEvent.MOUSE_DOWN, onLink);
			gameField.y = poolField.length ? poolField[poolField.length - 1].y + poolField[poolField.length - 1].height : 0;
			poolField.push(gameField);
			this.addChild(gameField);
		}

		protected function listenNotice():void
		{
			ClanManager.listen(onChangedNews, ClanNoticeEvent.CLAN_NEWS_CHANGED);
		}

		private function onPacket(packet:PacketChatMessage):void
		{
			if (packet.chatType != PacketClient.CHAT_CLAN)
				return;

			if (IgnoreList.isIgnored(packet.playerId))
				return;

			this.addMessage(new ClanMessage(Game.getPlayer(packet.playerId), packet.message));
		}

		private function renderAll():void
		{
			clearText();

			for each(var message:ChatMessage in this.messages)
				renderMessage(message);
		}

		private function onChangedNews(e:ClanNoticeEvent):void
		{
			this.addMessage(new ClanNoticeMessage(ClanNoticeMessage.UPDATE_NEWS));
		}

		private function onLink(e:MouseEvent):void
		{
			var obj: GameField = GameField(e.currentTarget);
			if (obj.userData)
				MenuProfile.showMenu(int(obj.userData));
		}

		private function deleteOldMessages(max:int, deleteCount:int):void
		{
			if (this.messages.length <= max)
				return;

			clearText();
			this.messages = this.messages.slice(deleteCount);
			poolField = poolField.slice(deleteCount);

			renderAll();
		}
	}
}