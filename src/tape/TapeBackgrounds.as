package tape
{
	import flash.events.MouseEvent;

	import events.NewBackgroundEvent;
	import game.mainGame.Backgrounds;

	public class TapeBackgrounds extends TapeEditView
	{
		public function TapeBackgrounds(collection:Array = null):void
		{
			super();

			var tapeData:TapeData = new TapeData();

			var items:Array = Backgrounds.get().slice().reverse();

			if (collection != null)
				items = collection;

			for (var i:int = 0; i < items.length; i++)
			{
				var newElement:TapeBackgroundElement = new TapeBackgroundElement(items[i]);
				newElement.addEventListener(MouseEvent.CLICK, onClick);
				tapeData.addObject(newElement);
			}

			setData(tapeData);
		}

		private function onClick(e:MouseEvent = null):void
		{
			e.stopImmediatePropagation();

			var target:TapeBackgroundElement = e.currentTarget as TapeBackgroundElement;
			dispatchEvent(new NewBackgroundEvent(target.id));
		}
	}
}