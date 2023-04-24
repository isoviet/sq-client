package tape
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import events.EditNewElementEvent;

	public class TapeEdit extends TapeEditView
	{
		public function TapeEdit(collection:Array):void
		{
			super();

			var tapeData:TapeEditData = new TapeEditData(collection);
			setData(tapeData);

			for each (var element:TapeEditElement in tapeData.objects)
				element.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(e:Event):void
		{
			e.stopImmediatePropagation();

			var target:TapeEditElement = e.currentTarget as TapeEditElement;
			dispatchEvent(new EditNewElementEvent(target.className));
		}
	}
}