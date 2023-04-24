package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class DialogTransfer extends Dialog
	{
		static private var _instance:DialogTransfer = null;

		public function DialogTransfer()
		{
			_instance = this;

			super("Restore profile");

			init();
		}

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogTransfer();

			_instance.show();
		}

		private function init():void
		{
			var format:TextFormat = new TextFormat(null, 14, 0x000000);
			format.align = TextFormatAlign.JUSTIFY;

			var textInfo:GameField = new GameField("If you already have an account in the old 'Squirrels'\napp and you want to restore it - press 'Restore my\nprofile' button (You must have the old app installed).\nThis button is also available in settings.", 20, 15, format);
			addChild(textInfo);

			var button:ButtonRestore = new ButtonRestore();
			button.scaleX = button.scaleY = 1.5;
			button.x = 120;
			button.y = 190;
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, sendData);

			var screenShot:RestoreScreenShot = new RestoreScreenShot();
			screenShot.x = 130;
			screenShot.y = 90;
			addChild(screenShot);

			place();

			this.height = 300;
			this.width = 450;
		}

		private function sendData(e:MouseEvent):void
		{
			Game.transfer();

			close();
		}
	}
}