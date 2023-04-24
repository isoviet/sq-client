package dialogs.clan
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import loaders.RuntimeLoader;

	import com.api.Services;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DialogClanDonate extends Dialog
	{
		static private var _instance:DialogClanDonate = null;

		private var fieldCoins:TextField = new TextField();
		private var fieldNuts:TextField = new TextField();

		public function DialogClanDonate(caption:String = null, messageText:String = null):void
		{
			if (_instance != null)
				_instance.close();

			_instance = this;

			if (messageText == null)
				messageText = gls("Каждая белка, состоящая в клане, должна\nвносить орешки или монетки.");

			super(caption == null ? gls("Внеси свой взнос") : caption);
			init(messageText);
		}

		private function init(messageText:String):void
		{
			var textField:GameField = new GameField(messageText, 5, 0, new TextFormat(null, 14, 0x000000));
			textField.width = 296;
			addChild(textField);

			var inputFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0xD70000, true);

			var inputBG1:DisplayObject = addChild(new ImageFieldInputText());
			inputBG1.x = textField.x;
			inputBG1.y = textField.y + textField.textHeight + 20;

			this.fieldNuts.x = inputBG1.x + 8;
			this.fieldNuts.y = inputBG1.y + 4;
			this.fieldNuts.type = TextFieldType.INPUT;
			this.fieldNuts.defaultTextFormat = inputFormat;
			this.fieldNuts.width = 35;
			this.fieldNuts.restrict = "[0-9]";
			this.fieldNuts.maxChars = 3;
			this.fieldNuts.embedFonts = true;
			this.fieldNuts.text = "0";
			this.fieldNuts.height = this.fieldNuts.textHeight + 5;
			addChild(this.fieldNuts);

			var imageNut:ImageIconNut = new ImageIconNut();
			imageNut.x = this.fieldNuts.x + 42;
			imageNut.y = this.fieldNuts.y;
			imageNut.scaleX = imageNut.scaleY = 0.8;
			addChild(imageNut);

			var inputBG2:DisplayObject = addChild(new ImageFieldInputText());
			inputBG2.x = inputBG1.x + inputBG1.width + 13;
			inputBG2.y = inputBG1.y;

			this.fieldCoins.x = inputBG2.x + 8;
			this.fieldCoins.y = inputBG2.y + 4;
			this.fieldCoins.type = TextFieldType.INPUT;
			this.fieldCoins.defaultTextFormat = inputFormat;
			this.fieldCoins.width = 35;
			this.fieldCoins.restrict = "[0-9]";
			this.fieldCoins.maxChars = 3;
			this.fieldCoins.embedFonts = true;
			this.fieldCoins.text = "0";
			this.fieldCoins.height = this.fieldCoins.textHeight + 5;
			addChild(this.fieldCoins);

			var imageCoins:ImageIconCoins = new ImageIconCoins();
			imageCoins.x = fieldCoins.x + 42;
			imageCoins.y = fieldCoins.y;
			imageCoins.scaleX = imageCoins.scaleY = 0.8;
			addChild(imageCoins);

			var button:ButtonBase = new ButtonBase(gls("Внести"));
			button.x = textField.x + textField.width - button.width;
			button.y = inputBG1.y;
			button.addEventListener(MouseEvent.CLICK, onDonate);
			addChild(button);

			place();

			this.width += 10;
			this.height = this.topOffset + button.y + button.height + this.bottomOffset + 20;
		}

		private function onDonate(e:MouseEvent):void
		{
			if (int(this.fieldCoins.text) == 0 && int(this.fieldNuts.text) == 0)
				return;

			if (Game.balanceCoins < int(this.fieldCoins.text) || Game.balanceNuts < int(this.fieldNuts.text))
			{
				RuntimeLoader.load(function():void
				{
					Services.bank.open();
				});
				return;
			}

			Connection.sendData(PacketClient.CLAN_DONATION, int(this.fieldCoins.text), int(this.fieldNuts.text));
			this.close();
		}
	}
}