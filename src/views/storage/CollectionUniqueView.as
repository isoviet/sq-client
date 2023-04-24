package views.storage
{
	import flash.display.Sprite;
	import flash.events.Event;

	import game.gameData.GameConfig;
	import tape.TapeData;
	import tape.collectionTapes.TapeCollectionUniqueElement;
	import tape.collectionTapes.TapeCollectionUniqueExchangeElement;
	import tape.collectionTapes.TapeCollectionView;

	import utils.Counter;

	public class CollectionUniqueView extends Sprite
	{
		public var trophyId:int = 0;

		private var data:TapeData = null;

		public function CollectionUniqueView(trophyId:int):void
		{
			this.trophyId = trophyId;

			init();
		}

		public function assembleComplete(success:Boolean):void
		{
			if (!success)
				return;

			for (var i:int = 0; i < this.data.objects.length; i++)
				(this.data.objects[i] as TapeCollectionUniqueElement).onExchange();
		}

		public function setData(itemsData:Vector.<Counter>):void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
				(this.data.objects[i] as TapeCollectionUniqueElement).counter = itemsData[(this.data.objects[i] as TapeCollectionUniqueElement).elementId];
		}

		public function checkCollected():Boolean
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if ((this.data.objects[i] as TapeCollectionUniqueExchangeElement).isCollected)
					continue;

				return false;
			}

			return true;
		}

		private function init():void
		{
			this.data = new TapeData();

			var price:Array = GameConfig.getCollectionTrophyPrice(this.trophyId);
			for (var i:int = 0; i < price.length; i++)
			{
				var element:TapeCollectionUniqueExchangeElement = new TapeCollectionUniqueExchangeElement(price[i]);
				element.addEventListener(Event.CHANGE, update);
				this.data.pushObject(element);
			}

			var uniqueTape:TapeCollectionView = new TapeCollectionView(12, 1, 0, 3, 4, 4, 45, 45, false, false);
			uniqueTape.setData(this.data);
			addChild(uniqueTape);
		}

		private function update(e:Event):void
		{
			dispatchEvent(e);
		}
	}
}