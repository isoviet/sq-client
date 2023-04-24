package dialogs
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import buttons.ButtonBase;

	public class DialogSendError extends Dialog
	{
		private var fieldPlayerID:TextField = new TextField();
		private var fieldStatus:GameField = null;

		public function DialogSendError():void
		{
			super(gls("Сообщить об ошибке"));

			init();

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, oKey, false, 0, true);
		}

		private function oKey(e:KeyboardEvent):void
		{
			if (!e || !Game.self || !Game.self.moderator)
				return;
			if (e.ctrlKey && e.keyCode == Keyboard.H)
				show();
		}

		private function init():void
		{
			addChild(new GameField(gls("Текст ошибки:"), 0, 5, new TextFormat(null, 13, 0x000000)));
			this.fieldPlayerID.x = 0;
			this.fieldPlayerID.y = 35;
			this.fieldPlayerID.width = 320;
			this.fieldPlayerID.height = 40;
			this.fieldPlayerID.multiline = true;
			this.fieldPlayerID.wordWrap = true;
			this.fieldPlayerID.type = TextFieldType.INPUT;
			this.fieldPlayerID.defaultTextFormat = new TextFormat(null, 13, 0x000000, true);
			this.fieldPlayerID.borderColor = 0xb3b3b3;
			this.fieldPlayerID.border = true;
			this.fieldPlayerID.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addChild(this.fieldPlayerID);

			this.fieldStatus = new GameField("", 120, 85, new TextFormat(null, 15, 0x000000, true));
			addChild(this.fieldStatus);

			var button:ButtonBase = new ButtonBase(gls("Отправить"));
			button.x = 0;
			button.y = 80;
			button.addEventListener(MouseEvent.CLICK, request);
			addChild(button);

			place();

			this.width = 350;
			this.height += 40;
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (this.fieldStatus.text == "")
				return;
			this.fieldStatus.text = "";
		}

		private function request(event:MouseEvent):void
		{
			PreLoader.sendError(new Error("Текст ошибки: " + this.fieldPlayerID.text, 754));

			this.fieldPlayerID.text = "";
			this.fieldStatus.text = gls("Сообщение отправлено");
		}
	}
}