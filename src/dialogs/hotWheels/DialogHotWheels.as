package dialogs.hotWheels
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import buttons.ButtonBase;
	import dialogs.Dialog;

	public class DialogHotWheels extends Dialog
	{
		static private var _instance:DialogHotWheels = null;

		public function DialogHotWheels()
		{
			super("", false, true, null, false);

			init();
		}

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogHotWheels();
			_instance.show();
		}

		static public function hide():void
		{
			if (_instance)
				_instance.hide();
		}

		private function init():void
		{
			addChild(new DialogHotWheelsBack);

			var button:ButtonBase = new ButtonBase("Перейти");
			button.x = 45 + int((445 - button.width) * 0.5);
			button.y = 347 + 167 - 40;
			button.addEventListener(MouseEvent.CLICK, link);
			addChild(button);

			place();

			this.buttonClose.x -= 35;
			this.buttonClose.y += 80;
		}

		private function link(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("https://apps.facebook.com/squirrelsgame"), "_blank");

			hide();
		}
	}
}