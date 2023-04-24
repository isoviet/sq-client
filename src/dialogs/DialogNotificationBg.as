package dialogs
{
	public class DialogNotificationBg extends Dialog
	{
		public function DialogNotificationBg(captionDialog:* = null, canClose:Boolean = true, drag:Boolean = true):void
		{
			this.leftOffset = 20;
			this.rightOffset = 20;
			this.topOffset = 10;

			super(captionDialog, true, canClose, DialogBaseBackground, drag);
		}

		override protected function initClose():void
		{
			super.initClose();

			this.buttonClose.x -= 3;
			this.buttonClose.y -= 10;
		}
	}
}