package tape
{
	import buttons.ButtonDouble;
	import events.GameEvent;

	public class TapeDecorations extends TapeView
	{
		static public const MAX_SHOW:int = 10;

		private var tapeData:TapeDecorationsData;

		public function TapeDecorations():void
		{
			super(10, 1, 44, -3, 7, 2, 75, 60, false, false);

			this.tapeData = new TapeDecorationsData();
			setData(this.tapeData);

			InteriorManager.addEventListener(GameEvent.INTERIOR_CHANGE, changeInterior);
		}

		override public function set offset(value:int):void
		{
			this._offset = value;

			if (this.data != null)
				this._offset = Math.min(this._offset, this.data.objects.length - MAX_SHOW);
			this._offset = Math.max(this._offset, 0);

			update();
		}

		override protected function placeButtons():void
		{
			this.buttonPrevious = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeftInactive);
			this.buttonRewindPrevious = new ButtonDouble(new ButtonRewindLeftDouble, new ButtonRewindLeftDoubleInactive);
			this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRightInactive);
			this.buttonRewindNext = new ButtonDouble(new ButtonRewindRightDouble, new ButtonRewindRightDoubleInactive);

			this.buttonPrevious.setState(true);
			this.buttonRewindPrevious.setState(true);
			this.buttonNext.setState(true);
			this.buttonRewindNext.setState(true);

			this.buttonPrevious.x = 10;
			this.buttonPrevious.y = 7;

			this.buttonRewindPrevious.x = 10;
			this.buttonRewindPrevious.y = 38;

			this.buttonNext.x = 862;
			this.buttonNext.y = 7;

			this.buttonRewindNext.x = 862;
			this.buttonRewindNext.y = 38;

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

		private function changeInterior(e:GameEvent = null):void
		{
			update();
		}
	}
}