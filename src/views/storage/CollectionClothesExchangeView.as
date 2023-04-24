package views.storage
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;

	import game.gameData.ClothesManager;
	import game.gameData.CollectionsData;
	import game.gameData.OutfitData;

	import utils.Counter;

	public class CollectionClothesExchangeView extends Sprite
	{
		static private const STATUS_NOT_ALL_COLLECTIONS:String = gls("<body><b>Обмен недоступен:</b> ты собрал не все предметы для обмена.</body>");
		static private const STATUS_NO_SCRAT:String = gls("<body><b>Обмен недоступен:</b> необходимо собрать Скрэта.</body>");
		static private const STATUS_NO_SCRATTY:String = gls("<body><b>Обмен недоступен:</b> необходимо собрать Скрэтти.</body>");

		public var trophyId:int;

		private var uniqueSet:CollectionUniqueView = null;
		public var converter:CollectionsConverter = null;

		public function CollectionClothesExchangeView(id:int):void
		{
			this.trophyId = id;

			init();
		}

		public function setData(itemsData:Vector.<Counter>):void
		{
			this.uniqueSet.setData(itemsData);
		}

		public function assembleComplete(success:Boolean):void
		{
			this.converter.waitingForResponse = false;
			this.uniqueSet.assembleComplete(success);
		}

		public function update(collected:Boolean):void
		{
			this.converter.available = !collected;
			if (!collected)
				updateConverter();
		}

		private function init():void
		{
			this.graphics.beginFill(0xDDC9AF);
			this.graphics.drawRoundRect(0, 0, 780, 55, 5, 5);

			addChild(new GameField(gls("Необходимые\nколлекции"), 20, 10, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF, true, null, null, null, null, "center")));

			this.uniqueSet = new CollectionUniqueView(this.trophyId);
			this.uniqueSet.x = 185;
			this.uniqueSet.y = 3;
			this.uniqueSet.addEventListener(Event.CHANGE, updateConverter);
			addChild(this.uniqueSet);

			this.converter = new CollectionsConverter(this.trophyId);
			addChild(this.converter)
		}

		private function updateConverter(e:Event = null):void
		{
			var canExchange:Boolean = this.uniqueSet.checkCollected();

			var blockReason:String = canExchange ? "" : STATUS_NOT_ALL_COLLECTIONS;

			var clothesId:int = CollectionsData.trophyData[this.trophyId]['clothesId'];
			var owner:int = OutfitData.getOwnerById(CollectionsData.trophyData[this.trophyId]['clothesId']);
			switch (owner)
			{
				case OutfitData.OWNER_SCRAT:
					if (ClothesManager.haveScrat || clothesId == OutfitData.SCRAT)
						break;
					blockReason = STATUS_NO_SCRAT;
					canExchange = false;
					break;
				case OutfitData.OWNER_SCRATTY:
					if (ClothesManager.haveScratty || clothesId == OutfitData.SCRATTY)
						break;
					blockReason = STATUS_NO_SCRATTY;
					canExchange = false;
					break;
			}

			this.converter.setBlocked(!canExchange, blockReason);
		}
	}
}