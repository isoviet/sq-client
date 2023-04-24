package views.shop
{
	import game.gameData.OutfitData;

	public class SquirrelShopView extends OutfitsShopView
	{
		override protected function get itemsIds():Array
		{
			return OutfitData.squirrel_outfits.sort(onSort);
		}

		static private function onSort(a:int, b:int):int
		{
			var indexA:int = OutfitData.newestPackages.indexOf(a);
			var indexB:int = OutfitData.newestPackages.indexOf(b);
			if (indexA == indexB)
				return a > b ? 1 : -1;
			return indexA > indexB ? -1 : 1;
		}
	}
}