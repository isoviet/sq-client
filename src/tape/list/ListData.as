package tape.list
{
	import flash.display.Sprite;

	import tape.list.events.ListDataEvent;
	import tape.list.events.ListElementEvent;

	public class ListData extends Sprite
	{
		public var objects:Vector.<ListElement> = new Vector.<ListElement>();

		public function ListData():void
		{}

		public function get count():int
		{
			return this.objects.length;
		}

		public function pushObject(data:ListElement):void
		{
			data.addEventListener(ListElementEvent.CHANGED, onObjectChanged);

			this.objects.push(data);
		}

		public function popObject():void
		{
			this.objects.pop().removeEventListener(ListElementEvent.CHANGED, onObjectChanged);
		}

		public function shiftObject():void
		{
			this.objects.shift().removeEventListener(ListElementEvent.CHANGED, onObjectChanged);
		}

		public function unshiftObject(data:ListElement):void
		{
			data.addEventListener(ListElementEvent.CHANGED, onObjectChanged);

			this.objects.unshift(data);
		}

		public function setData(data:Vector.<ListElement>):void
		{
			clearData();

			this.objects = data;

			for (var i:int = 0; i < this.objects.length; i++)
				this.objects[i].addEventListener(ListElementEvent.CHANGED, onObjectChanged);

			dispatchEvent(new ListDataEvent(ListDataEvent.UPDATE, this));
		}

		public function clearData():void
		{
			while (this.objects.length > 0)
				popObject();
		}

		public function onObjectChanged(e:ListElementEvent):void
		{}
	}
}