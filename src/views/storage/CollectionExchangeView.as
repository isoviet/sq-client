package views.storage
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBaseMultiLine;
	import dialogs.collections.DialogCollectionExchange;
	import dialogs.collections.DialogCollectionSelfPost;
	import game.gameData.CollectionManager;
	import loaders.RuntimeLoader;
	import tape.TapeData;
	import tape.collectionTapes.TapeCollectionExchangeElement;
	import tape.collectionTapes.TapeCollectionView;

	import protocol.Connection;
	import protocol.PacketClient;

	public class CollectionExchangeView extends Sprite
	{
		static public const ELEMENTS_COUNT:int = 9;

		private var data:TapeData = null;

		private var selfPostDialog:DialogCollectionSelfPost = null;

		public function CollectionExchangeView():void
		{
			init();
		}

		public function addItem(itemId:int):Boolean
		{
			for (var i:int = 0; i < ELEMENTS_COUNT; i++)
			{
				if (!(this.data.objects[i] as TapeCollectionExchangeElement).isEmpty)
					continue;

				CollectionManager.exchangeItems.push(itemId);

				(this.data.objects[i] as TapeCollectionExchangeElement).elementId = itemId;
				return true;
			}
			return false;
		}

		public function removeItem(itemId:int):void
		{
			for (var i:int = 0; i < ELEMENTS_COUNT; i++)
			{
				if ((this.data.objects[i] as TapeCollectionExchangeElement).elementId != itemId)
					continue;

				(this.data.objects[i] as TapeCollectionExchangeElement).remove();
				break;
			}

			for (var j:int = i; j < ELEMENTS_COUNT - 1; j++)
			{
				if ((this.data.objects[j + 1] as TapeCollectionExchangeElement).isEmpty)
					break;

				(this.data.objects[j] as TapeCollectionExchangeElement).elementId = (this.data.objects[j + 1] as TapeCollectionExchangeElement).elementId;
				(this.data.objects[j + 1] as TapeCollectionExchangeElement).remove();
			}
		}

		public function setData(data:Array):void
		{
			for (var i:int = 0; i < ELEMENTS_COUNT; i++)
			{
				if (i == data.length)
					break;
				(this.data.objects[i] as TapeCollectionExchangeElement).remove();
				(this.data.objects[i] as TapeCollectionExchangeElement).elementId = data[i];
			}
		}

		private function init():void
		{
			this.graphics.beginFill(0xDDC9AF);
			this.graphics.drawRoundRect(0, 0, 780, 55, 5, 5);

			addChild(new GameField(gls("Коллекции\nна обмен"), 20, 10, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF, true, null, null, null, null, "center")));

			var button:ButtonBaseMultiLine = new ButtonBaseMultiLine(gls("Обменяться\nс друзьями"), 0, 14, null, 1.5);
			button.x = 630;
			button.y = 6;
			button.addEventListener(MouseEvent.CLICK, searchFriends);
			addChild(button);

			this.data = new TapeData();

			for (var i:int = 0; i < ELEMENTS_COUNT; i++)
			{
				var element:TapeCollectionExchangeElement = new TapeCollectionExchangeElement();
				element.addEventListener(MouseEvent.CLICK, selfPost);
				this.data.pushObject(element);
			}

			var tapeView:TapeCollectionView = new TapeCollectionView(ELEMENTS_COUNT, 1, 0, 0, 7, 0, 45, 45);
			tapeView.x = 150;
			tapeView.y = 5;
			tapeView.setData(this.data);
			addChild(tapeView);
		}

		private function searchFriends(e:MouseEvent):void
		{
			if (!DialogCollectionExchange.byFriends)
				Connection.sendData(PacketClient.COUNT, PacketClient.EXCHANGE_USED, 0);
			DialogCollectionExchange.byFriends = true;

			RuntimeLoader.load(function():void
			{
				DialogCollectionExchange.setPlayer(-1);
			});
		}

		private function selfPost(e:MouseEvent):void
		{
			if (e.target is ButtonCross)
				return;

			if (e.currentTarget.elementId == -1)
				return;

			var postingAllowed:Boolean = false;
			switch (Game.self.type)
			{
				case Config.API_VK_ID:
				case Config.API_OK_ID:
				case Config.API_FB_ID:
				case Config.API_MM_ID:
					postingAllowed = true;
					break;
			}

			if (!postingAllowed)
				return;

			if (this.selfPostDialog == null)
				this.selfPostDialog = new DialogCollectionSelfPost();

			this.selfPostDialog.iconId = e.currentTarget.elementId;
			this.selfPostDialog.show();
		}
	}
}