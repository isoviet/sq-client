package tape
{
	import flash.events.MouseEvent;

	import events.EditNewElementEvent;
	import tape.TapeData;
	import tape.TapeShamanView;

	public class TapeJoints extends TapeShamanView
	{
		public function TapeJoints(collection:Array):void
		{
			super(13, 2, 32, 8, false);

			var tapeData:TapeData = new TapeData();

			for (var i:int = 0; i < collection.length; i++)
			{
				var element:TapeEditElement = new TapeEditElement(collection[i]);
				element.addEventListener(MouseEvent.CLICK, onClick);
				tapeData.addObject(element);
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