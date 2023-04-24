package tape.list
{
	import tape.list.events.ListDataEvent;
	import tape.list.events.ListElementEvent;

	public class ListFragsData extends ListData
	{
		public function ListFragsData():void
		{}

		static private function sortByFrags(a:ListFragsElement, b:ListFragsElement):int
		{
			if (a.frags > b.frags)
				return -1;
			if (a.frags < b.frags)
				return 1;

			if (a.player.name.toUpperCase() > b.player.name.toUpperCase())
				return 1;

			return -1;
		}

		override public function setData(data:Vector.<ListElement>):void
		{
			super.setData(data);

			sort();
		}

		override public function onObjectChanged(e:ListElementEvent):void
		{
			sort();
		}

		private function sort():void
		{
			for each (var data:ListElement in this.objects)
			{
				if (data.canAdd)
					continue;
				return;
			}

			this.objects.sort(sortByFrags);

			dispatchEvent(new ListDataEvent(ListDataEvent.UPDATE, this));
		}
	}
}