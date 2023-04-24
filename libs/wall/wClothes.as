package
{
	import utils.ArrayUtil;

	public class wClothes extends wClothesData
	{
		static private const COMPARES:Object = {
			(TYPE_HAT + " " + TYPE_HAT): false,
			(TYPE_HAT + " " + TYPE_HEAD): false,
			(TYPE_HAT + " " + TYPE_EYES): true,
			(TYPE_HAT + " " + TYPE_NECK): true,
			(TYPE_HAT + " " + TYPE_FULL): false,
			(TYPE_HAT + " " + TYPE_UPPER_BODY): true,
			(TYPE_HAT + " " + TYPE_BOTTOM_BODY): true,
			(TYPE_HAT + " " + TYPE_TAIL): true,

			(TYPE_HEAD + " " + TYPE_HEAD): false,
			(TYPE_HEAD + " " + TYPE_EYES): false,
			(TYPE_HEAD + " " + TYPE_NECK): true,
			(TYPE_HEAD + " " + TYPE_FULL): false,
			(TYPE_HEAD + " " + TYPE_UPPER_BODY): true,
			(TYPE_HEAD + " " + TYPE_BOTTOM_BODY): true,
			(TYPE_HEAD + " " + TYPE_TAIL): true,

			(TYPE_EYES + " " + TYPE_EYES): false,
			(TYPE_EYES + " " + TYPE_NECK): true,
			(TYPE_EYES + " " + TYPE_FULL): false,
			(TYPE_EYES + " " + TYPE_UPPER_BODY): true,
			(TYPE_EYES + " " + TYPE_BOTTOM_BODY): true,
			(TYPE_EYES + " " + TYPE_TAIL): true,

			(TYPE_NECK + " " + TYPE_NECK): false,
			(TYPE_NECK + " " + TYPE_FULL): false,
			(TYPE_NECK + " " + TYPE_UPPER_BODY): true,
			(TYPE_NECK + " " + TYPE_BOTTOM_BODY): true,
			(TYPE_NECK + " " + TYPE_TAIL): true,

			(TYPE_FULL + " " + TYPE_FULL): false,
			(TYPE_FULL + " " + TYPE_UPPER_BODY): false,
			(TYPE_FULL + " " + TYPE_BOTTOM_BODY): false,
			(TYPE_FULL + " " + TYPE_TAIL): false,

			(TYPE_UPPER_BODY + " " + TYPE_UPPER_BODY): false,
			(TYPE_UPPER_BODY + " " + TYPE_BOTTOM_BODY): true,
			(TYPE_UPPER_BODY + " " + TYPE_TAIL): true,

			(TYPE_BOTTOM_BODY + " " + TYPE_BOTTOM_BODY): false,
			(TYPE_BOTTOM_BODY + " " + TYPE_TAIL): true,

			(TYPE_TAIL + " " + TYPE_TAIL): false
		}

		static public const SHAMAN:int = -1;

		static private var _instance:wClothes;

		private var accessibility:Array = new Array();

		static public var selfWardrobeClothes:Array = new Array();

		public function Clothes():void
		{
			_instance = this;
		}

		static public function hasItem(index:int):Boolean
		{
			return index in wClothes.selfWardrobeClothes;
		}

		static public function clearItems():void
		{
			while (wClothes.selfWardrobeClothes.length > 0)
				wClothes.selfWardrobeClothes.pop();
		}

		static public function set(data:Array):void
		{
			_instance.accessibility = ArrayUtil.parseByteArray(data);
		}

		static public function have(id:int):Boolean
		{
			return _instance.accessibility[id];
		}

		static public function getWardrobeClothesIds():Array
		{
			var result:Array = new Array();

			for(var i:int = 0; i < _instance.accessibility.length; i++)
				if (have(i))
					result.push(i);

			return result;
		}

		static public function isCompatible(firstType:int, secondType:int):Boolean
		{
			var key:String = firstType + " " + secondType;

			if (key in COMPARES)
				return COMPARES[key];

			return COMPARES[secondType + " " + firstType];
		}
	}
}