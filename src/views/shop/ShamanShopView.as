package views.shop
{
	import game.gameData.OutfitData;

	public class ShamanShopView extends OutfitsShopView
	{
		override protected function get itemsIds():Array
		{
			return OutfitData.shaman_outfits;
		}
	}
}