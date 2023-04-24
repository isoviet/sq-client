package utils.starling.collections
{
	import starling.display.Image;

	public class DisplayObjectManager
	{
		private static var _instance:DisplayObjectManager;
		private var collection: Vector.<Image> = new Vector.<Image>;
		private var collectionName: Vector.<String> = new Vector.<String>;
		private var _reservedOffset: int = 0;

		public static function getInstance():DisplayObjectManager
		{
			if (!_instance)
			{
				_instance = new DisplayObjectManager();
			}

			return _instance;
		}

		public function remove(item: Image): void
		{
			var index: int = collection.indexOf(item);
			if (index > -1)
			{
				while(true)
				{
					index = collection.indexOf(item);
					if (index == -1)
						return;
					collection[index].removeFromParent(true);
					collection[index].dispose();
					collection[index] = null;
					collectionName[index] = null;
					collection.splice(index, 1);
					collectionName.splice(index, 1);
				}
			}
		}

		private function existObjects(): void
		{
			var removeObject: Vector.<Image> = new Vector.<Image>();
			for (var i:int, j:int = collection.length; i < j; i++)
			{
				if (Logger.traceTextureEnabled)
				{
					trace('exist:', collection[i], collectionName[i]);
					if (_reservedOffset - 1 == i)
					{
						trace('-------------preCache------------count:' + (i + 1));
					}
				}
				if (collection[i].width == 1 && collection[i].height == 1)
				{
					collection[i] = null;
					collectionName[i] = null;
					removeObject.push(collection[i]);
				}
			}

			for (i = 0, j = removeObject.length; i < j; i++)
			{
				var index: int = collection.indexOf(removeObject[i]);
				if (index > -1)
				{
					collection.splice(index, 1);
					collectionName.splice(index, 1);
				}
			}
			removeObject = null;
		}

		public function get length(): int
		{
			existObjects();
			trace('------------All Count:', collection.length);
			return collection.length;
		}

		public function set reservedOffset(value: int): void
		{
			_reservedOffset = value;
		}

		public function get reservedOffset(): int
		{
			return _reservedOffset;
		}

		public function disposeExcess(): void
		{
			for(var i: int = collection.length - 1, j: int = _reservedOffset ; i > j; --i)
			{
				try
				{
					collection[i].removeFromParent(true);
					collection[i].dispose();
				}
				catch(e: Error)
				{}

				collection[i] = null;
				collectionName[i] = null;
			}

			collectionName.splice(_reservedOffset, (collectionName.length - _reservedOffset));
			collection.splice(_reservedOffset, (collection.length - _reservedOffset));
		}

		public function add(item: Image, displayObjectName: String):void
		{
			if (item is Image)
			{
				collection.push(item);
				collectionName.push(displayObjectName);
			}
			else
			{
				Logger.add('error! DisplayObjectManager items is not DisplayObject!', item);
			}
		}
	}
}