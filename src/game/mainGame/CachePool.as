package game.mainGame
{
	import flash.display.DisplayObject;

	import game.mainGame.entity.ICache;
	import game.mainGame.entity.ICacheVolatile;

	public class CachePool
	{
		private var cached:Array = [];
		private var cachedVolatile:Array = [];

		public function set cacheAsBitmap(value : Boolean) : void
		{
			for each (var object:* in this.cached)
				object.cacheAsBitmap = value;
		}

		public function add(object:*):void
		{
			if (object is ICacheVolatile)
			{
				if (this.cachedVolatile.indexOf(object) == -1)
					this.cachedVolatile.push(object);

				return;
			}

			if (this.cached.indexOf(object) == -1)
				this.cached.push(object);
		}

		public function remove(object:*):void
		{
			var index:int = -1;
			if (object is ICacheVolatile)
			{
				index = this.cachedVolatile.indexOf(object);
				if (index != -1)
					this.cachedVolatile.splice(index, 1);

				return;
			}

			index = this.cached.indexOf(object);
			if (index == -1)
				return;

			this.cached.splice(index, 1);
		}

		public function clear():void
		{
			this.cached.splice(0);
			this.cachedVolatile.splice(0);
		}

		public function update():void
		{
			for each (var object:ICache in this.cachedVolatile)
				(object as DisplayObject).cacheAsBitmap = object.cacheBitmap;
		}
	}
}