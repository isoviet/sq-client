package tape
{
	import events.GameEvent;

	public class TapeDecorationsData extends TapeData
	{
		public function TapeDecorationsData():void
		{
			super();

			setData([]);

			for each (var element:TapeDecorationsElement in this.objects)
			{
				element.selected = (Game.self['interior'].indexOf(element.id) != -1);
				element.bougth = InteriorManager.haveDecoration(element.id);
			}

			InteriorManager.addEventListener(GameEvent.INTERIOR_CHANGE, changeInterior);
		}

		static private function sortDecorations(a:TapeDecorationsElement, b:TapeDecorationsElement):int
		{
			if (a.bougth != b.bougth)
				return b.bougth ? 1 : -1;
			return (a.id < b.id ? 1 : -1);
		}

		override public function setData(ids:Array):void
		{
			for (var i:int = 0; i < InteriorData.DATA.length; i++)
				addObject(new TapeDecorationsElement(i));
			sort();
		}

		override protected function sort():void
		{
			this.objects.sort(sortDecorations);
		}

		private function changeInterior(e:GameEvent = null):void
		{
			for each (var element:TapeDecorationsElement in this.objects)
			{
				element.selected = (Game.self['interior'].indexOf(element.id) != -1);
				element.bougth = InteriorManager.haveDecoration(element.id);
			}
			sort();
		}
	}
}