package dialogs.clan
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	import buttons.ButtonBase;
	import clans.Clan;
	import clans.ClanManager;
	import dialogs.Dialog;
	import dialogs.DialogInfo;
	import events.ClanEvent;
	import views.ClanEmblemLoader;
	import views.ClanPhotoLoader;

	import by.blooddy.crypto.image.PNGEncoder;

	import com.inspirit.MultipartURLLoader;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketClanState;

	import utils.ImageUtil;
	import utils.LoaderUtil;
	import utils.StringUtil;
	import utils.TextFieldUtil;

	public class DialogClanEdit extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #573E11;
			}
			a {
				text-decoration: none;
				margin-right: 0px;
			}
			a:hover {
				text-decoration: underline;
				color: #0641EC;
			}
			.blue {
				font-size: 18px;
				color: #0641EC;
			}
		]]>).toString();

		static private const CLAN_CHANGE_NAME_COST:int = 5;

		static private const NAME_EDIT_DEFAULT:String = gls("Название");

		private var emblemLoader:ClanEmblemLoader = null;
		private var photoLoader:ClanPhotoLoader = null;

		private var clanId:int = 0;

		private var browse:Boolean = false;

		private var file:FileReference = new FileReference();

		private var newEmblemURL:String = "";
		private var newPhotoURL:String = "";

		private var emblemChanged:Boolean = false;
		private var photoChanged:Boolean = false;

		private var clan:Clan = null;

		private var dialogNotUniqueClan:DialogInfo = null;
		private var dialogChangeNameFailed:DialogInfo = null;
		private var dialogEmptyNameFailed:DialogInfo = null;

		private var fieldName:TextField = null;

		private var editOutFormat:TextFormat = null;
		private var editInFormat:TextFormat = null;

		private var previewIcon:ClanEmblemLoader = null;
		private var previewField:GameField = null;

		public function DialogClanEdit():void
		{
			super("", false, false);

			init();

			ClanManager.listen(onClanLoaded);
			Connection.listen(onPacket, PacketClanState.PACKET_ID);
		}

		override public function show():void
		{
			super.show();

			if (!(this.clan))
				return;

			this.fieldName.defaultTextFormat = this.editInFormat;
			this.fieldName.text = this.clan.name;

			FocusOut();
		}

		public function set id(value:int):void
		{
			this.clanId = value;

			if (ClanManager.getClan(this.clanId).isLoaded())
			{
				onClanLoaded(new ClanEvent(ClanManager.getClan(this.clanId), false));
				return;
			}

			ClanManager.request(this.clanId);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.dialogNotUniqueClan = new DialogInfo(gls("Смена имени"), gls("Клан с таким именем уже существует!\n "));
			this.dialogChangeNameFailed = new DialogInfo(gls("Смена имени"), gls("Не удалось сменить имя клана!"));
			this.dialogEmptyNameFailed = new DialogInfo(gls("Смена имени"), gls("Введите имя клана!"));

			var background:ClanEditBg = new ClanEditBg();
			background.cross.addEventListener(MouseEvent.CLICK, hide);
			background.loadIcon.addEventListener(MouseEvent.CLICK, onIconClick);
			background.loadPhoto.addEventListener(MouseEvent.CLICK, onPhotoClick);
			addChild(background);

			var field:GameField = new GameField(gls("Редактирование"), 0, 40, new TextFormat(GameField.PLAKAT_FONT, 18, 0x755728));
			field.x = int((background.width - field.textWidth) * 0.5);
			field.filters = [new BevelFilter(1.0, 45, 0x381700, 1.0, 0x996600, 0.0, 1, 1),
				new DropShadowFilter(2, 45, 0xFFFFFF, 1.0, 2, 2, 0.25)];
			background.addChild(field);

			field = new GameField(gls("Добавьте изображения:"), 0, 142, new TextFormat(null, 12, 0x573E11));
			field.x = int((background.width - field.textWidth) * 0.5);
			background.addChild(field);

			var fieldCost:GameField = new GameField(gls("<body>Изменение названия клана стоит <b>{0}</b></body>", CLAN_CHANGE_NAME_COST), 64, 82, style);
			addChild(fieldCost);

			var imageCoins:ImageIconCoins = new ImageIconCoins();
			imageCoins.scaleX = imageCoins.scaleY = 0.6;
			imageCoins.x = fieldCost.x + fieldCost.textWidth + 5;
			imageCoins.y = fieldCost.y;
			addChild(imageCoins);

			this.editInFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0x583E0A);
			this.editInFormat.leading = 2;

			this.editOutFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0xA6967D);
			this.editOutFormat.leading = 2;

			this.fieldName = new TextField();
			this.fieldName.x = 70;
			this.fieldName.y = 107;
			this.fieldName.width = 220;
			this.fieldName.height = 30;
			this.fieldName.type = TextFieldType.INPUT;
			this.fieldName.defaultTextFormat = this.editInFormat;
			this.fieldName.maxChars = Config.NAME_MAX_LENGTH;
			TextFieldUtil.embedFonts(this.fieldName);
			this.fieldName.addEventListener(FocusEvent.FOCUS_IN, FocusIn);
			this.fieldName.addEventListener(FocusEvent.FOCUS_OUT, FocusOut);
			this.fieldName.restrict = "a-zA-Z а-яёА-ЯЁ[0-9]\-";
			addChild(this.fieldName);

			this.emblemLoader = new ClanEmblemLoader("", 235, 200);
			addChild(this.emblemLoader);

			this.photoLoader = new ClanPhotoLoader("", 95, 180);
			addChild(this.photoLoader);

			this.previewIcon = new ClanEmblemLoader("", 75, 274);
			addChild(this.previewIcon);

			this.previewField = new GameField("", 90, 269, new TextFormat(null, 14, 0x573E11, true));
			addChild(this.previewField);

			var buttonSave:ButtonBase = new ButtonBase(gls("Сохранить"), 128);
			buttonSave.x = 62;
			buttonSave.y = 315;
			buttonSave.addEventListener(MouseEvent.CLICK, onSave);
			background.addChild(buttonSave);

			var buttonCancel:ButtonBase = new ButtonBase(gls("Отмена"), 101);
			buttonCancel.x = 195;
			buttonCancel.y = 315;
			buttonCancel.setRed();
			buttonCancel.addEventListener(MouseEvent.CLICK, onClose);
			background.addChild(buttonCancel);

			place();
		}

		private function FocusIn(e:FocusEvent):void
		{
			this.fieldName.defaultTextFormat = this.editInFormat;
			this.fieldName.text = (this.fieldName.text == NAME_EDIT_DEFAULT) ? "" : this.fieldName.text;
		}

		private function FocusOut(e:FocusEvent = null):void
		{
			if (this.fieldName.text != "" && this.fieldName.text != NAME_EDIT_DEFAULT)
				return;

			this.fieldName.defaultTextFormat = this.editOutFormat;
			this.fieldName.text = NAME_EDIT_DEFAULT;
		}

		private function onClanLoaded(e:ClanEvent):void
		{
			if (this.clanId != e.clan.id || e.fromCache)
				return;

			this.clan = e.clan;

			this.fieldName.text = e.clan.name;
			this.emblemLoader.load(e.clan.emblemLink);
			this.photoLoader.load(e.clan.photoLink);

			updatePreviewField();
			updatePreviewIcon();
		}

		private function onIconClick(e:Event):void
		{
			if (this.browse)
				return;

			this.browse = true;
			this.file.addEventListener(Event.SELECT, onIconSelected);
			this.file.addEventListener(Event.CANCEL, onSelectCancel);
			this.file.browse();
		}

		private function onPhotoClick(e:Event):void
		{
			if (this.browse)
				return;

			this.browse = true;
			this.file.addEventListener(Event.SELECT, onPhotoSelected);
			this.file.addEventListener(Event.CANCEL, onSelectCancel);
			this.file.browse();
		}

		private function onIconSelected(e:Event):void
		{
			this.browse = false;

			var onLoaded:Function = function (e:Event):void
			{
				file.removeEventListener(Event.COMPLETE, onLoaded);
				emblemLoader.loadBytes(file.data);
				emblemChanged = true;
				updatePreviewIcon(file.data);
			};

			this.file.addEventListener(Event.COMPLETE, onLoaded);
			this.file.removeEventListener(Event.SELECT, onIconSelected);
			this.file.removeEventListener(Event.CANCEL, onSelectCancel);
			this.file.load();
		}

		private function onPhotoSelected(e:Event):void
		{
			this.browse = false;

			var onLoaded:Function = function (e:Event):void
			{
				file.removeEventListener(Event.COMPLETE, onLoaded);
				photoLoader.loadBytes(file.data);
				photoChanged = true;
			};

			this.file.addEventListener(Event.COMPLETE, onLoaded);
			this.file.removeEventListener(Event.SELECT, onPhotoSelected);
			this.file.removeEventListener(Event.CANCEL, onSelectCancel);
			this.file.load();
		}

		private function onSelectCancel(e:Event):void
		{
			this.browse = false;

			this.file.removeEventListener(Event.SELECT, onPhotoSelected);
			this.file.removeEventListener(Event.SELECT, onIconSelected);
			this.file.removeEventListener(Event.CANCEL, onSelectCancel);
		}

		private function get nameChanged():Boolean
		{
			return this.fieldName.text != this.clan.name;
		}

		private function onClose(e:MouseEvent):void
		{
			this.close();
		}

		private function onSave(e:MouseEvent):void
		{
			if (this.nameChanged)
			{
				if (this.fieldName.text == "" || this.fieldName.text == DialogClanEdit.NAME_EDIT_DEFAULT)
				{
					this.dialogEmptyNameFailed.show();
					return;
				}

				if (this.clan.coins < CLAN_CHANGE_NAME_COST)
					new DialogClanDonate(gls("У твоего клана недостаточно денег для изменения имени.\nПополни бюджет клана.")).show();
				else
					Connection.sendData(PacketClient.CLAN_RENAME, this.fieldName.text);
			}

			if (this.emblemChanged)
			{
				if (this.emblemLoader.width == 10 || this.emblemLoader.height == 10)
				{
					if (this.emblemLoader.width > this.emblemLoader.height)
					{
						this.emblemLoader.scaleX = 1 + ((10 - this.emblemLoader.height)/ this.emblemLoader.height);
						this.emblemLoader.scaleY = 1 + ((10 - this.emblemLoader.height) / this.emblemLoader.height);
						this.emblemLoader.y = -(this.emblemLoader.width - this.emblemLoader.height) / 2;
						this.emblemLoader.x = -(this.emblemLoader.width / 2 - 5);
					}
					else
					{
						this.emblemLoader.scaleY = 1 + ((10 - this.emblemLoader.width) / this.emblemLoader.width);
						this.emblemLoader.scaleX = 1 + ((10 - this.emblemLoader.width) / this.emblemLoader.width);
						this.emblemLoader.x = -(this.emblemLoader.height - this.emblemLoader.width) / 2;
						this.emblemLoader.y = -(this.emblemLoader.height / 2 - 5);
					}
				}
				LoaderUtil.uploadFile(Config.EMBLEM_UPLOAD_URL, PNGEncoder.encode(ImageUtil.getBitmapData(this.emblemLoader, new Point(10, 10))), {'clanid': this.clanId, 'type': 0}, onUploadEmblemComplete, onUploadError);

				this.emblemLoader.x = 235;
				this.emblemLoader.y = 200;
				this.emblemLoader.scaleX = 1;
				this.emblemLoader.scaleY = 1;
				addChild(this.emblemLoader);
			}

			if (this.photoChanged)
			{
				this.photoLoader.x = 0;
				this.photoLoader.y = 0;

				if (this.photoLoader.width == 50 || this.photoLoader.height == 50)
				{
					if (this.photoLoader.width > this.photoLoader.height)
					{
						this.photoLoader.scaleX = 1 + ((50 - this.photoLoader.height)/ this.photoLoader.height);
						this.photoLoader.scaleY = 1 + ((50 - this.photoLoader.height) / this.photoLoader.height);
						this.photoLoader.y = -(this.photoLoader.width - this.photoLoader.height) / 2;
						this.photoLoader.x = -(this.photoLoader.width / 2 - 25);
					}
					else
					{
						this.photoLoader.scaleY = 1 + ((50 - this.photoLoader.width) / this.photoLoader.width);
						this.photoLoader.scaleX = 1 + ((50 - this.photoLoader.width) / this.photoLoader.width);
						this.photoLoader.x = -(this.photoLoader.height - this.photoLoader.width) / 2;
						this.photoLoader.y = -(this.photoLoader.height / 2 - 25);
					}
				}
				LoaderUtil.uploadFile(Config.EMBLEM_UPLOAD_URL, PNGEncoder.encode(ImageUtil.getBitmapData(this.photoLoader, new Point(50, 50))), {'clanid': this.clanId, 'type': 1}, onUploadPhotoComplete, onUploadError);

				this.photoLoader.x = 95;
				this.photoLoader.y = 180;
				this.photoLoader.scaleX = 1;
				this.photoLoader.scaleY = 1;
				addChild(this.photoLoader);
			}

			hide();
		}

		private function onUploadEmblemComplete(e:Event):void
		{
			this.newEmblemURL = (e.currentTarget as MultipartURLLoader).loader.data;
			trace("Emblem URL:", this.newEmblemURL);
			onUploadComplete();
		}

		private function onUploadPhotoComplete(e:Event):void
		{
			this.newPhotoURL = (e.currentTarget as MultipartURLLoader).loader.data;
			trace("Photo URL:", this.newPhotoURL);
			onUploadComplete();
		}

		private function onUploadComplete():void
		{
			if (this.newEmblemURL == "" && this.emblemChanged || this.newPhotoURL == "" && this.photoChanged)
				return;

			this.clan.emblemLink = this.emblemChanged ? this.newEmblemURL : this.clan.emblemLink;
			this.clan.photoLink = this.photoChanged ? this.newPhotoURL : this.clan.photoLink;
			this.clan.save();

			this.emblemChanged = false;
			this.photoChanged = false;

			ClanManager.request(this.clanId);
		}

		private function onUploadError(e:Event):void
		{
			trace(e);
		}

		private function updatePreviewField(e:Event = null):void
		{
			this.previewField.text = StringUtil.formatName(Game.self['name'], 150);
		}

		private function updatePreviewIcon(loadBytes:ByteArray = null):void
		{
			if (loadBytes)
				this.previewIcon.loadBytes(loadBytes);
			else
				this.previewIcon.load(this.clan.emblemLink);
		}

		private function onPacket(packet:PacketClanState):void
		{
			if (Game.self['clan_id'] == 0 || (Game.self['clan_duty'] != Clan.DUTY_LEADER))
				return;

			switch (packet.status)
			{
				case PacketServer.CLAN_STATE_SUCCESS:
					ClanManager.request(this.clanId, true);
					break;
				case PacketServer.CLAN_STATE_ERROR:
					this.dialogNotUniqueClan.show();
					break;
				case PacketServer.CLAN_STATE_NO_BALANCE:
					this.dialogChangeNameFailed.show();
					break;
			}
		}
	}
}