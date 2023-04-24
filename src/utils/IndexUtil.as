package utils
{
	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterSprite;

	public class IndexUtil
	{
		static public function getMinIndex(input:Array, minValue:int = int.MIN_VALUE):StarlingAdapterSprite
		{
			var minIndex:int = int.MAX_VALUE;
			var minIndexObject:StarlingAdapterSprite;
			for each (var object:StarlingAdapterSprite in input)
			{
				if (object.parentStarling == null)
					continue;

				var objectIndex:int = object.parentStarling.getChildStarlingIndex(object);

				if (minIndex < objectIndex || objectIndex < minValue)
					continue;

				minIndexObject = object;
				minIndex = objectIndex;
			}
			return minIndexObject;
		}

		static public function getMaxIndex(input:Array, maxValue:int = int.MAX_VALUE):StarlingAdapterSprite
		{
			var maxIndex:int = int.MIN_VALUE;
			var maxIndexObject:StarlingAdapterSprite = null;
			for each (var object:StarlingAdapterSprite in input)
			{
				if (object.parentStarling == null)
					continue;

				var objectIndex:int = object.parentStarling.getChildStarlingIndex(object);

				if (maxIndex > objectIndex || objectIndex > maxValue)
					continue;

				maxIndexObject = object;
				maxIndex = objectIndex;
			}
			return maxIndexObject;
		}

		static public function shiftMany(input:Array, delta:int):void
		{
			if (delta == 0)
				return;

			input = sortByIndex(input, delta < 0 ? Array.DESCENDING : 0);
			for each (var object:StarlingAdapterSprite in input)
			{
				if (!shift(object, delta))
					return;
			}
		}

		static public function sortByIndex(input:Array, order:int = 0):Array
		{
			var sort:Array = [];
			for each (var object:* in input)
			{
				if (object == null)
					continue;

				if(object is IStarlingAdapter)
					sort.push({'object': object, 'index': ((object.parentStarling == null) ? int.MAX_VALUE : object.parentStarling.getChildStarlingIndex(object))});
			}

			sort.sortOn("index", Array.NUMERIC | order);
			var result:Array = [];

			for each (var data:Object in sort)
				result.unshift(data['object']);

			return result;
		}

		static public function shift(object:StarlingAdapterSprite, delta:int):Boolean
		{
			if (delta == 0)
				return false;
			if (object.parentStarling == null)
				return false;

			var maxIndex:int = object.parentStarling.numChildren - 1;
			var objectIndex:int = object.parentStarling.getChildStarlingIndex(object);

			if (objectIndex + delta > maxIndex || objectIndex + delta < 0)
				return false;

			object.parentStarling.setChildStarlingIndex(object, objectIndex + delta);
			return true;
		}
	}
}