package tape.list
{
	import tape.list.events.ListDataEvent;

	public class PlayerResultView extends ListView
	{
		public function PlayerResultView()
		{
			super(21);
		}

		override protected function updateSprite():void
		{
			clear();

			if (this.data == null)
				return;

			super.updateSprite();

			var number:int = 0;
			var y:int = 0;
			for each (var element:PlayerResultListElement in this.data.objects)
			{
				element.number = number;
				element.y = y;

				y += this.elementHeight;
				if (!element.shaman)
					number++;
			}

			this.data.dispatchEvent(new ListDataEvent(ListDataEvent.SORTED, this.data));
		}
	}
}