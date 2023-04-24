package dialogs
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;

	import buttons.ButtonBase;

	public class DialogWelcome extends Dialog
	{
		public function DialogWelcome()
		{
			super(gls("Обучающий уровень"));

			var textFormat:TextFormat = new TextFormat(null, 12, 0x4A240F, true);
			textFormat.align = TextFormatAlign.CENTER;

			var textField:GameField = new GameField(gls("Для того, чтобы отправиться\nв приключение с другими белками,\nтебе необходимо пройти обучение."), 10, 10, textFormat);
			textField.x = int((270 - textField.textWidth) * 0.5);
			addChild(textField);

			var button:ButtonBase = new ButtonBase(gls("Ок"));
			button.x = 100;
			button.y = 60;
			button.addEventListener(MouseEvent.CLICK, hide);
			addChild(button);

			place();

			this.width = 305;
			this.height = 150;
		}

		override public function show():void
		{
			super.show();

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
		}
		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}

		private function onKey(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.W:
				case Keyboard.SPACE:
				case Keyboard.UP:
				case Keyboard.A:
				case Keyboard.LEFT:
				case Keyboard.D:
				case Keyboard.RIGHT:
					break;
				default:
					return;
			}
			hide();
		}
	}
}