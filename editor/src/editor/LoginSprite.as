package editor
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	public class LoginSprite extends Sprite
	{
		static public var textConnect:TextField = new TextField();

		private var fieldPort:TextField = new TextField();
		private var fieldPassword:TextField = null;

		private var comboHost:ComboBox = new ComboBox();

		private var labelFieldPassword:EditorField = null;
		private var titlePort:EditorField = null;

		private var linkRealese:EditorField = null;

		public function LoginSprite()
		{
			this.labelFieldPassword = new EditorField("Пароль:", 20, 50, Formats.FORMAT_EDIT);
			addChild(this.labelFieldPassword);

			this.fieldPassword = new TextField();
			this.fieldPassword.type = TextFieldType.INPUT;
			this.fieldPassword.displayAsPassword = true;
			this.fieldPassword.border = true;
			this.fieldPassword.borderColor = 0xC0C0C0;
			this.fieldPassword.y = 50;
			this.fieldPassword.x = 70;
			this.fieldPassword.width = 200;
			this.fieldPassword.height = 20;
			this.fieldPassword.addEventListener(FocusEvent.FOCUS_IN, clearMessage);
			addChild(this.fieldPassword);

			this.linkRealese = new EditorField("<body><a href='event:#'>Подключиться</a></body>", 195, 75, Formats.style);
			this.linkRealese.addEventListener(MouseEvent.CLICK, connect);
			addChild(this.linkRealese);

			this.titlePort = new EditorField("Порт:", 94, 20, Formats.FORMAT_EDIT);
			addChild(this.titlePort);

			FormUtils.setTextField(this.fieldPort, this, 129, 20, 45, 18, 32, true);
			this.fieldPort.text = "11111";

			var portProvider:DataProvider = new DataProvider();
			portProvider.addItem({'label': "Релиз", 'value': "88.212.206.137", 'port': "11111", 'script_url': "http://88.212.207.58/squirrels/get_payments.php"});
			portProvider.addItem({'label': "Релиз(EN)", 'value': "209.126.119.142", 'port': "22122", 'script_url': ""});
			portProvider.addItem({'label': "Тест", 'value': "88.212.207.7", 'port': "22227", 'script_url': "http://88.212.207.7/squirrels/ru/get_payments.php"});

			FormUtils.setComboBox(this.comboHost, this, portProvider, 20, 20, 70);
			this.comboHost.addEventListener(Event.CHANGE, changeHost);

			FormUtils.setTextField(textConnect, this, 20, 100, 250, 18, 32, false);
		}

		public function get type():int
		{
			switch (this.comboHost.selectedItem['label'])
			{
				case "Тест":
				case "Релиз":
					return 0;
				case "Релиз(EN)":
					return 1;
			}
			return -1;
		}

		private function clearMessage(e:FocusEvent):void
		{
			textConnect.text = "";
		}

		private function connect(e:MouseEvent):void
		{
			MainForm.loader = new Loader(this.fieldPassword.text);
			MainForm.loader.connect(this.comboHost.selectedItem['value'], int(this.fieldPort.text));
			MainForm.loader.urlScript = this.comboHost.selectedItem['script_url'];
		}

		private function changeHost(event:Event):void
		{
			this.fieldPort.text = this.comboHost.selectedItem['port'];
		}
	}
}