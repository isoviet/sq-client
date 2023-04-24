package  
{
	import by.blooddy.crypto.MD5;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class LoginSprite extends Sprite 
	{
		private var emailField:TextField = new TextField();
		private var passwdField:TextField = new TextField();

		private var loginField:TextField = new TextField();
		private var regField:TextField = new TextField();

		private var statusField:TextField = new TextField();
		
		public function LoginSprite() 
		{
			this.emailField.x = 20;
			this.emailField.y = 20;
			this.emailField.width = 150;
			this.emailField.height = 20;
			this.emailField.background = true;
			this.emailField.type = TextFieldType.INPUT;
			this.emailField.backgroundColor = 0xC0C0C0;
			addChild(this.emailField);

			this.passwdField.x = 20;
			this.passwdField.y = 30 + 20;
			this.passwdField.width = 150;
			this.passwdField.height = 20;
			this.passwdField.background = true;
			this.passwdField.type = TextFieldType.INPUT;
			this.passwdField.backgroundColor = 0xC0C0C0;
			this.passwdField.displayAsPassword = true;
			addChild(this.passwdField);

			this.loginField.x = 20;
			this.loginField.y = 60 + 20;
			this.loginField.selectable = false;
			this.loginField.width = 150;
			this.loginField.height = 20;
			this.loginField.htmlText = "<a href='event:#'>Войти</a>";
			this.loginField.width = this.loginField.textWidth + 10;
			this.loginField.addEventListener(MouseEvent.CLICK, onLogin);
			addChild(this.loginField);

			this.regField.x = this.loginField.x + this.loginField.textWidth + 20 + 20;
			this.regField.y = 60 + 20;
			this.regField.selectable = false;
			this.regField.height = 20;
			this.regField.htmlText = "<a href='event:#'>Регистрация</a>";
			this.regField.width = this.regField.textWidth + 10;
			this.regField.addEventListener(MouseEvent.CLICK, onRegister);
			addChild(this.regField);

			this.statusField.x = 20;
			this.statusField.y = 90 + 20;
			this.statusField.selectable = false;
			this.statusField.width = 150;
			this.statusField.height = 60;
			this.statusField.htmlText = "";
			this.statusField.wordWrap = true;
			this.statusField.multiline = true;
			this.statusField.addEventListener(MouseEvent.CLICK, onLogin);
			this.statusField.defaultTextFormat = new TextFormat("Arial", 14, null, null, null, null, null, null, TextFormatAlign.CENTER);
			addChild(this.statusField);

			redraw();
		}

		private function checkEmail(email:String):Boolean
		{
			var signPos:int = email.indexOf("@");
			if (signPos < 2 || signPos >= email.length - 3)
				return false;
			return true;
		}

		private function onRegister(e:Event):void 
		{
			if (!checkEmail(this.emailField.text))
			{
				this.statusField.text = "Укажите верный адрес электронной почты";
				return;
			}

			if (this.passwdField.text.length < 8)
			{
				this.statusField.text = "Пароль должен содержать как минимум 8 символов";
				return;
			}
			SAMain.execute('register', { 'email': this.emailField.text, 'passwd': MD5.hash(this.passwdField.text) }, onRegExecute);
		}
		
		private function onRegExecute(data:*):void 
		{
			if ('RegError' in data)
			{
				switch (data['RegError'])
				{
					case 'Email exists': this.statusField.text = "Это адрес уже занят"; break;
					case 'Check Your email': this.statusField.text = "На это адрес уже было отправлено письмо с подтверждением регистрации"; break;
				}
				return;
			}
			this.statusField.text = "На это адрес отправлено письмо с подтверждением регистрации";
			if ('link' in data)
				trace(data['link']);
		}

		private function onLogin(e:Event):void 
		{
			SAMain.execute('auth', { 'email': this.emailField.text, 'passwd': MD5.hash(this.passwdField.text) }, onLoginExecute);
		}
		
		private function onLoginExecute(data:*):void 
		{
			if ('LoginFailed' in data)
			{
				this.statusField.text = "Неверное имя пользователя или пароль";
				return;
			}

			SAMain.USER_ID = data['id'];
			SAMain.SESSION_KEY = data['sig'];
			this.statusField.text = "Авторизовано";
			this.dispatchEvent(new Event("LOGIN"));
		}
		
		private function redraw():void 
		{
			this.graphics.clear();
			this.graphics.beginFill(0x8080C0, 0.5);
			this.graphics.drawRoundRectComplex( 0, 0, this.width + 40, this.height + 40, 20, 20, 20, 20);
		}
		
	}

}