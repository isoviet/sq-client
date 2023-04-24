package tape.list
{
	import flash.display.Sprite;
	import flash.events.Event;

	import tape.list.events.ListDataEvent;

	import interfaces.IDispose;

	public class ListView extends Sprite implements IDispose
	{
		protected var elementHeight:int;

		protected var data:ListData = null;

		private var sprite:Sprite = null;

		public function ListView(elementHeight:int):void
		{
			this.elementHeight = elementHeight;
			init();
		}

		public function dispose():void
		{
			if(this.data != null)
				this.data.removeEventListener(ListDataEvent.UPDATE, onDataUpdate);
		}

		public function clear():void
		{
			while (this.sprite.numChildren > 0)
				this.sprite.removeChildAt(0);
		}

		public function reset():void
		{
			if (this.data == null)
			{
				clear();
				return;
			}

			this.data.clearData();
			updateSprite();
		}

		public function get numElements():int
		{
			if (this.data == null)
				return 0;

			return this.data.objects.length;
		}

		public function setData(newData:ListData):void
		{
			if (this.data != null)
				this.data.removeEventListener(ListDataEvent.UPDATE, onDataUpdate);

			this.data = newData;

			updateSprite();

			this.data.addEventListener(ListDataEvent.UPDATE, onDataUpdate);
		}

		protected function updateSprite():void
		{
			clear();

			if (this.data == null)
				return;

			var y:int = 0;

			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if (!this.data.objects[i].canAdd)
					continue;

				this.data.objects[i].y = y;
				this.sprite.addChild(this.data.objects[i]);

				y += this.elementHeight;
			}
		}

		private function init():void
		{
			this.sprite = new Sprite();
			addChild(this.sprite);
		}

		private function onDataUpdate(e:Event):void
		{
			updateSprite();
		}
	}
}