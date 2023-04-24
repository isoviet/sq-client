package tape
{
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	import game.gameData.DialogOfferManager;

	public class TapeNewsElementOK extends TapeNewsElement
	{
		public function TapeNewsElementOK():void
		{
			super(int.MAX_VALUE, OFFER_OK);
		}

		override protected function init():void
		{
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0, 0, 90, 90);

			var imageButton:SimpleButton = DialogOfferManager.getButtonOfferOK();
			imageButton.x = 23;
			imageButton.y = 25;
			imageButton.mouseEnabled = false;
			addChild(imageButton);

			var image:ImageNewsButtonFrame = new ImageNewsButtonFrame();
			image.mouseEnabled = false;
			addChild(image);

			this.backSelected = new ImageNewsButtonSelected();
			this.backSelected.visible = false;
			this.backSelected.mouseEnabled = false;
			this.backSelected.mouseChildren = false;
			addChild(this.backSelected);

			addEventListener(MouseEvent.MOUSE_DOWN, stick);
		}
	}
}