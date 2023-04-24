package editor
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRequestPromo;

	public class PromoEditor extends Sprite
	{
		static private var provider:DataProvider = new DataProvider();

		private var fieldName:TextField = null;
		private var boxType:ComboBox = null;
		private var fieldCount:TextField = null;

		private var fieldsName:Vector.<TextField> = new <TextField>[];
		private var fieldsType:Vector.<TextField> = new <TextField>[];
		private var fieldsCount:Vector.<TextField> = new <TextField>[];
		private var fieldsUsed:Vector.<TextField> = new <TextField>[];

		public function PromoEditor()
		{
			var bonusType:Array = ["VIP", "Костюм"];
			for (var i:int = 0; i < bonusType.length; i++)
				provider.addItem({'label': bonusType[i], 'value': i});

			addChild(new EditorField("Промо-текст", 0, 0, Formats.FORMAT_EDIT));
			this.fieldName = new TextField();
			FormUtils.setTextField(this.fieldName, this, 0, 20, 200, 18, 100, true);

			addChild(new EditorField("Тип", 210, 0, Formats.FORMAT_EDIT));
			this.boxType = new ComboBox();
			FormUtils.setComboBox(this.boxType, this, provider, 210, 20, 80);

			addChild(new EditorField("Кол-во", 300, 0, Formats.FORMAT_EDIT));
			this.fieldCount = new TextField();
			FormUtils.setTextField(this.fieldCount, this, 300, 20, 40, 18, 100, true);

			var link:EditorField = new EditorField("<body><a href='event:#'>Добавить</a></body>", 350, 20, Formats.style);
			link.addEventListener(MouseEvent.CLICK, addPromo);
			addChild(link);

			Connection.sendData(PacketClient.ADMIN_REQUEST_PROMO);
		}

		public function load(data:PacketRequestPromo):void
		{
			while (this.fieldsName.length > data.items.length)
			{
				removeChild(this.fieldsName.pop());
				removeChild(this.fieldsType.pop());
				removeChild(this.fieldsCount.pop());
				removeChild(this.fieldsUsed.pop());
			}

			for (var i:int = 0; i < data.items.length; i++)
			{
				if (i >= this.fieldsName.length)
				{
					var field:TextField = new TextField();
					FormUtils.setTextField(field, this, 0, 60 + i * 20, 200, 18, 100, false);
					this.fieldsName.push(field);

					field = new TextField();
					FormUtils.setTextField(field, this, 210, 60 + i * 20, 80, 18, 100, false);
					this.fieldsType.push(field);

					field = new TextField();
					FormUtils.setTextField(field, this, 300, 60 + i * 20, 40, 18, 100, true);
					field.addEventListener(KeyboardEvent.KEY_DOWN, inputKey, false, 0, true);
					field.addEventListener(Event.CHANGE, onChange, false, 0, true);
					this.fieldsCount.push(field);

					field = new TextField();
					FormUtils.setTextField(field, this, 350, 60 + i * 20, 40, 18, 100, false);
					this.fieldsUsed.push(field);
				}

				this.fieldsName[i].text = data.items[i].code;
				this.fieldsType[i].text = provider.getItemAt(data.items[i].bonus)['label'];
				this.fieldsCount[i].text = data.items[i].maxCount.toString();
				this.fieldsUsed[i].text = data.items[i].usedCount.toString();

				this.fieldsCount[i].borderColor = 0x000000;
			}
		}

		private function addPromo(e:MouseEvent):void
		{
			Connection.sendData(PacketClient.ADMIN_ADD_PROMO, this.fieldName.text, int(this.boxType.selectedItem['value']), int(this.fieldCount.text));

			this.fieldName.text = "";
			this.boxType.selectedIndex = 0;
			this.fieldCount.text = "";
		}

		private function onChange(e:Event):void
		{
			(e.currentTarget as TextField).borderColor = 0xFF0000;
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			for (var i:int = 0; i < this.fieldsCount.length; i++)
			{
				if (e.currentTarget != this.fieldsCount[i])
					continue;
				break;
			}
			Connection.sendData(PacketClient.ADMIN_EDIT_PROMO, this.fieldsName[i].text, int(this.fieldsCount[i].text));
		}
	}
}