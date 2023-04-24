package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import fl.controls.CheckBox;
	import fl.controls.ComboBox;

	import buttons.ButtonBase;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.BanUtil;
	import utils.TextFieldUtil;

	public class DialogBlock extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #262626;
			}
			a {
				text-decoration: underline;
				margin-right: 0px;
			}
			a:hover {
				text-decoration: none;
			}
		]]>).toString();

		static private const OFFSET_X:int = 5;

		private var comboboxReason:ComboBox = new ComboBox();
		private var checkbox:CheckBox = new CheckBox();

		public var playerId:int = 0;

		public function DialogBlock():void
		{
			super(gls("Заблокировать"));
			init();
		}

		override public function show():void
		{
			super.show();

			Game.stage.focus = this.comboboxReason;
			this.comboboxReason.selectedIndex = 1;
			this.checkbox.selected = false;
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide(e);

			Game.stage.focus = Game.stage;
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			addChild(new GameField(gls("Укажите нарушение:"), OFFSET_X, 5, new TextFormat(null, 12, 0x262626)));

			var comboboxFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 11, 0x313436);
			comboboxFormat.align = TextFormatAlign.LEFT;

			this.comboboxReason.x = OFFSET_X;
			this.comboboxReason.y = 23;
			fill(this.comboboxReason);
			this.comboboxReason.width = 240;
			this.comboboxReason.height = 20;
			this.comboboxReason.rowCount = 16;
			this.comboboxReason.setStyle("textPadding", 2);
			this.comboboxReason.textField.setStyle("textFormat", comboboxFormat);
			this.comboboxReason.dropdown.setRendererStyle("textFormat", comboboxFormat);
			addChild(this.comboboxReason);

			TextFieldUtil.setStyleCheckBox(this.checkbox);
			this.checkbox.x = OFFSET_X;
			this.checkbox.y = 50;
			this.checkbox.width = 370;
			this.checkbox.label = gls("Такое нарушение уже было     ");
			addChild(this.checkbox);

			var buttonOk:ButtonBase = new ButtonBase(gls("Ок"));
			buttonOk.addEventListener(MouseEvent.CLICK, ban);

			var buttonCancel:ButtonBase = new ButtonBase(gls("Отмена"));
			buttonCancel.addEventListener(MouseEvent.CLICK, hide);

			place(buttonOk, buttonCancel);

			this.height = 180;
			this.width = 310;
		}

		private function fill(comboBox:ComboBox):void
		{
			comboBox.removeAll();

			for (var i:int = 0; i < BanUtil.reasons.length; i++)
			{
				var item:Object = BanUtil.reasons[i];
				if ('hide' in item && item['hide'])
					continue;
				comboBox.addItem({'label': item['title'], 'value': i});
			}
		}

		private function ban(e:MouseEvent):void
		{
			var reason:int = int(this.comboboxReason.selectedItem['value']);

			Connection.sendData(PacketClient.BAN, this.playerId, reason, (this.checkbox.selected ? 1 : 0));

			hide();
		}
	}
}