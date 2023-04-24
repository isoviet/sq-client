package editor
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import game.gameData.GameConfig;

	import editor.ClanSprite;
	import editor.forms.DataForm;

	import protocol.packages.server.PacketAdminInfo;
	import protocol.packages.server.PacketAdminInfoClan;
	import protocol.packages.server.PacketRequestPromo;

	public class MainForm extends Sprite
	{
		static private const MONTHS:Array = ["Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"];
		static private const PAY:Array = ["Нет", "СП", "ФС", "ВК", "Сундук"];

		static private var _instance:MainForm;

		static public var loader:Loader = null;
		static public var player:Player = null;

		private var fieldMessageBox:TextField = new TextField();
		private var linkMessage:EditorField = null;
		private var titleMessage:EditorField = null;

		private var loginSprite:LoginSprite = null;
		private var playerSprite:PlayerSprite = null;
		private var clanSprite:ClanSprite = null;
		private var promoEditor:PromoEditor = null;
		private var moderatorEditor:ModeratorEditor = null;

		private var userSprite:Sprite = null;
		private var messageSprite:Sprite = null;
		private var promoSprite:Sprite = null;
		private var moderatorSprite:Sprite = null;

		private var dataForms:Vector.<DataForm> = null;
		private var fieldList:Vector.<EditorField> = new <EditorField>[];

		public function MainForm():void
		{
			_instance = this;

			if (this.stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}

		static public function load(data:PacketAdminInfo):void
		{
			switch (data.field)
			{
				case DataForm.PROFILE:
					if (ClanSprite.requestInfo && (data.innerId == _instance.clanSprite.leaderUID))
					{
						_instance.clanSprite.setLeaderInfo(data.data);
						return;
					}

					if (!player)
						player = new Player();
					else if (player.uid != data.innerId && _instance.dataForms != null)
					{
						while (_instance.dataForms.length > 0)
							_instance.userSprite.removeChild(_instance.dataForms.shift());
						_instance.dataForms = null;
					}

					player.uid = data.innerId;
					player.nid = data.netId;
					player.setData(data.data, _instance.update);

					loader.requestField(DataForm.CLAN);
					break;
				case DataForm.CLAN:
					if (!player || player.uid != data.innerId)
						return;
					var clanId:int = data.data.readInt();
					_instance.clanSprite.id = clanId;
					break;
				default:
					if (!player || player.uid != data.innerId)
						return;
					if (!_instance.dataForms)
						_instance.dataForms = new <DataForm>[];
					for (var i:int = 0; i < _instance.dataForms.length; i++)
					{
						if (_instance.dataForms[i].isClan || _instance.dataForms[i].type != data.field)
							continue;
						_instance.dataForms[i].load(data.data);
						_instance.dataForms[i].changed = false;
						return;
					}

					var dataForm:DataForm = DataForm.getDataForm(data.field);
					dataForm.x = 425;
					if (_instance.dataForms.length != 0)
					{
						var lastForm:DataForm = _instance.dataForms[_instance.dataForms.length - 1];
						dataForm.y = lastForm.y + lastForm.height + 10;
					}
					else
						dataForm.y = 10;
					dataForm.load(data.data);
					_instance.userSprite.addChild(dataForm);

					_instance.dataForms.push(dataForm);
					break;
			}
		}

		static public function loadClan(data:PacketAdminInfoClan):void
		{
			if (_instance.clanSprite.id != data.clanId)
				return;
			switch (data.field)
			{
				case ClanSprite.INFO:
				case ClanSprite.LEADER:
					_instance.clanSprite.load(data.field, data.data);
					break;
				default:
					if (!_instance.dataForms)
						_instance.dataForms = new <DataForm>[];
					for (var i:int = 0; i < _instance.dataForms.length; i++)
					{
						if (!_instance.dataForms[i].isClan || _instance.dataForms[i].type != data.field)
							continue;
						_instance.dataForms[i].load(data.data);
						_instance.dataForms[i].changed = false;
						return;
					}

					var dataForm:DataForm = ClanSprite.getDataForm(data.field);
					dataForm.x = 425;
					if (_instance.dataForms.length != 0)
					{
						var lastForm:DataForm = _instance.dataForms[_instance.dataForms.length - 1];
						dataForm.y = lastForm.y + lastForm.height + 10;
					}
					else
						dataForm.y = 10;
					dataForm.load(data.data);
					_instance.userSprite.addChild(dataForm);

					_instance.dataForms.push(dataForm);
					break;
			}
		}

		static public function loadPromo(data:PacketRequestPromo):void
		{
			if (!_instance)
				return;
			_instance.promoEditor.load(data);
		}

		static public function remove():void
		{
			var array:Vector.<DataForm> = _instance.dataForms.concat();
			while (_instance.dataForms.length > 0)
				_instance.removeChild(_instance.dataForms.shift());
			var posY:int = 10;
			for (var i:int = 0; i < array.length; i++)
			{
				if (!array[i].changed)
					continue;
				array[i].y = posY;
				_instance.dataForms.push(array[i]);
				_instance.userSprite.addChild(array[i]);

				posY += array[i].height + 10;
			}
		}

		static public function save():void
		{
			if(!_instance || !_instance.dataForms)
				return;

			for (var i:int = 0; i < _instance.dataForms.length; i++)
			{
				if (_instance.dataForms[i].isClan)
					loader.saveClan(_instance.clanSprite.id, _instance.dataForms[i].type, _instance.dataForms[i].save());
				else
					loader.save(_instance.dataForms[i].type, _instance.dataForms[i].save());
			}
		}

		static public function onLogin():void
		{
			_instance.onLogin();
		}

		static public function set textID(value:Boolean):void
		{
			_instance.fieldMessageBox.selectable = value;
		}

		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			GameConfig.load();

			_instance.stage.scaleMode = 'noScale';
			_instance.stage.align = 'TOP';

			this.loginSprite = new LoginSprite();
			addChild(this.loginSprite);

			drawFrames();
		}

		private function Message(e:Event):void
		{
			if (this.fieldMessageBox.text != "")
				loader.message(this.fieldMessageBox.text);
			this.fieldMessageBox.text = "";
		}

		public function onLogin():void
		{
			this.loginSprite.visible = false;

			var link:EditorField = new EditorField("<body><a href='event:#'>Игрок</a></body>", 10, 0, Formats.style);
			link.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				userSprite.visible = true;
				messageSprite.visible = false;
				promoSprite.visible = false;
				moderatorSprite.visible = false;
			});
			addChild(link);

			link = new EditorField("<body><a href='event:#'>Сообщение</a></body>", 50, 0, Formats.style);
			link.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				userSprite.visible = false;
				messageSprite.visible = true;
				promoSprite.visible = false;
				moderatorSprite.visible = false;
			});
			addChild(link);

			link = new EditorField("<body><a href='event:#'>Промо</a></body>", 125, 0, Formats.style);
			link.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				userSprite.visible = false;
				messageSprite.visible = false;
				promoSprite.visible = true;
				moderatorSprite.visible = false;
			});
			addChild(link);

			link = new EditorField("<body><a href='event:#'>Модераторы</a></body>", 175, 0, Formats.style);
			link.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				userSprite.visible = false;
				messageSprite.visible = false;
				promoSprite.visible = false;
				moderatorSprite.visible = true;
			});
			addChild(link);

			this.graphics.moveTo(0, 20);
			this.graphics.lineTo(200, 20);

			initUserSprite();
			initMessageSprite();
			initPromoSprite();
			initModeratorSprite();
		}

		private function initModeratorSprite():void
		{
			this.moderatorSprite = new Sprite();
			this.moderatorSprite.y = 15;
			this.moderatorSprite.visible = false;
			addChild(this.moderatorSprite);

			this.moderatorEditor = new ModeratorEditor();
			this.moderatorEditor.x = 10;
			this.moderatorEditor.y = 10;
			this.moderatorSprite.addChild(this.moderatorEditor);
		}

		private function initPromoSprite():void
		{
			this.promoSprite = new Sprite();
			this.promoSprite.y = 15;
			this.promoSprite.visible = false;
			addChild(this.promoSprite);

			this.promoEditor = new PromoEditor();
			this.promoEditor.x = 10;
			this.promoEditor.y = 10;
			this.promoSprite.addChild(this.promoEditor);
		}

		private function initMessageSprite():void
		{
			this.messageSprite = new Sprite();
			this.messageSprite.y = 20;
			this.messageSprite.visible = false;
			addChild(this.messageSprite);

			FormUtils.setTextField(this.fieldMessageBox, this.messageSprite, 10, 20, 390, 50, 500, true);

			this.fieldMessageBox.wordWrap = true;
			this.fieldMessageBox.selectable = false;

			this.linkMessage = new EditorField("<body><a href='event:#'>Отправить сообщение</a></body>", 10, 70, Formats.style);
			this.linkMessage.addEventListener(MouseEvent.CLICK, Message);
			this.messageSprite.addChild(this.linkMessage);

			this.titleMessage = new EditorField("Сообщение:", 10, 0, Formats.FORMAT_EDIT);
			this.messageSprite.addChild(this.titleMessage);
		}

		private function initUserSprite():void
		{
			this.userSprite = new Sprite();
			this.userSprite.y = 15;
			addChild(this.userSprite);

			this.playerSprite = new PlayerSprite();
			this.playerSprite.x = 10;
			this.playerSprite.type = this.loginSprite.type;
			this.userSprite.addChild(this.playerSprite);

			this.userSprite.addChild(new EditorField("Список полей:", 10, 180, Formats.FORMAT_EDIT));

			for (var i:int = 0; i < DataForm.NAMES.length; i++)
			{
				if (i == DataForm.PROFILE || i == DataForm.CLAN)
					continue;
				var requestField:EditorField = new EditorField("<body><a href='event:#'>" + DataForm.NAMES[i] + "</a></body>", 20 + int(this.fieldList.length / 10) * 120, 195 + 15 * (this.fieldList.length % 10), Formats.style);
				requestField.addEventListener(MouseEvent.CLICK, onRequestField);
				requestField.name = i.toString();
				requestField.visible = false;
				this.userSprite.addChild(requestField);

				this.fieldList.push(requestField);
			}

			this.clanSprite = new ClanSprite();
			this.clanSprite.x = 10;
			this.clanSprite.y = 370;
			this.userSprite.addChild(this.clanSprite);
		}

		private function update():void
		{
			this.playerSprite.update();

			for (var i:int = 0; i < this.fieldList.length; i++)
				this.fieldList[i].visible = true;
		}

		private function onRequestField(e:MouseEvent = null):void
		{
			loader.requestField(int(e.currentTarget.name));
		}

		private function drawFrames():void
		{
			this.graphics.lineStyle(3, 0x999999);
			this.graphics.drawRoundRect(0, 0, 900, 660, 20);
		}
	}
}