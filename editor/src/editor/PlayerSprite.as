package editor
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	import editor.forms.DataForm;

	public class PlayerSprite extends Sprite
	{
		private var image:Bitmap = null;

		private var fieldID:TextField = new TextField();
		private var fieldName:TextField = new TextField();
		private var fieldPlayerNID:TextField = new TextField();
		private var fieldPlayerUID:TextField = new TextField();

		private var labelEditorId:TextField = null;

		private var comboBoxType:ComboBox = new ComboBox();

		private var linkGetID:EditorField = null;

		private var spriteEdit:Sprite = new Sprite();

		public function PlayerSprite():void
		{
			this.graphics.lineStyle(2, 0x000000);

			this.graphics.moveTo(0, 33);
			this.graphics.lineTo(390, 33);

			this.graphics.moveTo(0, 175);
			this.graphics.lineTo(390, 175);

			this.graphics.moveTo(390, 0);
			this.graphics.lineTo(390, 175);

			this.labelEditorId = new EditorField("Введите ID", 0, 10, Formats.FORMAT_EDIT);
			addChild(this.labelEditorId);

			this.spriteEdit.addChild(new EditorField("Имя:", 0, 35, Formats.FORMAT_EDIT));
			this.spriteEdit.addChild(new EditorField("NID:", 150, 52, Formats.FORMAT_EDIT));
			this.spriteEdit.addChild(new EditorField("UID:", 0, 52, Formats.FORMAT_EDIT));

			FormUtils.setTextField(this.fieldID, this, 70, 10, 200, 18, 100, true);
			FormUtils.setTextField(this.fieldName, this.spriteEdit, 50, 35, 204, 18, 100, true);
			FormUtils.setTextField(this.fieldPlayerNID, this, 180, 52, 200);
			FormUtils.setTextField(this.fieldPlayerUID, this, 30, 52, 70);

			this.fieldID.addEventListener(KeyboardEvent.KEY_DOWN, inputKey);
			this.fieldName.addEventListener(KeyboardEvent.KEY_DOWN, inputKeyName);

			this.linkGetID = new EditorField("<body><a href='event:#'>Получить</a></body>", 330, 10, Formats.style);
			this.linkGetID.addEventListener(MouseEvent.CLICK, onRequest);
			addChild(linkGetID);

			this.spriteEdit.visible = false;
			addChild(this.spriteEdit);

			var linkSave:EditorField = new EditorField("<body><a href='event:#'>Сохранить изменения</a></body>", 120, 70, Formats.style);
			linkSave.addEventListener(MouseEvent.CLICK, onSave);
			this.spriteEdit.addChild(linkSave);

			var linkRemove:EditorField = new EditorField("<body><a href='event:#'>Убрать лишние поля</a></body>", 120, 90, Formats.style);
			linkRemove.addEventListener(MouseEvent.CLICK, onRemove);
			this.spriteEdit.addChild(linkRemove);

			var linkPhoto:EditorField = new EditorField("<body><a href='event:#'>Удалить фотографию</a></body>", 120, 120, Formats.style);
			linkPhoto.addEventListener(MouseEvent.CLICK, onPhoto);
			this.spriteEdit.addChild(linkPhoto);

			var linkClear:EditorField = new EditorField("<body><a href='event:#'>Сбросить</a></body>", 120, 135, Formats.style);
			linkClear.addEventListener(MouseEvent.CLICK, onClear);
			this.spriteEdit.addChild(linkClear);

			var linkPay:EditorField = new EditorField("<body><a href='event:#'>История платежей</a></body>", 120, 150, Formats.style);
			linkPay.addEventListener(MouseEvent.CLICK, onLoadPayHistory);
			this.spriteEdit.addChild(linkPay);
		}

		public function set type(value:int):void
		{
			var typeProvider:DataProvider = new DataProvider();
			switch (value)
			{
				case 0:
					typeProvider.addItem({'label': "VK", 'value': 0});
					typeProvider.addItem({'label': "MM", 'value': 1});
					typeProvider.addItem({'label': "OK", 'value': 4});
					typeProvider.addItem({'label': "FB", 'value': 5});
					typeProvider.addItem({'label': "FS", 'value': 30});
					typeProvider.addItem({'label': "NG", 'value': 31});
					typeProvider.addItem({'label': "SA", 'value': 32});
					typeProvider.addItem({'label': "UID", 'value': -1});
					break;
				case 1:
					typeProvider.addItem({'label': "FB", 'value': 5});
					typeProvider.addItem({'label': "UID", 'value': -1});
					break;
			}
			FormUtils.setComboBox(this.comboBoxType, this, typeProvider, 274, 10, 55);
		}

		public function update():void
		{
			if (this.image != null)
				removeChild(this.image);

			this.image = new Bitmap(MainForm.player.getImage(50, 50, 0, 0).bitmapData);
			this.image.x = 10;
			this.image.y = 70;

			if (this.image.width > this.image.height)
			{
				this.image.width = 100;
				this.image.scaleY = this.image.scaleX;
			}
			else
			{
				this.image.height = 100;
				this.image.scaleX = this.image.scaleY;
			}
			addChild(this.image);

			this.fieldName.text = MainForm.player.playerName;
			this.fieldPlayerNID.text = MainForm.player.nid;
			this.fieldPlayerUID.text = MainForm.player.uid.toString();

			this.spriteEdit.visible = true;
		}

		private function onRequest(e:Event = null):void
		{
			MainForm.loader.request(int(this.fieldID.text), this.comboBoxType.selectedItem['value']);
			this.fieldID.text = "";
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			onRequest();
		}

		private function onSave(e:MouseEvent = null):void
		{
			MainForm.save();
		}

		private function onRemove(e:MouseEvent = null):void
		{
			MainForm.remove();
		}

		private function onClear(e:MouseEvent = null):void
		{
			MainForm.loader.clear();
		}

		private function onLoadPayHistory(e:MouseEvent = null):void
		{
			MainForm.loader.requestPays(MainForm.player.uid, onComplete);
		}

		private function onComplete(e:Event):void
		{}

		private function onPhoto(e:Event):void
		{
			MainForm.player.photoURL = "";
			savePlayer();
		}

		private function inputKeyName(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;

			MainForm.player.playerName = this.fieldName.text;
			savePlayer();
		}

		private function savePlayer():void
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeUTF(MainForm.player.playerName);
			byteArray.writeByte(0);
			byteArray.writeUTF(MainForm.player.photoURL);
			byteArray.writeByte(0);
			MainForm.loader.save(DataForm.PROFILE, byteArray);
		}
	}
}