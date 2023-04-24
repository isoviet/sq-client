package tape
{
	import flash.events.MouseEvent;

	import events.EditNewElementEvent;

	public class TapeHero extends TapeEditView
	{
		public function TapeHero(collection:Array):void
		{
			super();

			var tapeData:TapeData = new TapeData();

			for each (var className:Class in collection)
			{
				var newElement:TapeEditElement = new TapeEditElement(className);
				tapeData.addObject(newElement);
				newElement.addEventListener(MouseEvent.CLICK, onClick);
			}

			setData(tapeData);
		}

		private function onClick(e:MouseEvent):void
		{
			e.stopImmediatePropagation();

			var target:TapeEditElement = e.currentTarget as TapeEditElement;
			dispatchEvent(new EditNewElementEvent(target.className));
		}
	}
}