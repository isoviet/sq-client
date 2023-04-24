package buttons
{
	public class ButtonRatingTabsTape extends ButtonTabsTape
	{
		private var buttonCount:int = 0;

		public function ButtonRatingTabsTape(_buttonCount:int, leftMargin:int, topMargin:int, offsetX:int):void
		{
			this.buttonCount = _buttonCount;
			super(1, _buttonCount, leftMargin, topMargin, offsetX, 0);
		}

		override protected function placeButtons():void
		{
			this.buttonPrev = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeft);
			this.buttonPrev.scaleX = this.buttonPrev.scaleY = 1.5;
			this.buttonPrev.x = -27;
			this.buttonPrev.y = 65;

			this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRight);
			this.buttonNext.scaleX = this.buttonNext.scaleY = 1.5;
			this.buttonNext.x = 630;
			this.buttonNext.y = 65;

			super.placeButtons();
		}
	}
}