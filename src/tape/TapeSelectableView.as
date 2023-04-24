package tape
{
	import tape.events.TapeElementEvent;

	public class TapeSelectableView extends TapeView
	{
		public var lastSticked:TapeSelectableObject = null;
		public var pageSelection:Boolean = false;

		public function TapeSelectableView(numColumns:int, numRows:int, leftMargin:int, topMargin:int, offsetX:int, offsetY:int, objectWidth:int, objectHeight:int, pagination:Boolean = false, isSnake:Boolean = false, byItems:Boolean = false)
		{
			super(numColumns, numRows, leftMargin, topMargin, offsetX, offsetY, objectWidth, objectHeight, pagination, isSnake, byItems);

			init();
		}

		protected function init():void
		{}

		override public function setData(data:TapeData):void
		{
			if (this.data != null)
				this.data.removeEventListener(TapeElementEvent.STICKED, onStickElement);

			super.setData(data);

			this.data.addEventListener(TapeElementEvent.STICKED, onStickElement);
		}

		override protected function gotoPage(index:int, direction:int):void
		{
			super.gotoPage(index, direction);

			if (this.pageSelection && this.data.objects.length > index)
				select(this.data.objects[index] as TapeSelectableObject);
		}

		public function deselect():void
		{
			select(null);
		}

		protected function onStickElement(e:TapeElementEvent):void
		{
			select(e.element as TapeSelectableObject);
		}

		public function select(selected:TapeSelectableObject):void
		{
			if (this.lastSticked != null)
				this.lastSticked.selected = false;

			this.lastSticked = selected;

			if (this.lastSticked != null)
				this.lastSticked.selected = true;
			updateInfo(this.lastSticked);

			dispatchEvent(new TapeElementEvent(this.lastSticked, TapeElementEvent.SELECTED));
		}

		protected function updateInfo(selected:TapeSelectableObject):void
		{}
	}
}