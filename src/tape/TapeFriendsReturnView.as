package tape
{
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import buttons.ButtonDouble;

	public class TapeFriendsReturnView extends TapeView
	{
		public function TapeFriendsReturnView():void
		{
			super(5, 2, 40, 7, 5, 5, 58, 58);

			initButtons(1.8, new Point(360, 50), new Point(30, 50));
		}

		public function initButtons(buttonsScale:Number, buttonNextPos:Point, buttonPrevPos:Point, buttonNextRotation:int = 0, buttonPrevRotation:int = 0):void
		{
			this.buttonNext.scaleX = buttonsScale;
			this.buttonPrevious.scaleX = -buttonsScale;
			this.buttonNext.scaleY = this.buttonPrevious.scaleY = buttonsScale;

			this.buttonNext.x = buttonNextPos.x;
			this.buttonNext.y = buttonNextPos.y;

			this.buttonPrevious.x = buttonPrevPos.x;
			this.buttonPrevious.y = buttonPrevPos.y;

			this.buttonNext.rotation = buttonNextRotation;
			this.buttonPrevious.rotation = buttonPrevRotation;
		}

		override protected function placeButtons():void
		{
			if (!this.buttonNext)
				this.buttonNext = new ButtonDouble(new TapeCabinetButtonActive, new TapeCabinetButtonInactive);

			if (!this.buttonPrevious)
				this.buttonPrevious = new ButtonDouble(new TapeCabinetButtonActive, new TapeCabinetButtonInactive);

			this.buttonNext.addEventListener(MouseEvent.CLICK, onButtonClickNext);
			addChild(this.buttonNext);
			this.buttonPrevious.addEventListener(MouseEvent.CLICK, onButtonClickPrev);
			addChild(this.buttonPrevious);
		}

		override protected function updateButtons():void
		{
			var canNext:Boolean = this.offset + getMaxShow() < this.data.objects.length;
			var canPrev:Boolean = this.offset > 0;

			this.buttonNext.visible = this.buttonPrevious.visible = (canNext || canPrev);

			super.updateButtons();
		}

		private function onButtonClickNext(e:MouseEvent):void
		{
			if (this.offset + getMaxShow() >= this.data.objects.length)
				return;

			this.offset += this.numRows * this.numColumns;
		}

		private function onButtonClickPrev(e:MouseEvent):void
		{
			if (this.offset == 0)
				return;
			this.offset -= this.numRows * this.numColumns;
		}
	}
}