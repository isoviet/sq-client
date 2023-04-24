package utils
{
	import flash.display.DisplayObject;

	public class IndexUtil
	{
		static public function getMinIndex(input:Array, minValue:int = int.MIN_VALUE):DisplayObject
		{
			var minIndex:int = int.MAX_VALUE;
			var minIndexObject:DisplayObject;
			for each (var object:DisplayObject in input)
			{
				if (object.parent == null)
					continue;

				var objectIndex:int = object.parent.getChildIndex(object);

				if (minIndex < objectIndex || objectIndex < minValue)
					continue;

				minIndexObject = object;
				minIndex = objectIndex;
			}
			return minIndexObject;
		}

		static public function getMaxIndex(input:Array, maxValue:int = int.MAX_VALUE):DisplayObject
		{
			var maxIndex:int = int.MIN_VALUE;
			var maxIndexObject:DisplayObject;
			for each (var object:DisplayObject in input)
			{
				if (object.parent == null)
					continue;

				var objectIndex:int = object.parent.getChildIndex(object);

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
			for each (var object:DisplayObject in input)
			{
				if (!shift(object, delta))
					return;
			}
		}

		static public function sortByIndex(input:Array, order:int = 0):Array
		{
			var sort:Array = new Array();
			for each (var object:DisplayObject in input)
			{
				if (object == null)
					continue;
				sort.push( { 'object': object, 'index': ((object.parent == null) ? int.MAX_VALUE : object.parent.getChildIndex(object)) } );
			}

			sort.sortOn("index", Array.NUMERIC | order);
			var result:Array = new Array();

			for each (var data:Object in sort)
				result.unshift(data['object']);

			return result;
		}

		static public function shift(object:DisplayObject, delta:int):Boolean
		{
			if (delta == 0)
				return false;
			if (object.parent == null)
				return false;

			var maxIndex:int = object.parent.numChildren - 1;
			var objectIndex:int = object.parent.getChildIndex(object);

			if (objectIndex + delta > maxIndex || objectIndex + delta < 0)
				return false;

			trace("Prev index: " + objectIndex);
			object.parent.setChildIndex(object, objectIndex + delta);
			trace("After index: " + object.parent.getChildIndex(object));
			return true;
		}
	}

}