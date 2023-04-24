package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	import buttons.ButtonBase;

	public class DialogExit extends Dialog
	{
		private var saveFunction:Function;
		private var dontSaveFunction:Function;
		private var cancelFunction:Function;

		public function DialogExit(saveFunction:Function, dontSaveFunction:Function, cancelFunction:Function):void
		{
			super(gls("Выход"), true, false);

			this.saveFunction = saveFunction;
			this.dontSaveFunction = dontSaveFunction;
			this.cancelFunction = cancelFunction;

			var field:GameField = new GameField(gls("Вы уверены, что хотите выйти без сохранения изменений?"), 20, 10, new TextFormat(null, 14, 0x000000, null));
			addChild(field);

			var buttonSave:ButtonBase = new ButtonBase(gls("Сохранить"));
			buttonSave.addEventListener(MouseEvent.CLICK, onSave);

			var buttonNotSave:ButtonBase = new ButtonBase(gls("Не сохранять"));
			buttonNotSave.addEventListener(MouseEvent.CLICK, dontSave);

			var buttonCancel:ButtonBase = new ButtonBase(gls("Отмена"));
			buttonCancel.addEventListener(MouseEvent.CLICK, onCancel);

			place(buttonSave, buttonNotSave, buttonCancel);

			this.height += 70;
		}

		override protected function effectOpen():void
		{
		}

		private function onSave(e:MouseEvent):void
		{
			this.saveFunction();
			Mouse.cursor = MouseCursor.AUTO;
			hide();
		}

		private function dontSave(e:MouseEvent):void
		{
			this.dontSaveFunction();
			Mouse.cursor = MouseCursor.AUTO;
			hide();
		}

		private function onCancel(e:MouseEvent):void
		{
			this.cancelFunction();
			hide();
		}
	}
}