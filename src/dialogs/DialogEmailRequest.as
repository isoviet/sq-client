package dialogs
{
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import events.ScreenEvent;
	import screens.ScreenLocation;
	import screens.Screens;

	import utils.EmailValidatorUtil;

	public class DialogEmailRequest extends Dialog
	{
		private var emailField:TextField;
		private var statusField:GameField;

		public function DialogEmailRequest():void
		{
			super("", true, false);

			init();
		}

		override public function show():void
		{
			//TODO WTF
			if (this.visible || Experience.selfLevel < 3)
				return;

			if (Screens.active is ScreenLocation)
			{
				super.show();
				return;
			}

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
		}

		private function init():void
		{
			var message:GameField = new GameField("", 0, 10, new TextFormat(null, 14, 0x1f1f1f));
			message.text = gls("Чтобы завершить создание вашего аккаунта,\nвведите адрес электронной почты:");
			addChild(message);

			var image:DisplayObject = addChild(new InviteKeyBackground());
			image.x = 45;
			image.y = 55;
			image.addEventListener(MouseEvent.CLICK, setFocus, false, 0, true);

			this.emailField = new TextField();
			this.emailField.x = 45;
			this.emailField.y = 58;
			this.emailField.defaultTextFormat = new TextFormat(null, 17, 0x3C1D07);
			this.emailField.width = 205;
			this.emailField.height = 23;
			this.emailField.selectable = true;
			this.emailField.type = TextFieldType.INPUT;
			this.emailField.text = "Email";
			this.emailField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			this.emailField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			addChild(this.emailField);

			this.statusField = new GameField("", 0, this.emailField.y + this.emailField.height + 8, new TextFormat(null, 14, 0xFF0000));
			addChild(this.statusField);

			var button:ButtonBase = new ButtonBase(gls("Ок"));
			button.addEventListener(MouseEvent.CLICK, onEnter, false, 0, true);

			place(button);

			this.height = this.topOffset + this.statusField.y + this.statusField.height + this.bottomOffset + button.height + 45;
			message.x = int((this.width - message.width) / 2) - this.leftOffset;
		}

		private function onEnter(e:MouseEvent):void
		{
			if (this.emailField.text == "" || this.emailField.text == "Email")
			{
				this.statusField.text = gls("Введите адрес электронной почты.");
				return;
			}

			if (!EmailValidatorUtil.validateEmail(this.emailField.text))
			{
				this.statusField.text = gls("Введён некорректный адрес электронной\nпочты.");
				return;
			}

			hide();

			Game.saveSelf({'name': Game.self.name, 'sex': Game.self.sex, 'email': this.emailField.text});
		}

		private function setFocus(e:MouseEvent):void
		{
			Game.stage.focus = this.emailField;
		}

		private function onFocusIn(e:FocusEvent):void
		{
			if (this.emailField.text != "Email")
				return;

			this.emailField.text = "";
		}

		private function onFocusOut(e:FocusEvent):void
		{
			if (this.emailField.text != "")
				return;

			this.emailField.text = "Email";
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (!(e.screen is ScreenLocation))
				return;

			Screens.instance.removeEventListener(ScreenEvent.SHOW, onScreenChanged);
			super.show();
		}
	}
}