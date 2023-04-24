package chat
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import clans.ClanManager;
	import events.ClanNoticeEvent;
	import menu.MenuProfile;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketClanTransaction;
	import protocol.packages.server.structs.PacketClanTransactionItems;

	public class ClanFeeChatData extends ClanChatData
	{
		static private const DATE_V_OFFSET:int = 0;
		static private const DATE_WIDTH:int = 80;
		static private const DATA_H_OFFSET:int = 28;
		static private const LINE_HEIGHT:Number = 13.75;
		static private const QUANTITY_TRANSACTION:int = 100;

		static private var _bitmapNuts:BitmapData = null;
		static private var _bitmapCoins:BitmapData = null;

		private var lastIconIndex:int = 0;
		private var requested:Boolean = false;
		private var currencyPool: Array = [
			ClanFeeMessage.CURRENCY_NUTS,
			ClanFeeMessage.CURRENCY_COINS
		];

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
				color: #000000;
				font-weight: bold;
			}
			.subLeaderName {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
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

		static public function get bitmapNuts():BitmapData
		{
			if (!_bitmapNuts)
			{
				var image:ImageIconNut = new ImageIconNut();
				image.height = 16;
				image.scaleX = image.scaleY;

				var sprite:Sprite = new Sprite();
				sprite.addChild(image);

				_bitmapNuts = new BitmapData(sprite.width, sprite.height, true, 0x00FFFFFF);
				_bitmapNuts.draw(sprite);
			}
			return _bitmapNuts;
		}

		static public function get bitmapCoins():BitmapData
		{
			if (!_bitmapCoins)
			{
				var image:ImageIconCoins = new ImageIconCoins();
				image.height = 16;
				image.scaleX = image.scaleY;

				var sprite:Sprite = new Sprite();
				sprite.addChild(image);

				_bitmapCoins = new BitmapData(sprite.width, sprite.height, true, 0x00FFFFFF);
				_bitmapCoins.draw(sprite);
			}
			return _bitmapCoins;
		}

		public function ClanFeeChatData():void
		{
			super();
			style = new StyleSheet();
			style.parseCSS(CSS);

			ClanManager.listen(update, ClanNoticeEvent.CLAN_TRANSACTIONS_UPDATE);
		}

		override public function setWidth(value:int):void
		{
			super.setWidth(value - DATE_WIDTH);
		}

		override public function sendMessage(text:String):void
		{}

		override public function dispose():void
		{
			super.dispose();

			this.requested = false;
		}

		override public function clearText():void
		{
			super.clearText();
			this.lastIconIndex = 0;
			this.graphics.clear();
		}

		override public function onShow():void
		{
			super.onShow();

			request();
		}

		override protected function listen():void
		{
			Connection.listen(onPacket, PacketClanTransaction.PACKET_ID);
		}

		override protected function renderMessage(message:ChatMessage):void
		{
			var gameField: GameField = new GameField('', 0, 0, style);

			gameField.htmlText = "<textformat leading=\"1\">" + message.text + "</textformat><BR>";
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
			gameField.y = (poolField.length ? poolField[poolField.length - 1].y + poolField[poolField.length - 1].height : 0);
			if (poolField.length == 0)
			{
				gameField.y += LINE_HEIGHT;
			}
			poolField.push(gameField);
			renderDate(message);
			drawIcons();
			this.addChild(gameField);
		}

		protected function correctLenght(input:int, minLength:int = 2, fillChar:String = "0"):String
		{
			var tmp:String = String(input);

			while (tmp.length < minLength)
				tmp = fillChar + tmp;

			return tmp;
		}

		override protected function listenNotice():void
		{}

		private function onPacket(packet:PacketClanTransaction):void
		{
			if (!this.requested)
				return;

			packet.items = packet.items.sort(sortByTime);

			var items: Vector.<PacketClanTransactionItems> = packet.items;
			var item: PacketClanTransactionItems;
			var startNum:int = Math.max(0, items.length - QUANTITY_TRANSACTION);

			for (var i: int = startNum; i < items.length; i++)
			{
				item = items[i];
				if (item.type == PacketServer.CLAN_TRANSACTION_DONATION)
				{
					if (item.coins > 0)
						this.addMessage(new ClanFeeMessage(Game.getPlayer(item.playerId),
							item.type, item.coins, 0, item.data, new Date(item.time * 1000)));
					if (item.nuts > 0)
						this.addMessage(new ClanFeeMessage(Game.getPlayer(item.playerId),
							item.type, 0, item.nuts, item.data, new Date(item.time * 1000)));
				}
				else
					this.addMessage(new ClanFeeMessage(Game.getPlayer(item.playerId),
						item.type, item.coins, item.nuts, item.data, new Date(item.time * 1000)));
			}
		}

		private function sortByTime(a: PacketClanTransactionItems, b: PacketClanTransactionItems): int
		{
			return a.time < b.time ? -1: 1;
		}

		private function drawIcons():void
		{
			var currency: String = "";
			var index: int = 0;

			for (var i:int = 0, j:int = this.poolField.length; i < j; i++)
			{
				for (var k:int = 0, l:int = this.currencyPool.length; k < l; k++)
				{
					index = this.poolField[i].text.indexOf(this.currencyPool[k]);
					if (index > -1)
					{
						currency = this.currencyPool[k];
						break;
					}
				}

				if (currency == "" || index < 0)
					continue;

				var bound:Rectangle = this.poolField[i].getCharBoundaries(index - 2);

				if (!bound)
					bound = new Rectangle();

				bound.y += this.poolField[i].y;

				drawIcon(currency == ClanFeeMessage.CURRENCY_NUTS, bound);
				this.poolField[i].htmlText = this.poolField[i].htmlText.replace(currency, " ");
				currency = "";
			}
		}

		private function drawIcon(isNuts:Boolean, rect:Rectangle):void
		{
			var bitmapData:BitmapData = isNuts ? bitmapNuts : bitmapCoins;
			var bound:Rectangle = new Rectangle(rect.x + 8, rect.y - (bitmapData.height - rect.height) / 2, bitmapData.width, bitmapData.height);

			this.graphics.beginBitmapFill(bitmapData, new Matrix(1, 0, 0, 1, bound.x + this.text.x, bound.y + this.text.y), false);
			this.graphics.drawRect(bound.x + this.text.x, bound.y + this.text.y, bound.width, bound.height);
			this.graphics.endFill();
		}

		private function renderDate(message:ChatMessage):void
		{
			var dateText:TextField = new TextField();
			dateText.selectable = false;
			dateText.defaultTextFormat = new TextFormat(GameField.DEFAULT_FONT, 11, 0x000000, false);
			dateText.embedFonts = true;
			dateText.antiAliasType = AntiAliasType.ADVANCED;
			dateText.gridFitType = GridFitType.PIXEL;
			dateText.thickness = 100;
			dateText.sharpness = 0;

			dateText.htmlText = formatDate((message as ClanFeeMessage).date);
			dateText.width = dateText.textWidth + 5;
			dateText.height = dateText.textHeight + 5;

			var bitmapData:BitmapData = new BitmapData(dateText.width, dateText.height, true, 0x00FFFFFF);
			bitmapData.draw(dateText);

			var gameField: GameField = poolField[poolField.length - 1];

			var xPos:int = gameField.x + gameField.width + (DATE_WIDTH - bitmapData.width / 2) - DATA_H_OFFSET;
			var yPos:int = DATE_V_OFFSET + gameField.y;

			this.graphics.beginBitmapFill(bitmapData, new Matrix(1, 0, 0, 1, xPos, yPos), false, false);
			this.graphics.drawRect(xPos, yPos, bitmapData.width, bitmapData.height);
			this.graphics.endFill();
		}

		private function formatDate(date:Date):String
		{
			var now:Date = new Date();
			return correctLenght(date.hours) + ":" + correctLenght(date.minutes) + "  " + (now.month == date.month && now.date == date.date && now.fullYear == date.fullYear ? "" : correctLenght(date.date) + "." + correctLenght(date.month + 1));
		}

		private function request():void
		{
			if (this.requested)
				return;

			Connection.sendData(PacketClient.CLAN_GET_TRANSACTIONS);

			this.requested = true;
		}

		private function update(e:ClanNoticeEvent):void
		{
			if (!this.requested)
				return;

			dispose();

			dispatchEvent(new Event("CHANGED"));

			request();
		}

		private function onLink(e:MouseEvent):void
		{
			var obj: GameField = GameField(e.currentTarget);
			if (obj.userData)
				MenuProfile.showMenu(int(obj.userData));
		}
	}
}