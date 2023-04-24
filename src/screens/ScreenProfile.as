package screens
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import buttons.ButtonScreenshot;
	import buttons.ButtonToggle;
	import dialogs.Dialog;
	import dialogs.DialogBuyNickname;
	import dialogs.DialogPalette;
	import dialogs.clan.DialogClanCreate;
	import events.GameEvent;
	import footers.FooterTop;
	import game.gameData.ClothesManager;
	import game.gameData.EducationQuestManager;
	import game.gameData.FlagsManager;
	import game.gameData.OutfitData;
	import game.gameData.VIPManager;
	import headers.HeaderExtended;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import views.BirthdayPieView;
	import views.ClanBoard;
	import views.GoldenCupProfileView;
	import views.InteriorView;
	import views.ProfileHero;
	import views.SexView;

	import com.api.Player;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;

	import utils.EditField;
	import utils.GuardUtil;
	import utils.StringUtil;
	import utils.TextFieldUtil;

	public class ScreenProfile extends Screen
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #363636;
			}
			a {
				text-decoration: underline;
				margin-right: 0px;
			}
			a:hover {
				text-decoration: underline;
				color: #FF1B00;
			}
			.small {
				color: #0C0801;
				font-size: 10px;
			}
		]]>).toString();

		static private const LOAD_MASK:uint = PlayerInfoParser.NAME | PlayerInfoParser.SEX | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.WEARED;
		static private const FORMAT_NAME:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0xDB4F1A, true, null, null, null, null, "center");
		static private const FORMAT_RANK:TextFormat = new TextFormat(null, 14, 0xFFFFFF, true, null, null, null, null, "center");
		static private const FORMAT_CLAN:TextFormat = new TextFormat(null, 11, 0xFFFFFF, true);

		static private var _instance:ScreenProfile;

		private var player:Player = null;
		private var playerId:int = 0;
		private var beginId:int = 0;

		private var inited:Boolean = false;

		private var nameField:GameField = null;
		private var nameEditField:EditField;
		private var rankField:GameField;

		private var nameEditButton:ButtonToggle = null;

		private var buttonPalette:SimpleButton = null;

		private var saveWorld:MovieClip = null;
		private var shamanCertificatePlace:SimpleButton = null;
		private var shamanCertificate:MovieClip = null;
		private var sexButton:Sprite = null;
		private var clanBoardCreate:Sprite;
		private var clanBoard:ClanBoard = null;
		private var goldenCup:GoldenCupProfileView = null;
		private var birthdayView:Sprite = null;

		private var hero:ProfileHero = null;

		private var dialogBuyNickname:Dialog = null;

		private var interiorView:InteriorView = null;

		private var boards:Object = {};

		public function ScreenProfile():void
		{
			_instance = this;

			super();
		}

		static public function get instance():ScreenProfile
		{
			return _instance;
		}

		static public function onClanCreate():void
		{
			if (!_instance.inited)
				return;
			if (Game.self && Game.self['clan_id'])
				instance.clanBoard.clanId = Game.self['clan_id'];

			toggleCreateClanButton(false);
			DialogClanCreate.hide();
		}

		static public function onClanDispose():void
		{
			if (!_instance.inited)
				return;

			_instance.clanBoard.clanId = 0;
			_instance.clanBoard.visible = false;
			toggleCreateClanButton(true);
		}

		static public function updateHero():void
		{
			if (!_instance.inited)
				return;

			if ((ScreenProfile.playerId != Game.selfId))
				return;

			_instance.updateHero();
		}

		static public function addListener(type:String, listener:Function):void
		{
			if (!_instance)
				return;

			switch (type)
			{
				case GameEvent.PROFILE_PLAYER_CHANGED:
					_instance.addEventListener(GameEvent.PROFILE_PLAYER_CHANGED, listener);
					break;
				case GameEvent.SHOWED:
					_instance.addEventListener(GameEvent.SHOWED, listener);
					break;
			}
		}

		static public function removeListener(type:String, listener:Function):void
		{
			if (!_instance)
				return;

			switch (type)
			{
				case GameEvent.PROFILE_PLAYER_CHANGED:
					_instance.removeEventListener(GameEvent.PROFILE_PLAYER_CHANGED, listener);
					break;
				case GameEvent.SHOWED:
					_instance.removeEventListener(GameEvent.SHOWED, listener);
					break;
			}
		}

		static public function setPlayerId(id:int):void
		{
			_instance.setPlayerId(id);
		}

		static public function get playerId():int
		{
			return (_instance.playerId != 0 ? _instance.playerId : _instance.beginId);
		}

		static public function toggleCreateClanButton(value:Boolean):void
		{
			_instance.clanBoardCreate.visible = value;
		}

		override public function firstShow():void
		{
			show();

			FooterTop.addListenerToChange();
		}

		override public function show():void
		{
			super.show();

			if (!ScreensLoader.loaded)
				return;

			if (!this.inited)
			{
				init();
				this.inited = true;

				setPlayerId(this.beginId);
				FooterTop.showDecorations();
			}
			EducationQuestManager.done(EducationQuestManager.HOME);
			GuardUtil.checkId();

			dispatchEvent(new GameEvent(GameEvent.SHOWED));
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.interiorView = new InteriorView(Game.self['interior']);
			addChild(this.interiorView);
			InteriorManager.addEventListener(GameEvent.INTERIOR_CHANGE, changeInterior);

			var spriteProfile:Sprite = new Sprite();
			spriteProfile.x = 10;
			spriteProfile.y = 105;
			addChild(spriteProfile);

			var imageBoard:* = new ProfileHeroBoard();
			spriteProfile.addChild(imageBoard);
			this.boards['common'] = imageBoard;

			imageBoard = new ProfileHeroBoardVIP();
			spriteProfile.addChild(imageBoard);
			this.boards['VIP'] = imageBoard;

			this.clanBoardCreate = new Sprite();
			this.clanBoardCreate.x = 107;
			this.clanBoardCreate.y = 95;
			spriteProfile.addChild(this.clanBoardCreate);

			var button:ButtonClan = new ButtonClan();
			button.addEventListener(MouseEvent.CLICK, DialogClanCreate.show);
			this.clanBoardCreate.addChild(button);
			new Status(button, gls("Создать клан"));

			var field:GameField = this.clanBoardCreate.addChild(new GameField(gls("Создать"), 0, -10, FORMAT_CLAN)) as GameField;
			field.x -= field.textWidth + 30;
			this.clanBoardCreate.addChild(new GameField(gls("свой клан"), 20, -10, FORMAT_CLAN));

			this.clanBoard = new ClanBoard();
			this.clanBoard.y = 85;
			spriteProfile.addChild(this.clanBoard);

			this.nameEditField = new EditField("", 12, 45, 190, 28, FORMAT_NAME, FORMAT_NAME, Config.NAME_MAX_LENGTH);
			this.nameEditField.border = false;
			this.nameEditField.background = false;
			this.nameEditField.restrict = "a-zA-Z а-яёА-ЯЁ[0-9]\-";
			this.nameEditField.visible = false;
			spriteProfile.addChild(this.nameEditField);

			this.nameEditButton = new ButtonToggle(new ButtonChangeNick, new ButtonSaveNick, false);
			this.nameEditButton.x = 183;
			this.nameEditButton.y = 50;
			spriteProfile.addChild(this.nameEditButton);

			new Status(this.nameEditButton.buttonOn, gls("Сохранить имя"));
			new Status(this.nameEditButton.buttonOff, gls("Изменить имя"));

			this.nameEditButton.buttonOn.addEventListener(MouseEvent.CLICK, onSave);
			this.nameEditButton.buttonOn.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			this.nameEditButton.buttonOn.addEventListener(MouseEvent.ROLL_OVER, soundOver);

			this.nameEditButton.buttonOff.addEventListener(MouseEvent.CLICK, onEdit);
			this.nameEditButton.buttonOff.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			this.nameEditButton.buttonOff.addEventListener(MouseEvent.ROLL_OVER, soundOver);

			this.nameField = new GameField("", 12, 45, FORMAT_NAME);
			this.nameField.width = 190;
			this.nameField.autoSize = TextFieldAutoSize.CENTER;
			spriteProfile.addChild(this.nameField);

			this.rankField = new GameField("", 12, 10, FORMAT_RANK);
			this.rankField.width = 190;
			this.rankField.autoSize = TextFieldAutoSize.CENTER;
			spriteProfile.addChild(this.rankField);

			this.sexButton = new SexView();
			this.sexButton.x = 7;
			this.sexButton.y = 7;
			spriteProfile.addChild(this.sexButton);

			this.buttonPalette = new ButtonShowPalette();
			this.buttonPalette.x = 230 - this.buttonPalette.width;
			this.buttonPalette.y = 125 - this.buttonPalette.height;
			this.buttonPalette.addEventListener(MouseEvent.CLICK, DialogPalette.show);
			spriteProfile.addChild(buttonPalette);
			new Status(this.buttonPalette, gls("Сменить цвет имени"));

			this.shamanCertificate = new ShamanCertificateReceived();
			this.shamanCertificate.x = 434;
			this.shamanCertificate.y = 96;
			this.shamanCertificate.addEventListener(MouseEvent.CLICK, showSchool);
			addChild(this.shamanCertificate);
			new Status(this.shamanCertificate, gls("Аттестат школы шаманов"));

			this.shamanCertificatePlace = new ShamanCertificatePlace();
			this.shamanCertificatePlace.x = this.shamanCertificate.x;
			this.shamanCertificatePlace.y = this.shamanCertificate.y;
			addChild(this.shamanCertificatePlace);
			new Status(this.shamanCertificatePlace, gls("Место для Аттестата Шамана"));

			this.saveWorld = new ImageLeftSaveWorld();
			this.saveWorld.x = 427;
			this.saveWorld.y = 362;
			addChild(this.saveWorld);

			this.hero = new ProfileHero();
			this.hero.x = 486;
			this.hero.y = 470;
			addChild(this.hero);

			this.goldenCup = new GoldenCupProfileView();
			this.goldenCup.x = 600;
			this.goldenCup.y = 430;
			addChild(this.goldenCup);

			/*this.birthdayView = new BirthdayPieView();
			this.birthdayView.x = 720;
			this.birthdayView.y = 310;
			addChild(this.birthdayView);*/

			var screenshotButton:ButtonScreenshot = new ButtonScreenshot();
			screenshotButton.x = 600;
			screenshotButton.y = 135;
			addChild(screenshotButton);

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputKey);
			VIPManager.addEventListener(GameEvent.VIP_END, onVIPEnd);
			VIPManager.addEventListener(GameEvent.VIP_START, onVIPStart);
			Experience.addEventListener(GameEvent.EXPERIENCE_CHANGED, onExperience);
		}

		private function showSchool(e:MouseEvent):void
		{
			RuntimeLoader.load(function():void
			{
				ScreenSchool.type = ScreenSchool.SHAMAN;
				Screens.show("School");
			}, true);
		}

		private function onVIPEnd(e:GameEvent):void
		{
			this.buttonPalette.visible = false;
			this.boards['common'].visible = true;
			this.boards['VIP'].visible = false;
			DialogPalette.hide();
		}

		private function onVIPStart(e:GameEvent):void
		{
			this.buttonPalette.visible = true;
			this.boards['common'].visible = false;
			this.boards['VIP'].visible = true;
		}

		private function onExperience(e:GameEvent):void
		{
			if ((ScreenProfile.playerId != Game.selfId))
				return;

			this.rankField.text = String(Experience.getTitle(Experience.selfLevel, false));
			toggleCreateClanButton((Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS) && Game.self['clan_id'] == 0);
		}

		private function toggleSelfItems(value:Boolean):void
		{
			this.nameEditField.visible = false;
			this.nameEditButton.visible = false;
			this.nameField.visible = true;

			toggleCreateClanButton(value && this.player != null && (this.player['level'] >= Game.LEVEL_TO_OPEN_CLANS) && this.player['clan_id'] == 0);
			this.buttonPalette.visible = value && (this.player['vip_exist'] > 0);
			this.boards['common'].visible = !(value && (this.player['vip_exist'] > 0));
			this.boards['VIP'].visible = value && (this.player['vip_exist'] > 0);

			toggleCertificate(value);

			if (Screens.active is ScreenProfile)
				HeaderExtended.toggleButtons(value);

			this.nameEditButton.visible = value;

			if (value && Game.self['clan_id'] == 0)
				this.clanBoard.clanId = 0;
		}

		private function setPlayerId(id:int):void
		{
			if (!this.inited)
			{
				this.beginId = id;
				return;
			}

			if (id == Game.selfId && this.player != null)
				toggleSelfItems(true);

			if (this.playerId == id)
				return;

			if (this.player != null)
				this.player.removeEventListener(onPlayerLoaded);

			this.playerId = id;

			this.player = Game.getPlayer(id);

			this.player.addEventListener(ScreenProfile.LOAD_MASK, onPlayerLoaded);
			Game.request(id, ScreenProfile.LOAD_MASK);

			dispatchEvent(new GameEvent(GameEvent.PROFILE_PLAYER_CHANGED));
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;

			if (!this.nameEditField.visible)
				return;

			onSave();
		}

		private function onPlayerLoaded(player:Player):void
		{
			if (player.id != this.player.id)
				return;

			toggleSelfItems(this.player.id == Game.selfId);

			this.interiorView.load(this.player['interior']);

			TextFieldUtil.formatField(this.nameField, this.player.name, 140);

			this.rankField.text = String(Experience.getTitle(this.player['level'], false));
			(this.sexButton as SexView).updateSex(this.player.sex);

			updateHero();

			if (this.player['online'] && this.player['uid'] != Game.selfId)
			{
				this.hero.visible = false;
				this.saveWorld.visible = true;
			}
			else
			{
				this.hero.visible = true;
				this.saveWorld.visible = false;
			}

			this.clanBoard.clanId = this.player['clan_id'];
		}

		private function soundClick(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.CLICK);
		}

		private function soundOver(e:MouseEvent):void
		{

		}

		private function onEdit(e:MouseEvent):void
		{
			toggleEdit(true);

			e.stopImmediatePropagation();
		}

		private function onSave(e:MouseEvent = null):void
		{
			var name:String = StringUtil.trim(this.nameEditField.text);

			if (name == "" || name == Game.self.name)
			{
				cancel();
				return;
			}

			if (Experience.selfLevel >= Game.LEVEL_TO_PAY_FOR_NICK)
			{
				if (!this.dialogBuyNickname)
					this.dialogBuyNickname = new DialogBuyNickname(rename, cancel);
				this.dialogBuyNickname.show();
			}
			else
				save();
		}

		private function rename():void
		{
			var name:String = StringUtil.trim(this.nameEditField.text);

			Connection.sendData(PacketClient.RENAME, name);

			TextFieldUtil.formatField(this.nameField, name, 140);
			toggleEdit(false);
		}

		private function save():void
		{
			var name:String = StringUtil.trim(this.nameEditField.text);

			Game.saveSelf({'name': name, 'sex': Game.self.sex});

			TextFieldUtil.formatField(this.nameField, Game.self.name, 140);
			toggleEdit(false);
			Game.request(Game.selfId, PlayerInfoParser.NAME);
		}

		private function cancel():void
		{
			toggleEdit(false);
		}

		private function toggleEdit(edit:Boolean):void
		{
			this.nameEditField.visible = edit;

			if (edit)
			{
				this.nameEditField.text = Game.self['name'];
				this.nameEditField.setSelection(this.nameEditField.text.length, this.nameEditField.text.length);
				Game.stage.focus = this.nameEditField;
			}

			this.nameField.visible = !edit;
		}

		private function toggleCertificate(value:Boolean):void
		{
			this.shamanCertificate.visible = value && FlagsManager.has(Flag.SHAMAN_SCHOOL_FINISH);
			this.shamanCertificatePlace.visible = value && !FlagsManager.has(Flag.SHAMAN_SCHOOL_FINISH);
		}

		private function updateHero():void
		{
			if (this.player.id == Game.selfId)
			{
				if (ClothesManager.isScrat)
					this.hero.view = OutfitData.OWNER_SCRAT;
				else if (ClothesManager.isScratty)
					this.hero.view = OutfitData.OWNER_SCRATTY;
				else
					this.hero.view = OutfitData.OWNER_SQUIRREL;
				this.hero.setClothes(ClothesManager.wornPackages, ClothesManager.wornAccessories);
			}
			else
			{
				var isScrat:Boolean = false;
				for (var i:int = 0; i < this.player['weared_packages'].length; i++)
					isScrat = isScrat || OutfitData.isScratSkin(this.player['weared_packages'][i]);
				var isScratty:Boolean = false;
				for (i = 0; i < this.player['weared_packages'].length; i++)
					isScratty = isScratty || OutfitData.isScrattySkin(this.player['weared_packages'][i]);

				if (isScrat)
					this.hero.view = OutfitData.OWNER_SCRAT;
				else if (isScratty)
					this.hero.view = OutfitData.OWNER_SCRATTY;
				else
					this.hero.view = OutfitData.OWNER_SQUIRREL;
				this.hero.setClothes(this.player['weared_packages'], this.player['weared_accessories']);
			}
		}

		private function changeInterior(e:GameEvent):void
		{
			this.interiorView.load(Game.self['interior']);
		}
	}
}