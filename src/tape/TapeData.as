package tape
{
	import flash.events.EventDispatcher;

	import tape.events.TapeDataEvent;
	import tape.events.TapeElementEvent;

	public class TapeData extends EventDispatcher
	{
		public var objects:Vector.<TapeObject> = new Vector.<TapeObject>();
		protected var objectClass:Class = null;

		public function TapeData(objectClass:Class = null):void
		{
			super();

			this.objectClass = objectClass;
		}

		public function setData(ids:Array):void
		{
			clear();

			for (var i:int = ids.length - 1; i >= 0; i--)
				addObject(getNewObject(ids[i]));

			sort();
		}

		protected function getNewObject(id:int):TapeObject
		{
			return new this.objectClass(id) as TapeObject;
		}

		public function addObject(data:TapeObject):void
		{
			this.objects.unshift(data);

			setLengthCutRight(int.MAX_VALUE);
		}

		public function insertObject(data:TapeObject, index:int = 0):void
		{
			this.objects.splice(index, 0, data);
		}

		public function pushObject(data:TapeObject):void
		{
			this.objects.push(data);

			setLengthCutLeft(int.MAX_VALUE);
		}

		public function get count():int
		{
			return this.objects.length;
		}

		public function onObjectChanged(e:TapeElementEvent):void
		{
			for each (var data:TapeObject in this.objects)
			{
				if (data.loaded)
					continue;
				return;
			}

			sort();

			dispatchEvent(new TapeDataEvent(TapeDataEvent.UPDATE, this));
		}

		public function clear():void
		{
			setLengthCutRight(0);

			dispatchEvent(new TapeDataEvent(TapeDataEvent.UPDATE, this));
		}

		protected function sort():void
		{
			//TODO sort function
		}

		protected function setLengthCutRight(length:int):void
		{
			while (this.objects.length > length)
			{
				var removed:TapeObject = this.objects.pop();
				removed.forget(onObjectChanged);
			}
		}

		protected function setLengthCutLeft(length:int):void
		{
			while (this.objects.length > length)
			{
				var removed:TapeObject = this.objects.shift();
				removed.forget(onObjectChanged);
			}
		}
	}
}