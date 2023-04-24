package tape
{
	import tape.events.TapeElementEvent;

	public class TapeNewsData extends TapeData
	{
		private var itemArray:Array = [];

		override public function setData(ids:Array):void
		{
			this.itemArray = ids;

			updateData();
		}

		public function addData(id:int):void
		{
			if (this.itemArray.indexOf(id) == -1)
				this.itemArray.push(id);
			updateData();
		}

		public function getData():Array
		{
			if (this.itemArray != null)
				return this.itemArray;
			return [];
		}

		override public function addObject(object:TapeObject):void
		{
			object.addEventListener(TapeElementEvent.STICKED, stickItem);

			super.addObject(object);
		}

		override public function insertObject(object:TapeObject, index:int = 0):void
		{
			object.addEventListener(TapeElementEvent.STICKED, stickItem);

			super.insertObject(object, index);
		}

		override public function pushObject(object:TapeObject):void
		{
			object.addEventListener(TapeElementEvent.STICKED, stickItem);

			super.pushObject(object);
		}

		protected function stickItem(e:TapeElementEvent):void
		{
			dispatchEvent(new TapeElementEvent(e.element, TapeElementEvent.STICKED));
		}

		private function updateData():void
		{
			clear();

			for (var i:int = 0; i < this.itemArray.length; i++)
				addObject(new TapeNewsElement(this.itemArray[i]));
		}
	}
}