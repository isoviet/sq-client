package dialogs.hotWheels
{
	import flash.events.MouseEvent;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import loaders.ScreensLoader;
	import screens.ScreenWardrobe;

	public class DialogHotWheelsBonus extends Dialog
	{
		static private var _instance:DialogHotWheelsBonus = null;

		public function DialogHotWheelsBonus()
		{
			super("", false, true, null, false);

			init();
		}

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogHotWheelsBonus();
			_instance.show();
		}

		static public function hide():void
		{
			if (_instance)
				_instance.hide();
		}

		private function init():void
		{
			addChild(new DialogHotWheelsBonusBack);

			var button:ButtonBase = new ButtonBase("В гардероб");
			button.x = 45 + int((445 - button.width) * 0.5);
			button.y = 361 + 162 - 40;
			button.addEventListener(MouseEvent.CLICK, link);
			addChild(button);

			place();

			this.buttonClose.x -= 35;
			this.buttonClose.y += 80;
		}

		private function link(e:MouseEvent):void
		{
			ScreensLoader.load(ScreenWardrobe.instance);

			hide();
		}
	}
}