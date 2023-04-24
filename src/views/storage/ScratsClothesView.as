package views.storage
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFormat;

	import buttons.ButtonTabsTape;
	import dialogs.Dialog;
	import game.gameData.ClothesManager;
	import game.gameData.CollectionsData;
	import tape.collectionTapes.TapeCollectionClothesElement;

	import utils.Counter;

	public class ScratsClothesView extends Sprite
	{
		static private var _instance:ScratsClothesView = null;

		private var clothesTape:ButtonTabsTape = null;

		private var trophyObjects:Object = {};

		public function ScratsClothesView():void
		{
			super();

			_instance = this;

			init();
		}

		static public function get inited():Boolean
		{
			return _instance != null;
		}

		static public function setCollectionItems(uniqueData:Vector.<Counter>):void
		{
			_instance.setData(uniqueData);
		}

		static public function updateTrophyClothes():void
		{
			_instance.updateTrophyClothes();
		}

		static public function assembleComplete(success:Boolean, elementId:int):void
		{
			_instance.assembleComplete(success, elementId);
		}

		private function init():void
		{
			this.clothesTape = new ButtonTabsTape(1, 4, 210, 280, 2);
			this.clothesTape.x = 24;
			this.clothesTape.y = 200;
			this.clothesTape.initButtons(1, new Point(856, 140), new Point(-20, 140));

			for (var j:int = 0; j < CollectionsData.trophyData.length; j++)
			{
				if (!("clothesId") in CollectionsData.trophyData[j] || !("icon" in CollectionsData.trophyData[j]))
					continue;

				var sprite:Sprite = new Sprite();
				sprite.addChild(new GameField(CollectionsData.trophyData[j]['tittle'], 20, 90, Dialog.FORMAT_CAPTION_16)).filters = Dialog.FILTERS_CAPTION;
				var field:GameField = new GameField(CollectionsData.trophyData[j]['description'], 20, 115, new TextFormat(null, 12, 0x857653, true));
				field.wordWrap = true;
				field.width = 860;
				sprite.addChild(field);

				var collectionExchangeView:CollectionClothesExchangeView = new CollectionClothesExchangeView(j);
				collectionExchangeView.x = 60;
				collectionExchangeView.y = 545;
				sprite.addChild(collectionExchangeView);
				addChild(sprite);

				var trophyElement:TapeCollectionClothesElement = new TapeCollectionClothesElement(j);
				collectionExchangeView.converter.x = 105 - int(collectionExchangeView.converter.width * 0.5);
				collectionExchangeView.converter.y = 270 + 15;
				trophyElement.mouseChildren = true;
				trophyElement.addChild(collectionExchangeView.converter);
				this.clothesTape.insert(trophyElement, sprite);

				this.trophyObjects[j] = {'clothes': trophyElement, 'exchange': collectionExchangeView};
			}

			this.clothesTape.offset = 0;
			addChild(this.clothesTape);
		}

		private function setData(itemsData:Vector.<Counter>):void
		{
			for each (var object:Object in this.trophyObjects)
				(object['exchange'] as CollectionClothesExchangeView).setData(itemsData);
		}

		private function updateTrophyClothes():void
		{
			for each (var object:Object in this.trophyObjects)
			{
				var clothId:int = CollectionsData.trophyData[(object['clothes'] as TapeCollectionClothesElement).elementId]['clothesId'];
				var collected:Boolean = ClothesManager.haveItem(clothId, ClothesManager.KIND_PACKAGES);
				(object['clothes'] as TapeCollectionClothesElement).update(collected);
				(object['exchange'] as CollectionClothesExchangeView).update(collected);
			}
		}

		private function assembleComplete(success:Boolean, elementId:int):void
		{
			(this.trophyObjects[elementId]['exchange'] as CollectionClothesExchangeView).assembleComplete(success);
		}
	}
}