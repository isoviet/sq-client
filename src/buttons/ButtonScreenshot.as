package buttons
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import dialogs.DialogScreenshot;
	import statuses.Status;

	public class ButtonScreenshot extends Sprite
	{
		private var status:Status;

		public function ButtonScreenshot(isMainRoom:Boolean = false):void
		{
			super();

			if (!isMainRoom)
			{
				var photoStand:PhotoStand = new PhotoStand();
				photoStand.x = -6;
				photoStand.y = 19;
				addChild(photoStand);
			}

			var button:SimpleButton = isMainRoom ? new ButtonPhotoHeader() : new PhotoButton();
			button.addEventListener(MouseEvent.CLICK, onClick);
			addChild(button);

			this.status = new Status(button, gls("Снимок экрана"));
		}

		private function onClick(e:MouseEvent):void
		{
			this.status.visible = false;
			DialogScreenshot.show();
			this.status.visible = true;
		}
	}
}