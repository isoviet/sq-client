package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.utils.getDefinitionByName;

	import game.gameData.CollectionsData;

	public class CollectionPostView extends Sprite
	{
		static private const WIDTH:int = 126;

		public function CollectionPostView(type:int, id:int):void
		{
			addChild(new CollectionPostBackgroundImage());

			var scalingFactor:Number = (type == CollectionsData.TYPE_TROPHY ? 1.83 : 1.27);

			var iconClass:Class;
			if (type == CollectionsData.TYPE_TROPHY)
				iconClass = getDefinitionByName(CollectionsData.trophyData[id]['icon']) as Class;
			else if (type == CollectionsData.TYPE_UNIQUE)
				iconClass = CollectionsData.getUniqueClass(id);
			else
				iconClass = CollectionsData.getIconClass(id);

			var icon:DisplayObject = new iconClass();
			icon.scaleX = icon.scaleY = scalingFactor;
			icon.x = int((WIDTH - icon.width) / 2);
			icon.y = int((WIDTH - icon.height) / 2);
			icon.filters = [new GlowFilter(0xFFFFFF, 1, 20, 20, 3)];
			addChild(icon);
		}
	}
}