package tape.wardrobeTapes
{
	import game.gameData.ClothesManager;
	import tape.TapeDataSelectable;
	import tape.TapeObject;

	public class TapeWardrobeData extends TapeDataSelectable
	{
		private var hideRibbons:Boolean = false;

		public function TapeWardrobeData(hideRibbons:Boolean = false):void
		{
			super(TapeWardrobeElement);

			this.hideRibbons = hideRibbons;
		}

		override protected function getNewObject(id:int):TapeObject
		{
			var answer:TapeWardrobeElement = new this.objectClass(id) as TapeWardrobeElement;
			answer.hideRibbons = this.hideRibbons;
			return answer;
		}

		override protected function sort():void
		{
			this.objects.sort(sortClothes);
		}

		private function sortClothes(a:TapeWardrobeElement, b:TapeWardrobeElement):int
		{
			var timeA:int = ClothesManager.getPackageTime(a.id);
			var timeB:int = ClothesManager.getPackageTime(b.id);
			if (timeA != 0 && timeB != 0)
				return timeA > timeB ? 1 : -1;
			else if (timeA != 0 || timeB != 0)
				return timeA < timeB ? 1 : -1;

			return (a.id < b.id ? -1 : 1);
		}
	}
}