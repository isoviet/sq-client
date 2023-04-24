package game
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;

	import game.gameData.CollectionsData;
	import game.gameData.HolidayManager;
	import game.mainGame.entity.simple.CollectionElement;

	import utils.starling.StarlingAdapterSprite;

	public class CollectionHeroAnimation extends BaseCollectionHeroAnimation
	{
		public function CollectionHeroAnimation():void
		{
			super();
		}

		override protected function setIcon(itemId:int, kind:int):void
		{
			var iconClass:Class = kind == CollectionElement.KIND_HOLIDAY ? HolidayManager.images[itemId] : CollectionsData.getIconClass(itemId);
			this.iconImage = new StarlingAdapterSprite(new iconClass(), true);
			this.iconImage.scaleX = this.iconImage.scaleY = 0.5;
			this.iconImage.x = 20;
			this.iconImage.y = -10;
			this.iconImage.alpha = 0.5;
			this.iconImage.filters = [new GlowFilter(0xFFCC33, 1, 5, 5, 3.08, BitmapFilterQuality.HIGH)];
		}
	}
}