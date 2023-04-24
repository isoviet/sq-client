package com.sa
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	import fl.controls.CheckBox;

	import by.blooddy.crypto.MD5;

	public class LoginSprite extends Sprite
	{
		static private const link_data:Array = ["login", "register", "recover"];
		static private const link_names:Array = [["Вход", "Регистрация", "Восстановление пароля"],
							["Login", "Registration", "Password Recovery"]];

		static private var regData:Array = [{'Email incorrect': "Укажите верный адрес электронной почты",
							'Weak password': "Пароль должен содержать как минимум 8 символов",
							'Email exists.': "Этот адрес уже занят",
							'Check your email.': "На указанный e-mail отправлено письмо с подтверждением регистрации",
							'OK': "На указанный e-mail отправлено письмо с подтверждением регистрации"},
						{'Email incorrect': "Use valid e-mail address",
							'Weak password': "The password must contain at least 8 characters",
							'Email exists.': "This address is already in use",
							'Check your email.': "This address is already sent a confirmation letter",
							'OK': "This address is already sent a confirmation letter"}];

		static private var textSetPassword:String = "";
		static private var textSetNewPassword:String = "";
		static private var textMail:String = "";
		static private var textPassword:String = "";
		static private var textNewPassword:String = "";
		static private var textWrongLogin:String = "";
		static private var textOnLogin:String = "";

		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Arial";
				font-size: 15px;
				color: #FFFFFF;
			}
			a {
				text-decoration: none;
			}
			a:hover {
				color: #0AEE49;
				text-decoration: underline;
			}
			.select {
				text-decoration: underline;
			}
		]]>).toString();

		static private const FORMAT_WHITE_18_CENTER:TextFormat = new TextFormat("Arial", 18, 0xFFFFFF, true, null, null, null, null, "center");
		static private const FORMAT_WHITE_20:TextFormat = new TextFormat("Arial", 20, 0xFFFFFF, true);
		static private const FORMAT_BLACK_20:TextFormat = new TextFormat("Arial", 20, 0x000000, true);
		static private const FORMAT_GREY_20:TextFormat = new TextFormat("Arial", 20, 0xC0C0C0, true);
		static private const FORMAT_RED_16_CENTER:TextFormat = new TextFormat("Arial", 16, 0xFF7D6D, true, null, null, null, null, TextFormatAlign.CENTER);

		private var fieldEmail:TextField = null;
		private var fieldPassword:TextField = null;

		private var buttonLoginOAuth:SimpleButton = null;
		private var buttonLogin:SimpleButton = null;
		private var buttonRecover:SimpleButton = null;
		private var buttonRegister:SimpleButton = null;

		private var fieldLink:TextField = new TextField();
		private var fieldStatus:TextField = new TextField();
		private var fieldName:TextField = new TextField();

		private var localData:SharedObject = SharedObject.getLocal("RGLogin", "/");

		private var passwordHash:String = "";

		private var statusTimer:Timer = new Timer(5000, 1);
		private var isPress:Boolean = false;

		private var fieldBacks:Array = [];
		private var photo:Loader = new Loader();
		private var photoMask:Sprite = new Sprite();
		private var photoSprite:Sprite = new Sprite();

		private var socialBar:MovieClip = null;
		private var socialButtons:Array = [];

		private var spriteMail:Sprite = new Sprite();
		private var mailCaptions:Array = [];
		private var mailButtons:Array = [];

		private var isEMail:Boolean = false;

		public function LoginSprite():void
		{
			textSetPassword = Main.isRus ? "Укажите пароль" : "Enter password";
			textSetNewPassword = Main.isRus ? "Укажите новый пароль" : "Enter new password";
			textMail = Main.isRus ? "e-mail" : "e-mail";
			textPassword = Main.isRus ? "Пароль" : "Password";
			textNewPassword = Main.isRus ? "Новый пароль" : "New password";
			textWrongLogin = Main.isRus ? "Неверное имя пользователя или пароль" : "Incorrect username or password";
			textOnLogin = Main.isRus ? "Выполняется вход" : "Signing in";

			var panel:MovieClip = null;
			if (Main.isRus)
			{
				this.socialBar = new SocialBarRu();
				this.socialButtons.push((this.socialBar as SocialBarRu).buttonVK, (this.socialBar as SocialBarRu).buttonOK,
					(this.socialBar as SocialBarRu).buttonFB, (this.socialBar as SocialBarRu).buttonMM);
				for (var i:int = 0; i < this.socialButtons.length; i++)
					this.socialButtons[i].addEventListener(MouseEvent.CLICK, onSocialLogin);
				this.socialButtons.push((this.socialBar as SocialBarRu).buttonEMail);
				(this.socialBar as SocialBarRu).buttonEMail.addEventListener(MouseEvent.CLICK, onEmailLogin);
				(this.socialBar as SocialBarRu).buttonBack.addEventListener(MouseEvent.CLICK, logout);
				(this.socialBar as SocialBarRu).buttonBack.visible = false;
				panel = (this.socialBar as SocialBarRu).panelView;
			}
			else
			{
				this.socialBar = new SocialBarEn();
				this.socialButtons.push((this.socialBar as SocialBarEn).buttonFB);
				for (i = 0; i < this.socialButtons.length; i++)
					this.socialButtons[i].addEventListener(MouseEvent.CLICK, onSocialLogin);
				this.socialButtons.push((this.socialBar as SocialBarEn).buttonEMail);
				(this.socialBar as SocialBarEn).buttonEMail.addEventListener(MouseEvent.CLICK, onEmailLogin);
				(this.socialBar as SocialBarEn).buttonBack.addEventListener(MouseEvent.CLICK, logout);
				(this.socialBar as SocialBarEn).buttonBack.visible = false;
				panel = (this.socialBar as SocialBarEn).panelView;
			}
			panel.addChild(getField(Main.isRus ? "социальную сеть" : "social net", 0, 5, 410, 0, FORMAT_WHITE_18_CENTER));
			panel.addChild(getField(Main.isRus ? "почту" : "e-mail", 420, 5, 110, 0, FORMAT_WHITE_18_CENTER));
			addChild(socialBar);

			this.addEventListener(MouseEvent.CLICK, onHideStatus);
			this.statusTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHideStatus);

			var names:Array = Main.isRus ? ["e-mail:", "Пароль:"] : ["e-mail:", "Password:"];
			for (i = 0; i < 2; i++)
			{
				var sprite:Sprite = new Sprite();
				var textBack:TextInput_upSkin = new TextInput_upSkin();
				textBack.width = 435;
				textBack.height = 35;
				sprite.addChild(textBack);

				var field:TextField = getField(names[i], 0, 0, 0, 0, FORMAT_WHITE_20);
				field.x = -field.textWidth - 20;
				field.y = int((sprite.height - field.textHeight) * 0.5) - 7;
				sprite.addChild(field);

				sprite.x = 130;
				sprite.y = 130 + i * 60;
				sprite.visible = false;
				addChild(sprite);

				this.fieldBacks.push(sprite);
			}

			this.fieldEmail = getField("", 115, 128, 425, 35, FORMAT_BLACK_20);
			this.fieldEmail.type = TextFieldType.INPUT;
			this.fieldEmail.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			this.fieldEmail.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.fieldEmail.visible = false;
			this.fieldEmail.selectable = true;
			addChild(this.fieldEmail);

			this.fieldPassword = getField("", 115, 188, 425, 35, FORMAT_BLACK_20);
			this.fieldPassword.type = TextFieldType.INPUT;
			this.fieldPassword.displayAsPassword = true;
			this.fieldPassword.addEventListener(FocusEvent.FOCUS_IN, onPassFocus);
			this.fieldPassword.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			this.fieldPassword.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.fieldPassword.visible = false;
			this.fieldPassword.selectable = true;
			addChild(this.fieldPassword);

			this.photoMask.graphics.beginFill(0x000000);
			this.photoMask.graphics.drawRect(0, 0, 60, 60);
			this.photo.mask = this.photoMask;
			addChild(this.photoMask);

			addChild(this.photoSprite);

			this.photo.x = 125;
			this.photo.y = 180;
			this.photo.contentLoaderInfo.addEventListener(Event.COMPLETE, onPhotoLoaded);
			addChild(this.photo);

			this.fieldName = getField("", 0, 210, 570, 0, FORMAT_WHITE_18_CENTER);
			this.fieldName.visible = false;
			addChild(this.fieldName);

			this.buttonLoginOAuth = Main.isRus ? new LoginButtonRu() : new LoginButtonEn();
			this.buttonLoginOAuth.x = 286;
			this.buttonLoginOAuth.y = 300;
			this.buttonLoginOAuth.addEventListener(MouseEvent.CLICK, onLogin);
			this.buttonLoginOAuth.visible = false;
			addChild(this.buttonLoginOAuth);

			this.spriteMail.visible = false;
			addChild(this.spriteMail);

			this.mailCaptions = Main.isRus ? [new ImageCaptionLoginRu, new ImageCaptionRegisterRu, new ImageCaptionRecoverRu]
				: [new ImageCaptionLoginEn, new ImageCaptionRegisterEn, new ImageCaptionRecoverEn];
			for (i = 0; i < this.mailCaptions.length; i++)
			{
				this.mailCaptions[i].x = int(570 - this.mailCaptions[i].width) * 0.5;
				this.mailCaptions[i].y = 93;
				this.mailCaptions[i].visible = i == 0;
				this.spriteMail.addChild(this.mailCaptions[i]);
			}

			this.buttonLogin = Main.isRus ? new LoginButtonRu() : new LoginButtonEn();
			this.buttonLogin.x = 286;
			this.buttonLogin.y = 300;
			this.buttonLogin.addEventListener(MouseEvent.CLICK, onLogin);
			this.spriteMail.addChild(this.buttonLogin);

			this.buttonRegister = Main.isRus ? new RegisterButtonRu() : new RegisterButtonEn();
			this.buttonRegister.x = 286;
			this.buttonRegister.y = 300;
			this.buttonRegister.addEventListener(MouseEvent.CLICK, onRegister);
			this.buttonRegister.visible = false;
			this.spriteMail.addChild(this.buttonRegister);

			this.buttonRecover = Main.isRus ? new RecoverButtonRu() : new RecoverButtonEn();
			this.buttonRecover.x = 286;
			this.buttonRecover.y = 300;
			this.buttonRecover.addEventListener(MouseEvent.CLICK, onRecover);
			this.buttonRecover.visible = false;
			this.spriteMail.addChild(this.buttonRecover);

			this.mailButtons.push(this.buttonLogin, this.buttonRegister, this.buttonRecover);

			this.fieldLink = getField("", 0, 250, 0, 30, FORMAT_WHITE_20);
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);
			this.fieldLink.styleSheet = style;

			selectLinkText(0);

			this.fieldLink.width = this.fieldLink.textWidth + 10;
			this.fieldLink.x = int((570 - this.fieldLink.width) * 0.5) + 10;
			this.fieldLink.addEventListener(TextEvent.LINK, onLink);
			this.spriteMail.addChild(this.fieldLink);

			this.fieldStatus = getField("", 0, 335, 570, 60, FORMAT_RED_16_CENTER);
			addChild(this.fieldStatus);

			this.status = "";

			if ('lastLogin' in this.localData.data)
			{
				this.fieldEmail.text = this.localData.data['lastLogin']['email'];
				this.fieldPassword.text = "<<HIDDEN>>";
				this.passwordHash = this.localData.data['lastLogin']['passwd'];
			}
			else
			{
				this.fieldEmail.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT, true, false, this.fieldEmail));
				this.fieldPassword.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT, true, false, this.fieldPassword));

				selectLinkText(1);
			}

			addEventListener(Event.ADDED_TO_STAGE, onStage);
		}

		public function loadPhoto(url:String, name:String):void
		{
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			this.photo.load(new URLRequest(url), context);

			this.fieldName.text = name;
			this.photoSprite.graphics.clear();
			this.photoSprite.graphics.beginFill(0x000000, 0.2);
			this.photoSprite.graphics.drawRoundRect((this.fieldName.width -this.fieldName.textWidth) *0.5 - 7, this.fieldName.y - 3, this.fieldName.textWidth + 14, this.fieldName.textHeight + 8, 10);

			this.oauthInterface = true;
			this.socialInterface = false;
			this.mailInterface = false;
		}

		private function logout(e:MouseEvent):void
		{
			if (Main.socialType == "" && !this.isEMail)
				return;
			Main.socialType = "";
			this.isEMail = false;

			this.socialInterface = true;
			this.oauthInterface = false;
			this.mailInterface = false;
		}

		private function onEmailLogin(e:MouseEvent):void
		{
			this.isEMail = true;

			this.socialInterface = false;
			this.mailInterface = true;
		}

		private function set socialInterface(value:Boolean):void
		{
			this.socialBar.buttonBack.visible = !value;
			this.socialBar.imageEnter.visible = value;
			this.socialBar.panelView.visible = value;
			for (var i:int = 0; i < this.socialButtons.length; i++)
				this.socialButtons[i].visible = value;
		}

		private function set mailInterface(value:Boolean):void
		{
			this.fieldEmail.visible = value;
			this.fieldPassword.visible = value;
			for (var i:int = 0; i < this.fieldBacks.length; i++)
				this.fieldBacks[i].visible = value;

			this.spriteMail.visible = value;
		}

		private function set oauthInterface(value:Boolean):void
		{
			this.photo.visible = value;
			this.fieldName.visible = value;
			this.buttonLoginOAuth.visible = value;
			this.photoSprite.visible = value;
		}

		private function onStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onKeyUp(e:KeyboardEvent):void
		{
			this.isPress = false;
		}

		private function onKeyPress(e:KeyboardEvent):void
		{
			if ((e.keyCode != Keyboard.ENTER) || this.isPress)
				return;
			this.isPress = true;
			if (this.buttonLogin.visible)
				onLogin(null);
			if (this.buttonRecover.visible)
				onRecover(null);
			if (this.buttonRegister.visible)
				onRegister(null);
		}

		private function onPassFocus(e:Event):void
		{
			if (this.fieldPassword.text != "<<HIDDEN>>")
				return;
			this.fieldPassword.text = "";
		}

		private function onFocusIn(e:FocusEvent):void
		{
			var target:TextField = e.currentTarget as TextField;
			if (target == this.fieldEmail && this.fieldEmail.text == textMail || target == this.fieldPassword && (this.fieldPassword.text == textPassword || this.fieldPassword.text == textNewPassword))
			{
				target.defaultTextFormat = FORMAT_BLACK_20;
				target.text = "";
				if (target == this.fieldPassword)
					target.displayAsPassword = true;
			}
		}

		private function onFocusOut(e:FocusEvent):void
		{
			var target:TextField = e.currentTarget as TextField;
			if (target.text != "")
				return;

			target.defaultTextFormat = FORMAT_GREY_20;
			target.text = target == this.fieldEmail ? textMail : (this.buttonRecover.visible ? textNewPassword : textPassword);
			if (target == this.fieldPassword)
				target.displayAsPassword = false;
		}

		private function onRegister(e:Event):void
		{
			if (this.fieldPassword.textColor == FORMAT_GREY_20.color)
			{
				this.status = textSetPassword;
				return;
			}
			Processor.execute('register', {'email': this.fieldEmail.text, 'passwd': MD5.hash(this.fieldPassword.text), 'lang': Main.isRus ? "ru" : "en"}, onRegExecute);
		}

		private function onRegExecute(data:*):void
		{
			if (data in regData[Main.isRus ? 0 : 1])
				this.status = regData[Main.isRus ? 0 : 1][data];
		}

		private function onRecover(e:Event):void
		{
			if (this.fieldPassword.textColor == FORMAT_GREY_20.color)
				this.status = textSetNewPassword;
			else
				Processor.execute('recover', {'email': this.fieldEmail.text, 'passwd': MD5.hash(this.fieldPassword.text), 'lang': Main.isRus ? "ru" : "en"}, onRecoverExecute);
		}

		private function onRecoverExecute(data:*):void
		{
			if (data in regData[Main.isRus ? 0 : 1])
				this.status = regData[Main.isRus ? 0 : 1][data];
		}

		private function set status(value:String):void
		{
			if (value != "")
			{
				this.statusTimer.reset();
				this.statusTimer.start();
			}
			this.fieldStatus.text = value;
		}

		private function onLogin(e:Event):void
		{
			if (Main.socialType != "")
				Main.start();
			else if (this.fieldPassword.textColor == FORMAT_GREY_20.color)
				this.status = textSetPassword;
			else
				Processor.execute('auth', { 'email': this.fieldEmail.text, 'passwd': passHash}, onLoginExecute);
		}

		private function onLoginExecute(data:*):void
		{
			if (data == "Login failed")
			{
				this.status = textWrongLogin;
				return;
			}

			Services.userId = data['id'];
			Services.sessionKey = data['sig'];

			this.status = textOnLogin;

			Processor.execute('getAppInfo', {}, onAppInfo);

			this.localData.data['lastLogin'] = {'email': this.fieldEmail.text, 'passwd': passHash};

			this.localData.flush();
		}

		private function get passHash():String
		{
			return this.fieldPassword.text == "<<HIDDEN>>" ? this.passwordHash : MD5.hash(this.fieldPassword.text);
		}

		private function onAppInfo(data:*):void
		{
			Services.authKey = data['authkey'];
			Services.connect();
		}

		private function onPhotoLoaded(e:Event):void
		{
			this.photo.width = 60;
			this.photo.height = 60;
			this.photo.scaleY = this.photo.scaleX = Math.max(this.photo.scaleY, this.photo.scaleX);
			this.photo.x = 285 - int(this.photo.width * 0.5);
			this.photo.y = 130;

			this.photoMask.x = this.photo.x;
			this.photoMask.y = this.photo.y;

			this.photoSprite.graphics.drawRoundRect(this.photo.x - 10, this.photo.y - 10, this.photo.width + 20, this.photo.height + 20, 10);
		}

		private function onHideStatus(e:Event):void
		{
			if (e.target is SimpleButton)
				return;
			this.status = "";
		}

		private function onLink(e:TextEvent):void
		{
			var id:int = link_data.indexOf(e.text);

			if (id == -1)
				return;

			selectLinkText(id);

			if (!this.buttonLogin.visible)
				this.fieldPassword.text = "";
			this.fieldEmail.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT, true, false, this.fieldEmail));
			this.fieldPassword.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT, true, false, this.fieldPassword));
		}

		private function selectLinkText(id:int):void
		{
			var names:Array = link_names[Main.isRus ? 0 : 1];
			var text:String = "<body>";
			for (var i:int = 0; i < this.mailButtons.length; i++)
			{
				this.mailButtons[i].visible = id == i;
				this.mailCaptions[i].visible = id == i;
				text += id == i ? "<span class='select'>" : ("<a href='event:" + link_data[i] + "'>");
				text += names[i];
				text += id == i ? "</span>" : "</a>";
				text += i != (this.mailButtons.length - 1) ? "    " : "</body>";
			}
			this.fieldLink.htmlText = text;
		}

		private function onSocialLogin(e:MouseEvent):void
		{
			if (Main.socialType != "")
				return;
			var url:String = "";
			switch (e.currentTarget.name)
			{
				case "buttonVK":
					url = "https://oauth.vk.com/authorize?client_id=" + Config.VK_APP_ID;
					url += "&scope=" + Config.VK_SCOPE;
					url += "&redirect_uri=" + Config.REDIRECT_URL;
					url += "&display=" + Config.VK_DISPALY + "&response_type=code";
					break;
				case "buttonOK":
					url = "http://www.odnoklassniki.ru/oauth/authorize?client_id=" + Config.OK_APP_ID;
					url += "&scope=" + encodeURIComponent(Config.OK_SCOPE);
					url += "&redirect_uri=" + encodeURIComponent(Config.REDIRECT_URL);
					url += "&response_type=code";
					break;
				case "buttonFB":
					url = "https://www.facebook.com/dialog/oauth?client_id=" + (Main.isRus ? Config.FB_APP_ID_RU : Config.FB_APP_ID_EN);
					url += "&redirect_uri=" + Config.REDIRECT_URL;
					url += "&state=lkgadkgjhaklsdghasdflkjh&scope=" + Config.FB_SCOPE;
					url += "&display=" + Config.FB_DISPALY + "&response_type=token";
					break;
				case "buttonMM":
					url = "https://connect.mail.ru/oauth/authorize?client_id=" + Config.MM_APP_ID;
					url += "&scope=" + encodeURIComponent(Config.MM_SCOPE);
					url += "&redirect_uri=" + Config.REDIRECT_URL;
					url += "&display=" + Config.MM_DISPALY + "&response_type=code";
					break;
				default:
					return;
			}
			Main.initAuth();
			Main.socialType = e.currentTarget.name.replace("button", "");
			Main.socialUrl = url;
			Main.loadingSprite.visible = true;
			ExternalInterface.call("openWindow", Main.socialUrl, Config.REDIRECT_URL);
		}

		private function getField(text:String, x:int, y:int, width:int, height:int, format:TextFormat):TextField
		{
			var answer:TextField = new TextField();
			answer.x = x;
			answer.y = y;
			if (width != 0)
				answer.width = width;
			if (height != 0)
				answer.height = height;
			answer.defaultTextFormat = format;
			answer.embedFonts = false;
			answer.selectable = false;
			answer.text = text;

			return answer;
		}
	}
}