package views
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;
	import tape.TapeData;
	import tape.collectionTapes.TapeCollectionDemoElement;
	import tape.collectionTapes.TapeCollectionView;

	public class CollectionSetDemoView extends Sprite
	{
		static private const FORMAT_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 12, 0xFC7927);
		static private const FILTER:GlowFilter = new GlowFilter(0xDDC9AF, 1, 10, 10);

		private var data:TapeData = null;

		private var fieldTittle:GameField = null;

		public function CollectionSetDemoView():void
		{
			init();
		}

		public function setItem(itemId:int):void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				var collectionElementId:int = CollectionsData.uniqueData[CollectionsData.regularData[itemId]['collection']]['set'][i];
				(this.data.objects[i] as TapeCollectionDemoElement).setData(collectionElementId, CollectionManager.regularItems[collectionElementId].count, true);
			}

			this.fieldTittle.text = gls("Коллекция «{0}»", CollectionsData.uniqueData[CollectionsData.regularData[itemId]['collection']]['collectionName']).toUpperCase();
			this.fieldTittle.x = 120 - int(this.fieldTittle.textWidth * 0.5);
		}

		private function init():void
		{
			this.fieldTittle = new GameField("", 0, 0, FORMAT_CAPTION);
			addChild(this.fieldTittle);

			this.data = new TapeData();

			for (var i:int = 0; i < 5; i++)
			{
				var element:TapeCollectionDemoElement = new TapeCollectionDemoElement();
				element.filters = [FILTER];
				this.data.pushObject(element);
			}

			var commonTape:TapeCollectionView = new TapeCollectionView(5, 1, 0, 0, 1, 0, 47, 47);
			commonTape.setData(this.data);
			commonTape.y = 25;
			addChild(commonTape);
		}
	}
}