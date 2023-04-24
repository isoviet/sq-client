package views.storage
{
	import flash.display.Sprite;
	import flash.events.Event;

	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;
	import tape.TapeData;
	import tape.collectionTapes.TapeCollectionCollectorElement;
	import tape.collectionTapes.TapeCollectionCommonElement;
	import tape.collectionTapes.TapeCollectionView;

	import utils.Counter;

	public class CollectionSetView extends Sprite
	{
		private var data:TapeData = null;
		private var collectionUniqueItem:TapeCollectionCollectorElement = null;

		private var dataSetLock:Boolean = false;
		private var assembleBlocked:Boolean = false;

		public var collectionId:int = 1;

		public function CollectionSetView(collectionId:int):void
		{
			this.collectionId = collectionId;

			init();
		}

		public function setData(commonData:Vector.<Counter>, uniqueData:Vector.<Counter>):void
		{
			this.dataSetLock = true;

			for (var i:int = 0; i < this.data.objects.length; i++)
				(this.data.objects[i] as TapeCollectionCommonElement).counter = commonData[(this.data.objects[i] as TapeCollectionCommonElement).elementId];

			this.collectionUniqueItem.counter = uniqueData[this.collectionUniqueItem.elementId];

			this.dataSetLock = false;

			updateCollected();
		}

		public function setExchange(elementId:int, value:Boolean):void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if ((this.data.objects[i] as TapeCollectionCommonElement).elementId != elementId)
					continue;

				(this.data.objects[i] as TapeCollectionCommonElement).isAnExchange = value;
			}
		}

		public function assembleComplete(success:Boolean):void
		{
			this.assembleBlocked = false;

			if (!success || !checkCollected())
				return;

			this.dataSetLock = true;

			for (var i:int = 0; i < this.data.objects.length; i++)
				(this.data.objects[i] as TapeCollectionCommonElement).onConvert();

			this.dataSetLock = false;

			updateCollected();

			this.collectionUniqueItem.onAssembleComplete();
		}

		public function checkCollected():Boolean
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if ((this.data.objects[i] as TapeCollectionCommonElement).isCollected)
					continue;
				return false;
			}

			return true;
		}

		private function init():void
		{
			this.data = new TapeData();

			for (var i:int = 0; i < CollectionsData.uniqueData[this.collectionId]['set'].length; i++)
			{
				var element:TapeCollectionCommonElement = new TapeCollectionCommonElement(CollectionsData.uniqueData[this.collectionId]['set'][i]);
				element.addEventListener(Event.CHANGE, updateCollected);
				this.data.pushObject(element);
			}

			var commonTape:TapeCollectionView = new TapeCollectionView(3, 2, 0, 0, 3, 0, 60, 60);
			commonTape.y = 190;
			commonTape.setData(this.data);
			addChild(commonTape);

			this.collectionUniqueItem = new TapeCollectionCollectorElement(this.collectionId);
			this.collectionUniqueItem.addEventListener(TapeCollectionCollectorElement.EVENT_EXCHANGE, onConvert);
			addChild(this.collectionUniqueItem);
		}

		private function updateCollected(e:Event = null):void
		{
			if (this.dataSetLock)
				return;

			var isCollected:Boolean = checkCollected();

			this.collectionUniqueItem.collected = isCollected;

			dispatchEvent(new Event(Event.CHANGE));
		}

		private function onConvert(e:Event):void
		{
			if (!checkCollected())
				return;

			if (this.assembleBlocked)
				return;

			CollectionManager.collectUniqueItem(this.collectionId);
			this.assembleBlocked = true;
		}
	}
}