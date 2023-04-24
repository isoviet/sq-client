package dialogs
{
	import fl.controls.CheckBox;

	import game.mainGame.gameEditor.SquirrelGameEditor;
	import views.LabledInput;

	import utils.TextFieldUtil;

	public class DialogEditorConfig extends Dialog
	{
		private var game:SquirrelGameEditor;
		private var countInput:LabledInput = new LabledInput(gls("Кол-во белок:"));
		private var hareCheckBox:CheckBox = new CheckBox();

		public function DialogEditorConfig(game:SquirrelGameEditor):void
		{
			super(gls("Настройки тестирования\nкарты"));
			this.game = game;

			this.countInput.input.text = "2";
			this.countInput.input.restrict = "0-9";
			this.countInput.y = 20;
			addChild(this.countInput);

			TextFieldUtil.setStyleCheckBox(this.hareCheckBox);
			this.hareCheckBox.y = this.countInput.y + this.countInput.height + 10;
			this.hareCheckBox.label = gls("Добавить зайца НеСудьбы");
			this.hareCheckBox.width = 200;
			this.hareCheckBox.drawNow();
			addChild(this.hareCheckBox);

			place();
			this.width = 350;
			this.height = 170;
		}

		public function get squirrelsCount():int
		{
			return int(this.countInput.input.text);
		}

		public function set squirrelsCount(value:int):void
		{
			this.countInput.input.text = String(value);
		}

		public function get addHare():Boolean
		{
			return this.hareCheckBox.selected;
		}

		public function dispose():void
		{
			this.game = null;
		}
	}
}