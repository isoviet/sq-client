package tape
{
	import buttons.ButtonDouble;

	public class TapeEditView extends TapeView
	{
		public function TapeEditView():void
		{
			super(16, 2, 25, 7, 3, 2, 50, 40, false, false);
		}

		override public function set offset(value:int):void
		{
			this._offset = Math.max(value, 0);

			update();
		}

		override protected function placeButtons():void
		{
			this.buttonPrevious = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeftInactive);
			this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRightInactive);

			this.buttonPrevious.x = 0;
			this.buttonPrevious.y = 40 - int(this.buttonPrevious.height * 0.5);

			this.buttonNext.x = 875;
			this.buttonNext.y = 40 - int(this.buttonNext.height * 0.5);

			super.placeButtons();
		}

		override protected function update():void
		{
			super.update();

			if (this.data == null)
				return;

			this.buttonNext.visible = (this.data.objects.length > this.numRows * this.numColumns);
			this.buttonPrevious.visible = (this.data.objects.length > this.numRows * this.numColumns);
		}
	}
}