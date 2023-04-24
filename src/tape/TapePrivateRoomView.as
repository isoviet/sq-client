package tape
{
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	import buttons.ButtonDouble;
	import tape.TapeView;

	public class TapePrivateRoomView extends TapeView
	{
		static private const OFFSET:int = 2;

		public function TapePrivateRoomView()
		{
			super(2, 3, 0, 0, 5, 0, 129, 25, false, true);
		}

		override protected function placeButtons():void
		{
			if (this.buttonPrevious == null)
				this.buttonPrevious = new ButtonDouble(new PrivateRoomButtonUp(), new SimpleButton());
			if (this.buttonNext == null)
				this.buttonNext = new ButtonDouble(new PrivateRoomButtonDown(), new SimpleButton());

			this.buttonPrevious.x = 125;
			this.buttonPrevious.y = -9;

			this.buttonNext.x = 125;
			this.buttonNext.y = 78;

			this.buttonPrevious.addEventListener(MouseEvent.CLICK, onButtonClickPrev);
			this.buttonNext.addEventListener(MouseEvent.CLICK, onButtonClickNext);

			addChild(this.buttonPrevious);
			addChild(this.buttonNext);
		}

		private function onButtonClickNext(e:MouseEvent):void
		{
			if (this.offset + getMaxShow() >= this.data.objects.length)
				return;

			this.offset += OFFSET;
		}

		private function onButtonClickPrev(e:MouseEvent):void
		{
			if (this.offset == 0)
				return;

			this.offset -= OFFSET;
		}

		public function refreshInfo():void
		{
			super.update();
		}
	}
}