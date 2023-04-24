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

	import editor.forms.DataForm;
	import editor.forms.DataFormClanBalance;
	import editor.forms.DataFormClanBan;
	import editor.forms.DataFormClanNews;
	import editor.forms.DataFormClanPlace;
	import editor.forms.DataFormClanSize;

	public class ClanSprite extends Sprite
	{
		static public const INFO:int = 0;
		static public const NEWS:int = 1;
		static public const LEADER:int = 2;
		static public const SIZE:int = 3;
		static public const STATE:int = 4;
		static public const RANK:int = 5;
		static public const RANK_RANGE:int = 6;
		static public const PLACES:int = 7;
		static public const BAN:int = 8;
		static public const TOTEMS:int = 9;
		static public const TOTEMS_RANGS:int = 10;
		static public const TOTEMS_BONUSES:int = 11;
		static public const STATISTICS:int = 12;
		static public const BLACKLIST:int = 13;
		static public const LEVEL_LIMITER:int = 14;
		static public const ADMIN_BALANCE:int = 15;

		static public var CLASSES:Array = null;

		static public const NAMES:Array = ["Инфо", "Новости", "Лидер", "Размер", "Статус", "Ранг",
			"Изменение ранга", "Места", "Бан", "Тотемы", "Ранги тотемов", "Бонусы тотемов", "Статистика",
			"Чёрный лист", "Уровень входа", "Баланс"];

		static public var requestInfo:Boolean = false;

		public var clan:Clan = null;
		public var leaderUID:int = 0;
		protected var _id:int = 0;

		protected var fieldID:TextField = new TextField();
		protected var fieldName:TextField = new TextField();

		protected var fieldLeaderUID:TextField = new TextField();
		protected var fieldLeaderName:TextField = new TextField();

		protected var emblem:Bitmap = null;
		protected var image:Bitmap = null;

		protected var spriteFields:Sprite = null;
		protected var fieldList:Vector.<EditorField> = new <EditorField>[];

		static public function getDataForm(type:int):DataForm
		{
			if (!CLASSES)
				CLASSES = [null, DataFormClanNews, null, DataFormClanSize, "Статус", "Ранг",
					"Изменение ранга", DataFormClanPlace, DataFormClanBan, "Тотемы", "Ранги тотемов",
					"Бонусы тотемов", "Статистика", "Чёрный лист", "Уровень входа", DataFormClanBalance];
			var formClass:Class = CLASSES[type];
			return new formClass() as DataForm;
		}

		public function ClanSprite()
		{
			this.visible = false;

			addChild(new EditorField("Клан ID:", 0, 0, Formats.FORMAT_EDIT));
			FormUtils.setTextField(this.fieldID, this, 50, 0, 150, 18, 100);

			addChild(new EditorField("Имя:", 0, 20, Formats.FORMAT_EDIT));
			this.fieldName.addEventListener(KeyboardEvent.KEY_DOWN, inputKeyName);
			FormUtils.setTextField(this.fieldName, this, 30, 20, 150, 18, 100, true);

			addChild(new EditorField("Вождь Клана:", 0, 40, Formats.FORMAT_EDIT));
			FormUtils.setTextField(this.fieldLeaderName, this, 80, 40, 120, 18, 100);

			addChild(new EditorField("Вождь ID:", 0, 60, Formats.FORMAT_EDIT));
			FormUtils.setTextField(this.fieldLeaderUID, this, 60, 60, 130, 18, 100, true);

			var fieldLink:EditorField = new EditorField("<body><a href='event:#'>Удалить эмблему</a></body>", 250, 80, Formats.style);
			fieldLink.addEventListener(MouseEvent.CLICK, onPhotoDeleted);
			addChild(fieldLink);

			fieldLink = new EditorField("<body><a href='event:#'>Сменить вождя</a></body>", 0, 80, Formats.style);
			fieldLink.addEventListener(MouseEvent.CLICK, onLeaderChange);
			addChild(fieldLink);

			this.spriteFields = new Sprite();
			this.spriteFields.y = 100;
			addChild(this.spriteFields);

			this.spriteFields.addChild(new EditorField("Список полей:", 10, 0, Formats.FORMAT_EDIT));
			for (var i:int = 0; i < NAMES.length; i++)
			{
				if (i == INFO || i == LEADER)
					continue;
				var requestField:EditorField = new EditorField("<body><a href='event:#'>" + NAMES[i] + "</a></body>", 20 + int(this.fieldList.length / 5) * 120, 15 + 15 * (this.fieldList.length % 5), Formats.style);
				requestField.addEventListener(MouseEvent.CLICK, onRequestField);
				requestField.name = i.toString();
				this.spriteFields.addChild(requestField);

				this.fieldList.push(requestField);
			}

			this.graphics.clear();
			this.graphics.lineStyle(2, 0);
			this.graphics.drawRoundRect(0, -5, 390, 200, 5);

			this.graphics.lineStyle(0.5, 0x777777);
			this.graphics.moveTo(0, 102);
			this.graphics.lineTo(390, 102);
		}

		public function set id(value:int):void
		{
			if (this._id == value)
				return;
			this._id = value;

			this.visible = this._id != 0;
			this.clan = null;

			if (this._id != 0)
			{
				this.clan = new Clan();
				this.clan.id = this.id;

				this.fieldID.text = this.id.toString();

				MainForm.loader.requestFieldClan(INFO, this.id);
				MainForm.loader.requestFieldClan(LEADER, this.id);
			}
		}

		public function get id():int
		{
			return this._id;
		}

		public function setLeaderInfo(data:ByteArray):void
		{
			requestInfo = false;

			this.fieldLeaderName.text = data.readUTF();
		}

		public function load(type:int, data:ByteArray):void
		{
			switch (type)
			{
				case INFO:
					this.clan.setData(data, onPhoto, onEmblem);
					this.fieldName.text = this.clan.name;
					break;
				case LEADER:
					this.leaderUID = data.readInt();
					this.fieldLeaderUID.text = this.leaderUID.toString();

					if (this.leaderUID == MainForm.player.uid)
						this.fieldLeaderName.text = MainForm.player.playerName;
					else
					{
						requestInfo = true;
						MainForm.loader.request(this.leaderUID, -1);
					}
					break;
			}
		}

		private function onPhoto():void
		{
			if (this.image != null)
				removeChild(this.image);

			this.image = new Bitmap(this.clan.getImage(50, 50, 0, 0).bitmapData);
			this.image.x = 250;
			this.image.y = 10;

			if (this.image.width > this.image.height)
			{
				this.image.width = 50;
				this.image.scaleY = this.image.scaleX;
			}
			else
			{
				this.image.height = 50;
				this.image.scaleX = this.image.scaleY;
			}
			addChild(this.image);
		}

		private function onEmblem():void
		{
			if (this.emblem != null)
				removeChild(this.emblem);

			this.emblem = new Bitmap(this.clan.getEmblem(10, 10, 0, 0).bitmapData);
			this.emblem.x = 250;
			this.emblem.y = 65;

			if (this.emblem.width > this.emblem.height)
			{
				this.emblem.width = 10;
				this.emblem.scaleY = this.emblem.scaleX;
			}
			else
			{
				this.emblem.height = 10;
				this.emblem.scaleX = this.emblem.scaleY;
			}
			addChild(this.emblem);
		}

		private function onRequestField(e:MouseEvent = null):void
		{
			MainForm.loader.requestFieldClan(int(e.currentTarget.name), this.id);
		}

		private function inputKeyName(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;

			this.clan.name = this.fieldName.text;

			saveClan();
		}

		private function onPhotoDeleted(e:Event):void
		{
			this.clan.photoURL = "";
			this.clan.emblemURL = "";

			saveClan();
		}

		private function saveClan():void
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeUTF(this.clan.name);
			byteArray.writeByte(0);
			byteArray.writeUTF(this.clan.photoURL);
			byteArray.writeByte(0);
			byteArray.writeUTF(this.clan.emblemURL);
			byteArray.writeByte(0);
			MainForm.loader.saveClan(this.id, INFO, byteArray);
		}

		private function onLeaderChange(e:Event):void
		{
			var leaderId:int = int(this.fieldLeaderUID.text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(leaderId);
			MainForm.loader.saveClan(this.id, LEADER, byteArray);
		}
	}
}