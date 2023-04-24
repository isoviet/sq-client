package utils
{
	import game.mainGame.CastItem;
	import game.mainGame.entity.EntityFactory;

	public class CastUtil
	{
		static public function squirrelCastItems(items: Vector.<int>):Vector.<CastItem>
		{
			var result:Vector.<CastItem> = new Vector.<CastItem>;

			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i] <= 0)
					continue;

				var className:Class = CastItemsData.getClass(i);
				if (!className)
					continue;

				result.push(new CastItem(className, CastItem.TYPE_SQUIRREL, items[i]));
			}
			return result;
		}

		static public function shamanCastItems(ids:Array):Vector.<CastItem>
		{
			var result:Vector.<CastItem> = new Vector.<CastItem>;

			var unic:Array = ArrayUtil.valuesToUnic(ids);

			for (var i:int = 0; i < unic.length; i++)
				result.push(new CastItem(EntityFactory.getEntity(unic[i]), CastItem.TYPE_SHAMAN));

			return result;
		}
	}
}