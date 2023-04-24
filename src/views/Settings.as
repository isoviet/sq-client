package views
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;

	import buttons.ButtonMultipleSettings;
	import buttons.ButtonToggle;
	import dialogs.Dialog;
	import dialogs.DialogInfo;
	import dialogs.DialogTransfer;
	import events.ScreenEvent;
	import game.gameData.FlagsManager;
	import game.gameData.SettingsStorage;
	import loaders.ScreensLoader;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.ScreenSchool;
	import screens.Screens;
	import sounds.GameMusic;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;

	import protocol.Flag;

	public class Settings extends Sprite
	{
		static private const TOP_MARGIN:int = 35;
		static private const OFFSET:int = 25;

		static private const LEFT_MARGIN:int = 4;

		static private var _instance:Settings;

		static public var highlight:int = 2;

		private var background:SettingsBackground;

		private var buttonOpen:SimpleButton;
		private var buttonClose:SimpleButton;

		private var buttonEditor:SimpleButton;

		private var buttonToggleMusic:ButtonToggle;
		private var buttonToggleSound:ButtonToggle;
		private var buttonToggleCamera:ButtonToggle;
		private var buttonToggleQuality:ButtonToggle;
		private var buttonToggleHighLight:ButtonMultipleSettings;
		private var buttonToggleShaman:ButtonToggle;
		private var toggleClanInvitesButtons:ButtonToggle;

		private var copySession:SimpleButton = null;
		private var dialogInfoQuality:Dialog;

		private var addedClanInvites:Boolean = false;
		private var indexClanInvites:int = 0;

		private var localData:Object = {};

		private var buttonsArray:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		public function Settings():void
		{
			_instance = this;
			super();

			this.visible = false;
			this.localData = SettingsStorage.load(SettingsStorage.SETTINGS);
			SettingsStorage.addCallback(SettingsStorage.SETTINGS, onLoad);
			FlagsManager.onLoad(onFlagsInit);

			init();
			extendsElements(false);
		}

		static public function updateToggleButtons():void
		{
			_instance.updateToggleButtons();

		}

		static public function addClanInvitesButton():void
		{
			if (!_instance)
				return;

			if (_instance.addedClanInvites)
				return;

			_instance.addedClanInvites = true;

			var clanInvitesOn:ButtonClansOn = new ButtonClansOn();
			clanInvitesOn.addEventListener(MouseEvent.MOUSE_DOWN, _instance.soundClick);
			clanInvitesOn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				Game.clanInvites = false;
				FlagsManager.set(Flag.HIDE_CLAN_INVITES);
			});
			new Status(clanInvitesOn, gls("Не получать приглашения в клан"));

			var clanInvitesOff:ButtonClansOff = new ButtonClansOff();
			clanInvitesOff.addEventListener(MouseEvent.MOUSE_DOWN, _instance.soundClick);
			clanInvitesOff.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				Game.clanInvites = true;
				FlagsManager.unset(Flag.HIDE_CLAN_INVITES);
			});
			new Status(clanInvitesOff, gls("Получать приглашения в клан"));

			_instance.toggleClanInvitesButtons = new ButtonToggle(clanInvitesOn, clanInvitesOff, !Game.clanInvites);
			_instance.toggleClanInvitesButtons.x = 6;
			_instance.toggleClanInvitesButtons.y = TOP_MARGIN + _instance.indexClanInvites * OFFSET;
			_instance.addChild(_instance.toggleClanInvitesButtons);

			for (var i:int = _instance.indexClanInvites; i < _instance.buttonsArray.length; i++)
				_instance.buttonsArray[i].y += OFFSET;

			_instance.buttonsArray.splice(_instance.indexClanInvites, 0, _instance.toggleClanInvitesButtons);
			_instance.background.height = _instance.buttonsArray.length * OFFSET;

			_instance.toggleClanInvitesButtons.visible = _instance.background.visible;
		}

		override public function set scaleX(value:Number):void
		{
			var newX:int = this.buttonOpen.width * (1 - value) / 2;

			this.buttonOpen.scaleX = this.buttonClose.scaleX = value;

			this.buttonOpen.x = newX;
			this.buttonClose.x = newX;
		}

		override public function set scaleY(value:Number):void
		{
			this.buttonOpen.scaleY = this.buttonClose.scaleY = value;
		}

		private function init():void
		{
			var enableHighQuality:Boolean = false;

			this.dialogInfoQuality = new DialogInfo(gls("Качество изображения"), gls("Для смены качества изображения\nвыйди на экран планет"));

			this.background = new SettingsBackground();
			this.background.y = TOP_MARGIN;
			addChild(this.background);

			this.buttonOpen = new ButtonSettingsOpen();
			this.buttonOpen.x = LEFT_MARGIN;
			this.buttonOpen.addEventListener(MouseEvent.CLICK, hideElements);
			this.buttonOpen.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			addChild(this.buttonOpen);
			new Status(buttonOpen, gls("Настройки"));

			this.buttonClose = new ButtonSettingsClose();
			this.buttonClose.x = LEFT_MARGIN;
			this.buttonClose.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			this.buttonClose.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{

				extendsElements(false);
			});
			addChild(this.buttonClose);

			var buttonMusicOn:ButtonMusicOn = new ButtonMusicOn();
			buttonMusicOn.addEventListener(MouseEvent.CLICK, musicOn);
			buttonMusicOn.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonMusicOn, gls("Выключить музыку"));

			var buttonMusicOff:ButtonMusicOff = new ButtonMusicOff();
			buttonMusicOff.addEventListener(MouseEvent.CLICK, musicOff);
			buttonMusicOff.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonMusicOff, gls("Включить музыку"));

			this.buttonToggleMusic = new ButtonToggle(buttonMusicOff, buttonMusicOn, GameMusic.on);
			addChild(this.buttonToggleMusic);
			this.buttonsArray.push(this.buttonToggleMusic);

			var buttonSoundOff:ButtonSoundOff = new ButtonSoundOff();
			buttonSoundOff.addEventListener(MouseEvent.CLICK, soundOff);
			buttonSoundOff.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonSoundOff, gls("Включить звук"));

			var buttonSoundOn:ButtonSoundOn = new ButtonSoundOn();
			buttonSoundOn.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			buttonSoundOn.addEventListener(MouseEvent.CLICK, soundOn);
			new Status(buttonSoundOn, gls("Выключить звук"));

			this.buttonToggleSound = new ButtonToggle(buttonSoundOff, buttonSoundOn, GameSounds.on);
			addChild(this.buttonToggleSound);
			this.buttonsArray.push(this.buttonToggleSound);

			var buttonCameraOff:ButtonCameraOff = new ButtonCameraOff();
			buttonCameraOff.addEventListener(MouseEvent.CLICK, cameraOff);
			buttonCameraOff.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonCameraOff, gls("Включить слежение за белкой"));

			var buttonCameraOn:ButtonCameraOn = new ButtonCameraOn();
			buttonCameraOn.addEventListener(MouseEvent.CLICK, cameraOn);
			buttonCameraOn.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonCameraOn, gls("Выключить слежение за белкой"));

			this.buttonToggleCamera = new ButtonToggle(buttonCameraOff, buttonCameraOn, !FlagsManager.has(Flag.CAMERA_TRACK));
			addChild(this.buttonToggleCamera);
			this.buttonsArray.push(this.buttonToggleCamera);

			var buttonHighQuality:ButtonLQ = new ButtonLQ();
			buttonHighQuality.addEventListener(MouseEvent.CLICK, lowQuality);
			buttonHighQuality.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonHighQuality, gls("Низкое качество"));

			var buttonLowQuality:ButtonHQ = new ButtonHQ();
			buttonLowQuality.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			buttonLowQuality.addEventListener(MouseEvent.CLICK, highQuality);
			new Status(buttonLowQuality, gls("Высокое качество"));

			if ('quality' in this.localData)
			{
				Game.stage.quality = this.localData['quality'];
				enableHighQuality = this.localData['quality'] != "LOW";
			}

			this.buttonToggleQuality = new ButtonToggle(buttonHighQuality, buttonLowQuality, enableHighQuality);
			addChild(this.buttonToggleQuality);
			this.buttonsArray.push(this.buttonToggleQuality);

			var buttonHighlightPaleOn:ButtonBacklightOn = new ButtonBacklightOn();
			buttonHighlightPaleOn.addEventListener(MouseEvent.CLICK, backligthOn);
			buttonHighlightPaleOn.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonHighlightPaleOn, gls("Включить слабую подсветку своей белки"));

			var buttonHighlightStrongOn:ButtonBacklightOn = new ButtonBacklightOn();
			buttonHighlightStrongOn.addEventListener(MouseEvent.CLICK, backligthSuper);
			buttonHighlightStrongOn.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			new Status(buttonHighlightStrongOn, gls("Включить сильную подсветку своей белки"));

			var buttonHighlightOff:ButtonBacklightOff = new ButtonBacklightOff();
			buttonHighlightOff.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			buttonHighlightOff.addEventListener(MouseEvent.CLICK, backligthOff);
			new Status(buttonHighlightOff, gls("Выключить подсветку своей белки"));

			if ('highlight' in this.localData)
				highlight = int(this.localData['highlight']);
			else
				highlight = 0;

			this.buttonToggleHighLight = new ButtonMultipleSettings([buttonHighlightOff, buttonHighlightPaleOn, buttonHighlightStrongOn], highlight);
			addChild(this.buttonToggleHighLight);
			this.buttonsArray.push(this.buttonToggleHighLight);

			var buttonShamanOn:ButtonShamanOn = new ButtonShamanOn();
			buttonShamanOn.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			buttonShamanOn.addEventListener(MouseEvent.CLICK, shamanOn);
			new Status(buttonShamanOn, gls("Не хочу быть шаманом"));

			var buttonShamanOff:ButtonShamanOff = new ButtonShamanOff();
			buttonShamanOff.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			buttonShamanOff.addEventListener(MouseEvent.CLICK, shamanOff);
			new Status(buttonShamanOff, gls("Хочу быть шаманом"));

			this.buttonToggleShaman = new ButtonToggle(buttonShamanOn, buttonShamanOff, Game.notBecomeShaman);
			addChild(this.buttonToggleShaman);
			this.buttonsArray.push(this.buttonToggleShaman);

			this.indexClanInvites = this.buttonsArray.length;

			if (Config.isEng)
			{
				this.copySession = new CopySessionFB();
				this.copySession.addEventListener(MouseEvent.CLICK, onCopy);

				if (!Game.transferComplete)
				{
					addChild(copySession);
					this.buttonsArray.push(copySession);
				}

				new Status(this.copySession, "Restore my profile");
			}

			this.buttonEditor = new ButtonEditor();
			this.buttonEditor.addEventListener(MouseEvent.CLICK, showEditor);
			this.buttonEditor.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			addChild(this.buttonEditor);
			new Status(this.buttonEditor, gls("Редактор карт"));
			this.buttonsArray.push(this.buttonEditor);

			update();

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
		}

		private function update():void
		{
			var offset:int = 2;

			for (var i:int = 0; i < this.buttonsArray.length; i++)
			{
				this.buttonsArray[i].x = LEFT_MARGIN;
				this.buttonsArray[i].y = TOP_MARGIN + offset;
				offset += this.buttonsArray[i].visible ? Math.max(this.buttonsArray[i].height + 2, OFFSET) : 0;
			}
			this.background.height = offset + 2;
		}

		private function showEditor(e:MouseEvent):void
		{
			if (Screens.active is ScreenGame || Screens.active is ScreenEdit || Screens.active is ScreenSchool || Screens.active is ScreenLearning)
			{
				new DialogInfo(gls("Информация"), gls("Ты не можешь сейчас перейти в Редактор.\nТебе необходимо вернуться на экран планет.")).show();
				return;
			}
			ScreensLoader.load(ScreenEdit.instance);
		}

		private function shamanOff(e:MouseEvent):void
		{
			Game.notBecomeShaman = false;
			FlagsManager.unset(Flag.NOT_BE_SHAMAN);
		}

		private function shamanOn(e:MouseEvent):void
		{
			Game.notBecomeShaman = true;
			FlagsManager.set(Flag.NOT_BE_SHAMAN);
		}

		private function backligthSuper(e:MouseEvent):void
		{
			highlight = 2;
			localData['highlight'] = highlight;
			SettingsStorage.save(SettingsStorage.SETTINGS, localData);
		}

		private function backligthOn(e:MouseEvent):void
		{
			highlight = 1;
			localData['highlight'] = highlight;
			SettingsStorage.save(SettingsStorage.SETTINGS, localData);
		}

		private function backligthOff(e:MouseEvent):void
		{
			highlight = 0;
			this.localData['highlight'] = highlight;
			SettingsStorage.save(SettingsStorage.SETTINGS, this.localData);
		}

		private function highQuality(e:MouseEvent):void
		{
			if (Screens.active is ScreenGame || Screens.active is ScreenSchool || Screens.active is ScreenLearning)
			{
				e.stopImmediatePropagation();
				dialogInfoQuality.show();
			}
			else
			{
				Game.stage.quality = StageQuality.LOW;
				this.localData['quality'] = Game.stage.quality;
				SettingsStorage.save(SettingsStorage.SETTINGS, this.localData);
				FullScreenManager.instance().updateToggleButtons();
			}
		}

		private function lowQuality(e:MouseEvent):void
		{
			if (Screens.active is ScreenGame || Screens.active is ScreenSchool || Screens.active is ScreenLearning)
			{
				e.stopImmediatePropagation();
				dialogInfoQuality.show();
			}
			else
			{
				Game.stage.quality = StageQuality.HIGH;
				this.localData['quality'] = Game.stage.quality;
				SettingsStorage.save(SettingsStorage.SETTINGS, this.localData);
				FullScreenManager.instance().updateToggleButtons();
			}
		}

		private function cameraOff(e:MouseEvent):void
		{
			FlagsManager.unset(Flag.CAMERA_TRACK);
		}

		private function cameraOn(e:MouseEvent):void
		{
			FlagsManager.set(Flag.CAMERA_TRACK);
		}

		private function soundOff(e:MouseEvent):void
		{
			GameSounds.on = true;
			FlagsManager.unset(Flag.SOUND);
		}

		private function soundOn(e:MouseEvent):void
		{
			GameSounds.on = false;
			GameSounds.play(SoundConstants.CLICK);
			FlagsManager.set(Flag.SOUND);
		}

		private function musicOff(e:MouseEvent):void
		{
			GameMusic.on = true;
			FullScreenManager.instance().updateToggleButtons();
			FlagsManager.unset(Flag.MUSIC);
		}

		private function musicOn(e:MouseEvent):void
		{
			GameMusic.on = false;
			FullScreenManager.instance().updateToggleButtons();
			FlagsManager.set(Flag.MUSIC);
		}

		private function onLoad():void
		{
			this.localData = SettingsStorage.load(SettingsStorage.SETTINGS);

			updateToggleButtons();
		}

		private function onFlagsInit():void
		{
			updateToggleButtons();
		}

		private function onCopy(e:MouseEvent):void
		{
			DialogTransfer.show();
		}

		private function soundClick(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);
		}

		private function hideElements(e:MouseEvent):void
		{
			extendsElements(true);
		}

		private function extendsElements(value:Boolean):void
		{
			this.buttonOpen.visible = !value;
			this.buttonClose.visible = value;

			this.background.visible = value;

			for each (var element:DisplayObject in this.buttonsArray)
				element.visible = value;

			update();

			Game.stage.removeEventListener(MouseEvent.MOUSE_DOWN, click);
			if (value)
				Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, click);
		}

		private function click(e:MouseEvent):void
		{
			if (e.target)
			{
				for each (var element:DisplayObject in this.buttonsArray)
				{
					if (e.target == element || e.target.parent == element)
						return;
				}
			}

			extendsElements(false);
		}

		private function updateToggleButtons():void
		{
			GameMusic.on ? this.buttonToggleMusic.on() : this.buttonToggleMusic.off();
			GameSounds.on ? this.buttonToggleSound.on() : this.buttonToggleSound.off();

			if ('quality' in this.localData)
			{
				(this.localData['quality'] != "LOW") ? this.buttonToggleQuality.on() : this.buttonToggleQuality.off();
				Game.stage.quality = this.localData['quality'] == 0 ? StageQuality.HIGH : StageQuality.LOW;
			}

			Game.notBecomeShaman ? this.buttonToggleShaman.on() : this.buttonToggleShaman.off();

			//TODO переключать
			//if (this.buttonToggleFullscreen != null)
			//	FullScreenManager.instance().fullScreen ? this.buttonToggleFullscreen.on() : this.buttonToggleFullscreen.off();
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			extendsElements(false);
		}
	}
}