package wear
{
	import wear.decorators.ClothesHidingItem;
	import wear.decorators.ClothesZOrderItem;

	import by.blooddy.crypto.serialization.JSON;

	public class ClothesFactory
	{
		static public function create(itemName:String):ClothesItem
		{
			Logger.add("create", itemName);
			var params:Object = BonesData.getObject(itemName);
			Logger.add("params", by.blooddy.crypto.serialization.JSON.encode(params));
			params['skeleton'] = itemName;

			return createZOrder(createHiding(createUpper(params) || createItem(params)));
		}

		static private function createItem(params:Object):ClothesItem
		{
			return new ClothesItem(params);
		}


		static private function createUpper(params:Object):ClothesItem
		{
			return params.hasOwnProperty('upper') ? new ClothesUpperItem(params) : null;
		}

		static private function createZOrder(item:ClothesItem):ClothesItem
		{
			if (BonesData.DATA){/*GET DATA FROM*/}
			return item.params.hasOwnProperty('zOrderBones') ? new ClothesZOrderItem(item) : item;
		}

		static private function createHiding(item:ClothesItem):ClothesItem
		{
			if (BonesData.DATA){/*GET DATA FROM*/}
			return item.params.hasOwnProperty('hiddenBones') ? new ClothesHidingItem(item) : item;
		}
	}
}