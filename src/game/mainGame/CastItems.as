package game.mainGame
{
	import flash.events.EventDispatcher;

	import events.CastItemsEvent;
	import game.mainGame.events.CastItemEvent;

	public class CastItems extends EventDispatcher
	{
		private var data:Vector.<CastItem> = new Vector.<CastItem>;

		public function CastItems():void
		{
			super();
		}

		public function update():void
		{
			dispatchEvent(new CastItemsEvent(CastItemsEvent.UPDATE, []));
		}

		public function dispose():void
		{
			for each (var item:CastItem in this.data)
				item.removeEventListener(CastItemEvent.ITEM_END, onCastItemEnd);

			this.data = new Vector.<CastItem>;
		}

		public function reset():void
		{
			this.data = this.data.filter(onReset);
		}

		public function get items():Vector.<CastItem>
		{
			return this.data;
		}

		public function getItem(itemClass:Class, type:int):CastItem
		{
			if (this.data.length == 0)
				return null;
			for each (var castItem:CastItem in this.data)
			{
				if (castItem.itemClass == itemClass && castItem.type == type)
					return castItem;
			}
			return null;
		}

		public function set(value:Vector.<CastItem>):void
		{
			dispose();

			for each (var item:CastItem in value)
			{
				if (item.count <= 0)
					continue;
				this.data.push(item);
			}

			for each (item in this.data)
				item.addEventListener(CastItemEvent.ITEM_END, onCastItemEnd);

			update();
		}

		public function add(item:CastItem):void
		{
			if (item.count == 0 && item.type != CastItem.TYPE_ROUND)
				return;

			var founded:Boolean = false;

			if (this.data.length != 0)
			{
				for each (var castItem:CastItem in this.data)
				{
					if (castItem.itemClass != item.itemClass || castItem.type != item.type)
						continue;

					founded = true;

					if (item.type == CastItem.TYPE_SHAMAN)
						break;
					castItem.count += item.count;
					break;
				}
			}

			if (founded)
				return;

			item.addEventListener(CastItemEvent.ITEM_END, onCastItemEnd);
			this.data.push(item);

			dispatchEvent(new CastItemEvent(CastItemEvent.ITEM_ADD, item));
		}

		private function onCastItemEnd(e:CastItemEvent):void
		{
			this.data = this.data.filter(existingCastItems);
		}

		private function existingCastItems(item:CastItem, index:int, parentArray:Vector.<CastItem>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			if (item.count > 0)
				return true;

			item.removeEventListener(CastItemEvent.ITEM_END, onCastItemEnd);
			return false;
		}

		private function onReset(item:CastItem, index:int, parentArray:Vector.<CastItem>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			if (item.type == CastItem.TYPE_SQUIRREL && item.count > 0)
				return true;

			item.removeEventListener(CastItemEvent.ITEM_END, onCastItemEnd);
			return false;
		}
	}
}