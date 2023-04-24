package tape
{
	import buttons.ButtonDouble;

	public class TapeShamanView extends TapeView
	{
		public function TapeShamanView(columns:int, rows:int, marginLeft:int, top:int, isSnake:Boolean):void
		{
			super(columns, rows, marginLeft, top, -42, -28, 95 - 2, 69, false, isSnake);
		}

		override public function set offset(value:int):void
		{
			this._offset = Math.max(value, 0);

			update();
		}

		override protected function placeButtons():void
		{
			if (this.buttonPrevious == null)
				this.buttonPrevious = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeftInactive);
			if (this.buttonNext == null)
				this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRightInactive);

			this.buttonPrevious.x = 2;
			this.buttonPrevious.y = int(((this.offsetY + this.objectHeight) * this.numRows - this.buttonNext.height) * 0.5) + this.topMargin;

			this.buttonNext.x = (this.offsetX + this.objectWidth) * this.numColumns - this.offsetX - 2;
			this.buttonNext.y = int(((this.offsetY + this.objectHeight) * this.numRows - this.buttonNext.height) * 0.5) + this.topMargin;

			super.placeButtons();
		}

		override protected function update():void
		{
			super.update();

			if (this.data == null)
				return;

			this.buttonNext.visible = (this.data.objects.length > this.numRows * this.numColumns);
			this.buttonPrevious.visible = (this.data.objects.length > this.numRows * this.numColumns);

			if ((this.offset == 0) || this.buttonPrevious.visible)
				return;

			this.offset = 0;
		}
	}
}