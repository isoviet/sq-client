package game.mainGame.gameEditor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;

	import dialogs.DialogMapInfo;
	import dialogs.DialogScreenshot;
	import game.mainGame.entity.editor.inspector.InspectorDialog;
	import statuses.Status;

	import protocol.PacketServer;

	import utils.FiltersUtil;

	public class EditorHeader extends Sprite
	{
		private var seconds:int;
		private var minutes:int;
		private var labelTime:GameField;
		private var timeLabel:GameField;
		private var undoEnable:Boolean = false;
		private var redoEnable:Boolean = false;
		private var isRecording:Boolean = false;
		private var screenShotStatus:Status;
		private var formatEditTime:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 10, 0x000000);
		private var formatHitTime:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 13, 0x027B00, true);

		private var timer:Timer = new Timer(1000);

		private var game:SquirrelGameEditor;
		private var state:DisplayObject = null;

		private var handButtonStatus:Status;

		private var currentLocation:int = 0;

		public var fieldNumber:GameField;
		public var numberField:GameField;
		public var screenshotButton:ButtonPhotoHeader = null;
		public var nextMapButton:ButtonNextMap = null;
		public var prevMapButton:ButtonPrevMap = null;
		public var deleteMapButton:ButtonDeleteMap = null;
		public var editorLoadButton:ButtonEditorLoad = null;
		public var editorSaveButton:ButtonEditorSave = null;
		public var editorApprove:ButtonEditorSave = null;
		public var editorSendButton:ButtonEditorSend = null;
		public var editorTestButton:ButtonTestMap = null;
		public var editButton:ButtonEditorEdit = null;
		public var redoEditorButton:ButtonRedo = null;
		public var undoEditorButton:ButtonUndo = null;
		public var handEditorButton:ButtonHand = null;
		public var rulesEditorButton:ButtonRule = null;
		public var recordButton:ButtonRule = null;
		public var replayButton:ButtonRule = null;
		public var mapInfoButton:ButtonMapInfo = null;
		public var objectInfoButton:ButtonOjectInfo = null;
		public var objectsInspectorButton:ButtonRule = null;

		public var editing:Boolean = false;
		private var _menuForModerApprove: Boolean = false;

		public function EditorHeader(game:SquirrelGameEditor):void
		{
			this.game = game;

			addChild(new ImageHeaderEditor());

			this.screenshotButton = new ButtonPhotoHeader();
			this.screenshotButton.x = 609;
			this.screenshotButton.y = 1;
			this.screenshotButton.addEventListener(MouseEvent.CLICK, showDialogScreenshot);
			addChild(this.screenshotButton);
			this.screenShotStatus = new Status(screenshotButton, gls("Снимок экрана"));

			this.nextMapButton = new ButtonNextMap();
			this.nextMapButton.x = 570;
			this.nextMapButton.y = 1;
			addChild(this.nextMapButton);
			new Status(nextMapButton, gls("Следующая карта"));
			if (Game.editor_access == 0)
				this.nextMapButton.visible = false;

			this.prevMapButton = new ButtonPrevMap();
			this.prevMapButton.x = 544;
			this.prevMapButton.y = 1;
			addChild(this.prevMapButton);
			new Status(prevMapButton, gls("Предыдущая карта"));
			if (Game.editor_access == 0)
				this.prevMapButton.visible = false;

			this.deleteMapButton = new ButtonDeleteMap();
			this.deleteMapButton.x = 504;
			this.deleteMapButton.y = 1;
			addChild(this.deleteMapButton);
			new Status(deleteMapButton, gls("Удалить"));

			this.editorLoadButton = new ButtonEditorLoad();
			this.editorLoadButton.x = 476;
			this.editorLoadButton.y = 1;
			addChild(this.editorLoadButton);
			new Status(editorLoadButton, gls("Загрузить сохраненную карту"));

			this.editorSaveButton = new ButtonEditorSave();
			this.editorSaveButton.x = 449;
			this.editorSaveButton.y = 1;
			addChild(this.editorSaveButton);
			new Status(editorSaveButton, gls("Сохранить как черновик"));

			this.editorSendButton = new ButtonEditorSend();
			this.editorSendButton.x = 422;
			this.editorSendButton.y = 1;
			addChild(this.editorSendButton);

			this.editorApprove = new ButtonEditorSave();
			this.editorApprove.x = 476;
			this.editorApprove.y = 1;
			addChild(this.editorApprove);
			new Status(this.editorApprove, gls("Одобрить"));

			if (Game.editor_access == PacketServer.EDITOR_NONE)
				new Status(this.editorSendButton, gls("Отправить на проверку"));
			else
				new Status(this.editorSendButton, gls("Сохранить"));

			this.editorTestButton = new ButtonTestMap();
			this.editorTestButton.x = 394;
			this.editorTestButton.y = 1;
			this.editorTestButton.addEventListener(MouseEvent.CLICK, onTest);
			addChild(this.editorTestButton);
			new Status(editorTestButton, gls("Тестировать"));

			this.editButton = new ButtonEditorEdit();
			this.editButton.x = 394;
			this.editButton.y = 1;
			this.editButton.visible = false;
			this.editButton.addEventListener(MouseEvent.CLICK, onEdit);
			addChild(this.editButton);
			new Status(editButton, gls("Редактировать"));

			this.redoEditorButton = new ButtonRedo();
			this.redoEditorButton.x = 173;
			this.redoEditorButton.y = 1;
			addChild(this.redoEditorButton);
			new Status(redoEditorButton, gls("Шаг вперед"));

			this.undoEditorButton = new ButtonUndo();
			this.undoEditorButton.x = 146;
			this.undoEditorButton.y = 1;
			addChild(this.undoEditorButton);
			new Status(undoEditorButton, gls("Шаг назад"));

			this.handEditorButton = new ButtonHand();
			this.handEditorButton.x = 92;
			this.handEditorButton.y = 1;
			this.handEditorButton.addEventListener(MouseEvent.CLICK, onHand);
			addChild(this.handEditorButton);
			this.handButtonStatus = new Status(handEditorButton, gls("Включить\\выключить"));

			this.rulesEditorButton = new ButtonRule();
			this.rulesEditorButton.x = 93;
			this.rulesEditorButton.y = 1;
//			addChild(this.rulesEditorButton);
			new Status(rulesEditorButton, gls("Линейка"));

			this.recordButton = new ButtonRule();
			this.recordButton.x = 93;
			this.recordButton.y = 1;
//			addChild(this.recordButton);
			new Status(recordButton, gls("Список записей"));

			this.mapInfoButton = new ButtonMapInfo();
			this.mapInfoButton.x = 36;
			this.mapInfoButton.y = 1;
			addChild(this.mapInfoButton);
			new Status(mapInfoButton, gls("Инфо о карте"));

			this.objectInfoButton = new ButtonOjectInfo();
			this.objectInfoButton.x = 7;
			this.objectInfoButton.y = 1;
			this.objectInfoButton.addEventListener(MouseEvent.CLICK, showDialogObject);
			addChild(this.objectInfoButton);
			new Status(objectInfoButton, gls("Объект"));

			this.objectsInspectorButton = new ButtonRule();	//TODO replace button
			this.objectsInspectorButton.x = this.mapInfoButton.x + this.mapInfoButton.width + 5;
			this.objectsInspectorButton.y = 1;
			this.objectsInspectorButton.visible = Game.editor_access != PacketServer.EDITOR_NONE;
			addChild(this.objectsInspectorButton);
			new Status(objectsInspectorButton, gls("Инспектор объектов"));

			this.labelTime = new GameField(gls("Время:"), 255, 7, this.formatEditTime);
			this.labelTime.visible = false;
			this.timeLabel = new GameField("", 286, 4, this.formatHitTime);
			addChild(this.labelTime);
			addChild(this.timeLabel);

			this.fieldNumber = new GameField(gls("Номер карты:"), 222, 7, this.formatEditTime);
			this.numberField = new GameField("", 293, 4, this.formatHitTime);
			this.numberField.addEventListener(MouseEvent.CLICK, copyToClipBoard);

			if (Game.editor_access)
			{
				addChild(this.fieldNumber);
				addChild(this.numberField);
			}

			this.timer.addEventListener(TimerEvent.TIMER, onTick, false, 0, true);

			initButtons();
		}

		public function get menuForModerApprove(): Boolean
		{
			return _menuForModerApprove;
		}

		public function onTest(e:MouseEvent = null):void
		{
			if ((this.game.map as GameMapEditor).selection.handButton)
				onHand(null);

			this.editButton.visible = true;
			this.editorTestButton.visible = false;

			this.undoEnable = this.undoEditorButton.enabled;

			this.redoEnable = this.redoEditorButton.enabled;

			blockButton();
			this.seconds = DialogMapInfo.seconds;
			this.minutes = DialogMapInfo.minutes;
			this.fieldNumber.visible = false;
			this.numberField.visible = false;
			this.timer.start();
		}

		public function blockButton():void
		{
			this.nextMapButton.enabled = false;
			this.nextMapButton.mouseEnabled = false;
			this.nextMapButton.filters = FiltersUtil.GREY_FILTER;

			this.prevMapButton.enabled = false;
			this.prevMapButton.mouseEnabled = false;
			this.prevMapButton.filters = FiltersUtil.GREY_FILTER;

			this.deleteMapButton.enabled = false;
			this.deleteMapButton.mouseEnabled = false;
			this.deleteMapButton.filters = FiltersUtil.GREY_FILTER;

			this.editorLoadButton.enabled = false;
			this.editorLoadButton.mouseEnabled = false;
			this.editorLoadButton.filters = FiltersUtil.GREY_FILTER;

			this.editorSaveButton.enabled = false;
			this.editorSaveButton.mouseEnabled = false;
			this.editorSaveButton.filters = FiltersUtil.GREY_FILTER;

			this.editorSendButton.enabled = false;
			this.editorSendButton.mouseEnabled = false;
			this.editorSendButton.filters = FiltersUtil.GREY_FILTER;

			this.redoEditorButton.enabled = false;
			this.redoEditorButton.mouseEnabled = false;
			this.redoEditorButton.filters = FiltersUtil.GREY_FILTER;

			this.undoEditorButton.enabled = false;
			this.undoEditorButton.mouseEnabled = false;
			this.undoEditorButton.filters = FiltersUtil.GREY_FILTER;

			this.handEditorButton.enabled = false;
			this.handEditorButton.mouseEnabled = false;
			this.handEditorButton.filters = FiltersUtil.GREY_FILTER;

			this.rulesEditorButton.enabled = false;
			this.rulesEditorButton.mouseEnabled = false;
			this.rulesEditorButton.filters = FiltersUtil.GREY_FILTER;

			this.mapInfoButton.enabled = false;
			this.mapInfoButton.mouseEnabled = false;
			this.mapInfoButton.filters = FiltersUtil.GREY_FILTER;

			this.objectInfoButton.enabled = false;
			this.objectInfoButton.mouseEnabled = false;
			this.objectInfoButton.filters = FiltersUtil.GREY_FILTER;

			this.objectsInspectorButton.enabled = false;
			this.objectsInspectorButton.mouseEnabled = false;
			this.objectsInspectorButton.filters = FiltersUtil.GREY_FILTER;

			this.editorApprove.enabled = false;
			this.editorApprove.mouseEnabled = false;
			this.editorApprove.filters = FiltersUtil.GREY_FILTER;
		}

		public function updateModerButton(ignore: Boolean = false): void
		{
			this._menuForModerApprove = Game.editor_access == PacketServer.EDITOR_SUPER || Game.editor_access == PacketServer.EDITOR_APPROVAL ||
				Game.editor_access == PacketServer.EDITOR_APPROVAL_PLUS;
			this._menuForModerApprove = !ignore && this._menuForModerApprove && this.currentLocation == Locations.NONAME_ID;

			this.editorSaveButton.visible = !this._menuForModerApprove;
			this.editorSendButton.visible = !this._menuForModerApprove;
			this.editorLoadButton.visible = !this._menuForModerApprove;
			this.editorApprove.visible = this._menuForModerApprove;
			if(this._menuForModerApprove)
			{
				this.editorTestButton.x = 449;
				this.editButton.x = 449;
			}
			else
			{
				this.editorTestButton.x = 394;
				this.editButton.x = 394;
			}
		}

		public function enableButton():void
		{
			this.nextMapButton.enabled = true;
			this.nextMapButton.mouseEnabled = true;
			this.nextMapButton.filters = [];

			this.prevMapButton.enabled = true;
			this.prevMapButton.mouseEnabled = true;
			this.prevMapButton.filters = [];

			this.deleteMapButton.enabled = !this.editing || (Game.editor_access != PacketServer.EDITOR_SUPER) || (Game.editor_access == PacketServer.EDITOR_SUPER && (this.currentLocation == Locations.NONAME_ID || this.currentLocation == Locations.APPROVED_ID));
			this.deleteMapButton.mouseEnabled = !this.editing || (Game.editor_access != PacketServer.EDITOR_SUPER) || (Game.editor_access == PacketServer.EDITOR_SUPER && (this.currentLocation == Locations.NONAME_ID || this.currentLocation == Locations.APPROVED_ID));
			this.deleteMapButton.filters = !this.editing || (Game.editor_access != PacketServer.EDITOR_SUPER) || (Game.editor_access == PacketServer.EDITOR_SUPER && (this.currentLocation == Locations.NONAME_ID || this.currentLocation == Locations.APPROVED_ID)) ? [] : FiltersUtil.GREY_FILTER;

			this.editorLoadButton.enabled = true;
			this.editorLoadButton.mouseEnabled = true;
			this.editorLoadButton.filters = [];

			this.editorSaveButton.enabled = true;
			this.editorSaveButton.mouseEnabled = true;
			this.editorSaveButton.filters = [];

			this.editorSendButton.enabled = true;
			this.editorSendButton.mouseEnabled = true;
			this.editorSendButton.filters = [];

			this.editorApprove.enabled = true;
			this.editorApprove.mouseEnabled = true;
			this.editorApprove.filters = [];

			if (redoEnable)
			{
				this.redoEditorButton.enabled = true;
				this.redoEditorButton.mouseEnabled = true;
				this.redoEditorButton.filters = [];
			}

			if (undoEnable)
			{
				this.undoEditorButton.enabled = true;
				this.undoEditorButton.mouseEnabled = true;
				this.undoEditorButton.filters = [];
			}

			this.handEditorButton.enabled = true;
			this.handEditorButton.mouseEnabled = true;
			this.handEditorButton.filters = [];

			this.rulesEditorButton.enabled = true;
			this.rulesEditorButton.mouseEnabled = true;
			this.rulesEditorButton.filters = [];

			this.mapInfoButton.enabled = true;
			this.mapInfoButton.mouseEnabled = true;
			this.mapInfoButton.filters = [];

			this.objectInfoButton.enabled = true;
			this.objectInfoButton.mouseEnabled = true;
			this.objectInfoButton.filters = [];

			this.objectsInspectorButton.enabled = true;
			this.objectsInspectorButton.mouseEnabled = true;
			this.objectsInspectorButton.filters = [];
		}

		public function onEdit(e:MouseEvent = null):void
		{
			this.editButton.visible = false;
			this.editorTestButton.visible = true;
			enableButton();
			updateModerButton();
			this.labelTime.visible = false;
			this.timeLabel.text = "";
			this.fieldNumber.visible = true;
			this.numberField.visible = true;
			this.timer.stop();
		}

		public function onNew():void
		{
			this.deleteMapButton.visible = (Game.editor_access > 0);
			this.visible = true;
			updateModerButton(true);
		}

		public function onHand(e:MouseEvent = null):void
		{
			if (GameMapEditor(this.game.map).scale != 1)
				return;

			if (!(this.game.map as GameMapEditor).selection.handButton)
			{
				(this.game.map as GameMapEditor).selection.handButton = true;
				Mouse.cursor = MouseCursor.HAND;
				this.state = this.handEditorButton.upState;
				this.handEditorButton.upState = this.handEditorButton.downState;
			}
			else
			{
				(this.game.map as GameMapEditor).selection.handButton = false;
				Mouse.cursor = MouseCursor.AUTO;
				this.handEditorButton.upState = this.state;
			}
		}

		public function onOpen(locationId:int):void
		{
			this.currentLocation = locationId;
			enableButton();
			updateModerButton();
			this.visible = true;
		}

		private function onTick(e:TimerEvent):void
		{
			var addZero:String = "";

			this.labelTime.visible = true;
			if (this.seconds == 0)
			{
				this.minutes--;
				this.seconds = 60;
			}
			this.seconds--;

			this.seconds < 10 ? addZero = "0" : "";
			this.timeLabel.text = " " + minutes + ":" + addZero + seconds;

			if (minutes == 0 && seconds == 0)
			{
				timer.stop();
			}
		}

		private function showDialogScreenshot(e:MouseEvent):void
		{
			this.screenShotStatus.visible = false;
			DialogScreenshot.show();
			this.screenShotStatus.visible = true;
		}

		private function showDialogObject(e:MouseEvent):void
		{
			var gameMapEditor: GameMapEditor = GameMapEditor(this.game.map);

			if ((this.game.map as GameMapEditor).selection.selection.length != 0)
				gameMapEditor.wndInspector = new InspectorDialog(gameMapEditor.selection.selection[0]);
			else
				gameMapEditor.wndInspector = new InspectorDialog(this.game.map);

			gameMapEditor.wndInspector.show();
			gameMapEditor.wndInspector.visible = true;
		}

		private function copyToClipBoard(e:Event):void
		{
			System.setClipboard(this.numberField.text);
		}

		private function initButtons():void
		{}
	}
}