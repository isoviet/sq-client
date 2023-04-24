package game.mainGame.gameEditor
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	import buttons.ButtonBase;
	import dialogs.DialogEditorConfig;
	import dialogs.DialogExit;
	import dialogs.DialogInfo;
	import dialogs.DialogLocation;
	import dialogs.DialogMapInfo;
	import dialogs.DialogObjectsInspector;
	import dialogs.DialogRecord;
	import dialogs.DialogSaveMap;
	import events.EditNewElementEvent;
	import events.NewBackgroundEvent;
	import events.ShamanEvent;
	import footers.FooterGame;
	import game.mainGame.Backgrounds;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.editor.BlackShamanBody;
	import game.mainGame.entity.editor.RedShamanBody;
	import game.mainGame.entity.editor.ShamanBody;
	import game.mainGame.events.CastEvent;
	import game.mainGame.gameRecord.CastRecord;
	import game.mainGame.perks.mana.PerkFactory;
	import headers.HeaderShort;
	import screens.ScreenEdit;
	import screens.Screens;
	import tape.TapeBackgrounds;
	import tape.TapeEdit;
	import tape.TapePlatform;
	import views.Settings;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketMapsId;
	import protocol.packages.server.PacketMapsMap;

	import utils.ComboBoxUtil;
	import utils.FiltersUtil;
	import utils.StringUtil;

	public class SquirrelGameEditor extends SquirrelGame
	{
		static private const ROUND_DEFAULT_START_TIME:int = 180;

		static private const ROPED_SQUIRRELS_MIN:int = 3;

		private var mapInfo:String = "";
		private var isTesting:Boolean = false;
		private var deleteFromDialog:Boolean = false;
		private var isNewMap:Boolean = false;
		private var localsaved:Boolean = false;
		private var footer:EditorFooter = new EditorFooter();
		private var dialogMapInfo:DialogMapInfo = new DialogMapInfo(footer);

		private var myFileReference:FileReference = new FileReference();
		private var myFileLoad:FileReference = new FileReference();

		private var dialogDelete:DialogInfo = null;
		private var dialogSave:DialogSaveMap = null;

		private var dialogCantSave:DialogInfo = null;

		private var dialogCantSaveSimple:DialogInfo = null;
		private var dialogCantSaveSimple2:DialogInfo = null;

		private var dialogCantSaveBattle:DialogInfo = null;
		private var dialogCantSaveBattle2:DialogInfo = null;
		private var dialogCantSaveBattleContest:DialogInfo = null;

		private var dialogCantSaveDragons:DialogInfo = null;
		private var dialogCantSaveDragons2:DialogInfo = null;

		private var dialogCantSaveRoped2:DialogInfo = null;

		private var dialogCantSaveTwoShamans:DialogInfo = null;
		private var dialogCantSaveTwoShamans2:DialogInfo = null;

		private var dialogCantSaveSurvival:DialogInfo = null;
		private var dialogCantSaveSurvival2:DialogInfo = null;

		private var dialogCantSaveFlyAcorn1:DialogInfo = null;
		private var dialogCantSaveFlyAcorn2:DialogInfo = null;

		private var dialogObjectsInspector:DialogObjectsInspector = null;

		private var dialogNeedTest:DialogInfo = null;
		private var dialogExit:DialogExit = null;

		private var currentMap:MapData = new MapData();
		private var newMap:MapData = new MapData();

		private var timer:Timer = new Timer(1000);

		private var flagNextAndPrev:String = "";
		private var stringX:String = "";
		private var stringY:String = "";
		private var interval:int = 40;
		private var shiftRuleX:int = -1;
		private var shiftRuleY:int = -1;
		private var ruleBarX:BitmapData = new BitmapData(Config.GAME_WIDTH + interval, 15, true, 0x00FFFFFF);
		private var ruleBarY:BitmapData = new BitmapData(Config.GAME_HEIGHT + interval, 15, true, 0x00FFFFFF);

		private var _scale:Number = 1;
		private var currentScale:Number = 1;
		private var openBrowse: Boolean = false;

		public var lastTestedMap:MapData = new MapData();

		public var line:Object;
		public var lines:Array = [];
		public var dragLine:Boolean = false;

		public var dialogConfig:DialogEditorConfig = null;
		public var header:EditorHeader;
		public var frameSprite:Sprite = new Sprite();
		public var scaleBar:MovieClip;

		public var aMap:Array = [];
		public var posMap:int = -1;
		public var undo:Boolean = false;

		public function SquirrelGameEditor():void
		{
			this.map = new GameMapEditor(this, this);
			this.squirrels = new SquirrelCollectionEditor();
			this.header = new EditorHeader(this);

			this.map.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			this.footer.addEventListener(MouseEvent.CLICK, onFooterClick, false, 0, true);

			this.footer.heroTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.heroBattleTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.heroTwoShamansTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.heroSurvivalTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.heroZombieTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.heroVolcanoTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.heroAllTape.addEventListener(EditNewElementEvent.NEW, onAddElement);

			this.footer.jointsTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.jointsAnomalTape.addEventListener(EditNewElementEvent.NEW, onAddElement);
			this.footer.jointsStormTape.addEventListener(EditNewElementEvent.NEW, onAddElement);

			for (var type:String in this.footer.tapesPlatforms)
				(this.footer.tapesPlatforms[type] as TapePlatform).addEventListener(EditNewElementEvent.NEW, onAddElement);

			for (type in this.footer.tapesObjects)
				(this.footer.tapesObjects[type] as TapeEdit).addEventListener(EditNewElementEvent.NEW, onAddElement);

			for (type in this.footer.tapesDecorations)
				(this.footer.tapesDecorations[type] as TapeEdit).addEventListener(EditNewElementEvent.NEW, onAddElement);

			for (type in this.footer.tapesFonts)
				(this.footer.tapesFonts[type] as TapeBackgrounds).addEventListener(NewBackgroundEvent.NAME, changeBackground);

			this.header.editorTestButton.addEventListener(MouseEvent.CLICK, onTest);
			this.header.editButton.addEventListener(MouseEvent.CLICK, onEdit);
			this.header.nextMapButton.addEventListener(MouseEvent.CLICK, onNextAndPrev);
			this.header.prevMapButton.addEventListener(MouseEvent.CLICK, onNextAndPrev);
			this.header.deleteMapButton.addEventListener(MouseEvent.CLICK, onDelete);
			this.header.editorSaveButton.addEventListener(MouseEvent.CLICK, onLocalSave);
			this.header.editorLoadButton.addEventListener(MouseEvent.CLICK, onLocalLoad);
			this.header.editorSendButton.addEventListener(MouseEvent.CLICK, onSave);
			this.header.editorApprove.addEventListener(MouseEvent.CLICK, onSave);
			this.header.undoEditorButton.addEventListener(MouseEvent.CLICK, onUndo);
			this.header.redoEditorButton.addEventListener(MouseEvent.CLICK, onRedo);
			this.header.rulesEditorButton.addEventListener(MouseEvent.CLICK, onRules);
			this.header.recordButton.addEventListener(MouseEvent.CLICK, onRecord);
			this.header.mapInfoButton.addEventListener(MouseEvent.CLICK, showMapInfo);
			this.header.objectsInspectorButton.addEventListener(MouseEvent.CLICK, showObjectsInspector);

			this.dialogConfig = new DialogEditorConfig(this);
			this.dialogObjectsInspector = new DialogObjectsInspector(this.map as GameMapEditor);

			initButtons();
			initDialogs();
			initTimers();

			togglePanels(false);

			super();

			this.scaleBar = new ScaleBar();
			this.scaleBar.x = 1;
			this.scaleBar.y = 34;
			this.scaleBar.visible = false;
			addChild(this.scaleBar);
			addChild(this.frameSprite);
			Game.gameSprite.addChild(this.footer);
			Game.gameSprite.addChild(this.header);

			var settings:Settings = new Settings();
			settings.x = 808;
			settings.scaleX = settings.scaleY = 1.1;
			settings.y = 1;
			settings.visible = true;
			this.header.addChild(settings);

			Connection.listen(onPacket, [PacketMapsMap.PACKET_ID, PacketMapsId.PACKET_ID]);
			Game.listen(onPlayerLoaded);
			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullscreen);
			onFullscreen();
		}

		private function onFullscreen(e: Event = null): void
		{
			this.header.x = Game.starling.stage.stageWidth / 2 - this.header.width / 2;
			this.footer.x = 0;
			this.footer.y = 0;
		}

		public function get mapNumber():int
		{
			return this.currentMap.number;
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			this.squirrels.dispose();
		}

		override public function dispose():void
		{
			if (this.footer.parent)
				this.footer.parent.removeChild(this.footer);

			if (this.header.parent)
				this.header.parent.removeChild(this.header);

			this.map.removeEventListener(MouseEvent.CLICK, onClick);
			this.footer.removeEventListener(MouseEvent.CLICK, onFooterClick);
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			super.dispose();

			this.currentMap = null;
			this.newMap = null;

			Connection.forget(onPacket, [PacketMapsMap.PACKET_ID, PacketMapsId.PACKET_ID]);
			Game.forget(onPlayerLoaded);

			this.dialogDelete.dispose();
			this.dialogCantSaveSimple.dispose();
			this.dialogCantSaveDragons.dispose();

			this.footer.dispose();
		}

		public function get isTest():Boolean
		{
			return this.isTesting;
		}

		public function get scale():Number
		{
			return this._scale;
		}

		public function set scale(value:Number):void
		{
			if (this._scale == value)
				return;

			if (value > 1 || value < 0.3)
				return;

			this._scale = value;

			this.squirrels.scaleX = this.squirrels.scaleY = value;
			this.shift = this.shift;
			(this.map as GameMapEditor).selection.clear();
		}

		public function openDialog():void
		{
			togglePanels(false);
			reset();
			DialogLocation.show();
			this.deleteFromDialog = false;
		}

		public function start():void
		{
			this.dialogConfig.show();

			this.mapInfo = this.map.serialize();
			this.isTesting = true;
			this.simulate = true;

			setSquirrels();
		}

		public function stop():void
		{
			this.isTesting = false;
			this.simulate = false;

			if (this.map.getSquirrelsCount() > 0)
			{
				this.squirrels.remove(Game.selfId);
				this.squirrels.hide();
			}

			this.squirrels.reset();
			this.map.deserialize(this.mapInfo);
		}

		public function onOpen(locationId:int, mapId:int, folderId:int, subLocationId:int):void
		{
			reset();

			this.header.editing = true;
			this.dialogMapInfo.editing = true;
			this.lastTestedMap.reset();
			this.isNewMap = false;
			this.map.clear();

			blockUndoRedo();

			this.header.editing = true;
			this.dialogMapInfo.hide();
			this.dialogMapInfo.editing = true;
			this.dialogMapInfo.updateListLocation();
			this.footer.onOpen(locationId, mapId);
			this.header.onOpen(locationId);
			ComboBoxUtil.selectValue(this.dialogMapInfo.folderComboBox, folderId);
			this.dialogMapInfo.changeFolder();
			ComboBoxUtil.selectValue(this.dialogMapInfo.locationComboBox, locationId);
			this.dialogMapInfo.changeHandler(null);
			this.currentMap.number = mapId;
			this.currentMap.location = locationId;
			this.currentMap.subLocation = subLocationId;

			var isLast:Boolean = (RangeMaps.last == mapId && !RangeMaps.isEmpty);
			var isFirst:Boolean = (RangeMaps.first == mapId && !RangeMaps.isEmpty);

			this.header.nextMapButton.enabled = this.header.nextMapButton.mouseEnabled = !isLast;
			this.header.nextMapButton.filters = isLast ? FiltersUtil.GREY_FILTER : [];

			this.header.prevMapButton.enabled = this.header.prevMapButton.mouseEnabled = !isFirst;
			this.header.prevMapButton.filters = isFirst ? FiltersUtil.GREY_FILTER : [];

			Connection.sendData(PacketClient.MAPS_GET, mapId);
			this.deleteFromDialog = false;
		}

		public function onNew(locationId:int = 0, modeId:int = 0, subId:int = 0):void
		{
			reset();
			clearMapData();
			blockUndoRedo();

			this.footer.onNew();
			this.header.onNew();

			this.deleteFromDialog = false;

			this.header.editing = false;
			this.dialogMapInfo.editing = false;
			this.dialogMapInfo.updateListLocation();
			this.lastTestedMap.reset();
			this.isNewMap = true;

			this.map.backgroundId = Backgrounds.SIMPLE;

			this.dialogMapInfo.setTime(ROUND_DEFAULT_START_TIME);
			this.dialogMapInfo.rating(0, 0, 0, 0, 0);

			this.header.numberField.text = String("");

			ComboBoxUtil.selectValue(this.dialogMapInfo.locationComboBox, locationId);
			this.dialogMapInfo.changeHandler(null);
			this.dialogMapInfo.mode = modeId;
			this.dialogMapInfo.sub = subId;
			this.dialogMapInfo.show();
			(this.map as GameMapEditor).setTapeShamaning(this.footer.currentShamaningTape);

			focusOnMap();
		}

		public function showDeleteDialog():void
		{
			this.dialogDelete.show();
		}

		public function onMouseDown(e:MouseEvent):void
		{
			this.dragLine = true;
			this.line = e.currentTarget;
			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		public function onMouseUp(e:MouseEvent):void
		{
			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.dragLine = false;
		}

		public function reset(resetShift:Boolean = true):void
		{
			this.isTesting = false;

			this.footer.reset();

			this.timer.stop();
			HeaderShort.clear();
			this.dialogObjectsInspector.removeAll();

			if (this.squirrels != null)
				this.squirrels.clear();

			if (this.map != null)
			{
				this.map.clear();
				(this.map as GameMapEditor).enabled = true;
				this.map.visible = true;
			}

			if (this.cast)
				this.cast.castObject = null;

			if (resetShift)
				this.shift = new Point(0, 0);

			clearHintArrows();
		}

		public function onFileLoaded(e:Event):void
		{
			try
			{
				this.myFileLoad.data.position = 0;
				this.newMap.map = this.myFileLoad.data.readUTF();
				this.newMap.time = this.myFileLoad.data.readInt();

				var lengthIds:int = this.myFileLoad.data.readInt();
				var shamanObjectsIds:Array = [];
				for (var i:int = 0; i < lengthIds; i++)
					shamanObjectsIds.push(this.myFileLoad.data.readInt());

				this.footer.loadShamaningTape(shamanObjectsIds);
				this.map.deserialize(this.newMap.map);

				this.dialogMapInfo.clearMapFields();
				this.dialogMapInfo.setTime(this.newMap.time);
				(this.map as GameMapEditor).selection.clear();
				this.shift = new Point(0, 0);
				if ((this.map as GameMapEditor).selection.handButton)
					this.header.onHand(null);
				this.aMap = [];
				this.posMap = -1;
				blockUndoRedo();
			}catch(error: Error)
			{
				Logger.add('SquirrelGameEditor->onFileLoaded: ' + error.message);
			}
		}

		public function saveStep():void
		{
			if (this.map.serialize() == this.aMap[posMap])
				return;

			this.header.undoEditorButton.enabled = true;
			this.header.undoEditorButton.mouseEnabled = true;
			this.header.undoEditorButton.filters = [];

			this.header.redoEditorButton.enabled = false;
			this.header.redoEditorButton.mouseEnabled = false;
			this.header.redoEditorButton.filters = FiltersUtil.GREY_FILTER;

			if (this.aMap.length > 9)
			{
				this.aMap = this.aMap.slice(1, this.posMap + 1);
				this.posMap --;
			}

			if (this.undo)
				this.aMap = this.aMap.slice(0, this.posMap + 1);

			this.undo = false;
			this.posMap ++;
			this.aMap[posMap] = this.map.serialize();
			this.localsaved = false;
		}

		public function showMapInfo(e:MouseEvent):void
		{
			this.dialogMapInfo.show();
		}

		public function showObjectsInspector(e:MouseEvent):void
		{
			this.dialogObjectsInspector.show();
		}

		public function onEdit(e:MouseEvent = null):void
		{
			this.footer.visible = true;

			this.dialogObjectsInspector.removeAll();
			this.dialogObjectsInspector.hide();

			FooterGame.hide();
			FooterGame.hero = null;
			FooterGame.removeListenerShaman(this.onShaman);

			if (this.isTesting)
				this.scale = this.currentScale;

			reset(false);

			this.isTesting = false;
			this.simulate = false;
			this.footer.visibleButtons(true);

			this.squirrels.clear();
			this.map.deserialize(this.mapInfo);
			(this.map as GameMapEditor).enabled = true;

			focusOnMap();
			this.map.drawVisibleObjects(true, true);
		}

		public function onTest(e:MouseEvent = null):void
		{
			this.dialogObjectsInspector.removeAll();
			this.dialogObjectsInspector.hide();

			ScreenEdit.allowedPerks = {};
			if (this.dialogMapInfo.visible)
				this.dialogMapInfo.hide();

			this.currentScale = this.scale;
			this.scale = 1;

			roundPosition();

			if (!this.isTesting)
				this.mapInfo = this.map.serialize();
			this.map.deserialize(this.mapInfo);
			(this.map as GameMapEditor).enabled = false;

			this.footer.visible = false;

			loadLastMapData(this.lastTestedMap);

			if ((this.lastTestedMap.mode == Locations.ROPED_MODE) && (this.dialogConfig.squirrelsCount < ROPED_SQUIRRELS_MIN))
				this.dialogConfig.squirrelsCount = ROPED_SQUIRRELS_MIN;

			if (this.cast)
			{
				this.cast.removeFromParent(true);
				this.cast.dispose();
			}

			this.cast = (DialogRecord.recorder.isRecording || DialogRecord.recorder.isReplay) ? new CastRecord(this) : new CastEditor(this);
			addChildStarling(this.cast);

			setSquirrels();

			FooterGame.show();
			FooterGame.listenShaman(this.onShaman);
			FooterGame.gameState = PacketServer.ROUND_START;

			this.isTesting = true;
			this.simulate = true;

			this.map.cachePool.cacheAsBitmap = true;

			this.footer.visibleButtons(false);
			this.timer.repeatCount = int(this.dialogMapInfo.minutes) * 60 + int(this.dialogMapInfo.seconds);
			this.timer.reset();
			this.timer.start();

			for (var i:int = 0; i < PerkFactory.PERK_TOOLBAR.length; i++)
			{
				if (PerkFactory.PERK_TOOLBAR[i] == PerkFactory.SKILL_RESURECTION)
					continue;
				scriptUtils.allowPerk(i, true, true);
			}
		}

		override public function get shift():Point
		{
			return super.shift;
		}

		override public function set shift(value:Point):void
		{
			super.shift = value;

			this.frameSprite.graphics.clear();
			this.frameSprite.graphics.lineStyle(2, 0x00C113);

			var i:int = 1;
			var mapWidth:Number = this.map.size.x * this.scale;
			var mapHeight:Number = this.map.size.y * this.scale;

			var startLine:int = 0;

			if (value.x < Config.GAME_WIDTH && value.x >= 0)
			{
				for (i = 1; i <= int((Config.GAME_WIDTH - value.x) / mapWidth); i++)
				{
					this.frameSprite.graphics.moveTo(value.x + (mapWidth * i), 0);
					this.frameSprite.graphics.lineTo(value.x + (mapWidth * i), Config.GAME_HEIGHT);
				}
			}
			else
				startLine = value.x >= 0 ? (int((value.x - Config.GAME_WIDTH) / mapWidth) + 1) : (Math.abs(int(value.x / mapWidth)) + 1);

			var endLine:int = value.x >= 0 ? int(value.x / mapWidth) + 1 : (int((Math.abs(value.x) + Config.GAME_WIDTH)/ mapWidth) + 1);

			for (i = startLine; i < endLine; i++)
			{
				this.frameSprite.graphics.moveTo(value.x + (value.x >= 0 ? -1 : 1) * (mapWidth * i), 0);
				this.frameSprite.graphics.lineTo(value.x + (value.x >= 0 ? -1 : 1) * (mapWidth * i), Config.GAME_HEIGHT);
			}

			if (value.y < Config.GAME_HEIGHT && value.y >= 0)
			{
				for (i = 1; i <= int((Config.GAME_HEIGHT - value.y) / mapHeight); i++)
				{
					this.frameSprite.graphics.moveTo(0, value.y + mapHeight * i);
					this.frameSprite.graphics.lineTo(Config.GAME_WIDTH, value.y + mapHeight * i);
				}
				startLine = 0;
			}
			else
				startLine = value.y >= 0 ? (int((value.y - Config.GAME_HEIGHT) / mapHeight) + 1) : (Math.abs(int(value.y / mapHeight)) + 1);

			endLine = value.y >= 0 ? int(value.y / mapHeight) + 1 : (int((Math.abs(value.y) + Config.GAME_HEIGHT)/ mapHeight) + 1);

			for (i = startLine; i < endLine; i++)
			{
				this.frameSprite.graphics.moveTo(0, value.y + (value.y >= 0 ? -1 : 1) * (mapHeight * i));
				this.frameSprite.graphics.lineTo(Config.GAME_WIDTH, value.y + (value.y >= 0 ? -1 : 1) * (mapHeight * i));
			}

			if (this.scaleBar.visible)
				this.showRule();
		}

		public function onExit(e:Event = null):void
		{
			if ((this.map as GameMapEditor).selection.handButton)
				this.header.onHand(null);
			if (this.isTesting)
				this.onEdit();

			(this.map as GameMapEditor).selection.clear();

			this.header.onEdit(null);
			loadLastMapData(this.newMap);

			this.aMap = [];
			this.posMap = -1;

			var changed:Boolean = false;
			if (this.header.editing)
				changed = !this.newMap.isEqual(this.currentMap);
			else
				changed = !this.map.isEmpty();

			if (changed && !this.localsaved)
			{
				if (this.dialogMapInfo.author == Game.selfId || Game.editor_access == PacketServer.EDITOR_FULL || Game.editor_access == PacketServer.EDITOR_SUPER || Game.editor_access == PacketServer.EDITOR_APPROVAL || !this.header.editing)
					this.dialogExit.show();
				else
					exit();

				block();
				return;
			}
			exit();
		}

		public function showRule():void
		{
			this.scaleBar.graphics.clear();
			this.scaleBar.graphics.beginBitmapFill(new RuleMarking(), new Matrix(1, 0, 0, 1, this.shift.x, 0), true, false);
			this.scaleBar.graphics.drawRect(15, 0, this.map.size.x, 15);

			this.scaleBar.graphics.beginBitmapFill(new RuleMarking(), new Matrix(0, 1, -1, 0, 0, this.shift.y+5), true, false);
			this.scaleBar.graphics.drawRect(0, 15, 15, this.map.size.y);

			var i:int = 0;
			var format:TextFormat = new TextFormat(null, 10, 0xFFFFFF);
			var field:TextField = new TextField();
			field.width = 100;
			field.defaultTextFormat = format;
			if (this.shiftRuleX != int(this.shift.x / 40))
			{
				this.shiftRuleX = int(this.shift.x / 40);
				this.ruleBarX = new BitmapData(Config.GAME_WIDTH + interval, 15, true, 0x00FFFFFF);

				for (i = 0; i < Config.GAME_WIDTH + this.interval; i += this.interval)
				{
					this.stringX = String(i -(int(this.shift.x / 40) * this.interval));
					field.text = this.stringX;
					this.ruleBarX.draw(field, new Matrix(1, 0, 0, 1, i, 0));
				}
			}

			if (this.shiftRuleY != int(this.shift.y / 40))
			{
				this.shiftRuleY = int(this.shift.y / 40);
				this.ruleBarY = new BitmapData(Config.GAME_HEIGHT + interval, 15, true, 0x00FFFFFF);

				for (i = 0; i < Config.GAME_HEIGHT + this.interval; i += this.interval)
				{
					this.stringY = String(i -(int(this.shift.y / 40) * this.interval));
					field.text = this.stringY;
					this.ruleBarY.draw(field, new Matrix(1, 0, 0, 1, i, 0));
				}
			}

			this.scaleBar.graphics.beginBitmapFill(this.ruleBarX, new Matrix(1, 0, 0, 1, this.shift.x - int(this.shift.x / 40) * this.interval, -3), true, false);
			this.scaleBar.graphics.drawRect(15, 0, Config.GAME_WIDTH, 15);
			this.scaleBar.graphics.beginBitmapFill(this.ruleBarY, new Matrix(0, 1, -1, 0, 0, this.shift.y - 33 - int(this.shift.y / 40) * this.interval), true, false);
			this.scaleBar.graphics.drawRect(0, 15, 15, Config.GAME_HEIGHT);
		}

		public function onFileSaved(e:Event):void
		{
			this.localsaved = true;
			this.aMap = [];
			this.posMap = -1;
			blockUndoRedo();
		}

		private function onMouseMove(e:MouseEvent):void
		{
			if (!this.dragLine)
				return;

			if (this.line.width > 5)
				this.line.y = e.stageY - this.scaleBar.y;
			else
				this.line.x = e.stageX;
		}

		private function onRules(e:MouseEvent):void
		{
			!this.scaleBar.visible ? this.scaleBar.visible = true : this.scaleBar.visible = false;
		}

		private function onRecord(e:MouseEvent):void
		{
			DialogRecord.show(this);
		}

		private function onNextAndPrev(e:MouseEvent):void
		{
			this.shift = new Point(0, 0);
			if (e!= null)
			{
				if (e.currentTarget is ButtonNextMap)
					this.flagNextAndPrev = "Next";
				else if (e.currentTarget is ButtonPrevMap)
					this.flagNextAndPrev = "Prev";
			}

			if (!DialogLocation.checkMap(this.currentMap.number, this.flagNextAndPrev))
			{
				this.flagNextAndPrev = "";
				return;
			}
			onExit();
		}

		private function checkPressButton():Boolean
		{
			if (this.flagNextAndPrev == "")
				return false;

			switch (this.flagNextAndPrev)
			{
				case "Next":
					DialogLocation.loadNextMap(this.currentMap.number);
					break;
				case "Prev":
					DialogLocation.loadPrevMap(this.currentMap.number);
					break;
			}

			this.flagNextAndPrev = "";
			return true;
		}

		private function showFAQ(e:MouseEvent):void
		{

		}

		private function clearMapData():void
		{
			this.currentMap.reset();

			this.dialogMapInfo.clearMapFields();
		}

		private function onFooterClick(e:MouseEvent):void
		{
			if (this.map == null)
				return;

			(this.map as GameMapEditor).selection.clear();
		}

		private function onClick(e:MouseEvent):void
		{
			focusOnMap();
		}

		private function setSquirrels():void
		{
			this.squirrels.clear();

			var countSquirrels:int = this.map.getSquirrelsCount();
			if (countSquirrels <= 0 || this.dialogConfig.squirrelsCount <= 0)
				return;

			for (var i:int = 0; i < this.dialogConfig.squirrelsCount; i++) {
				this.squirrels.add(-i - 1);
			}

			this.squirrels.reset();

			if (this.lastTestedMap.mode == Locations.DRAGON_MODE)
				this.squirrels.setDragons(this.squirrels.getIds());
			else
			{
				var id:int = -1;

				if (this.map.has(ShamanBody))
				{
					this.squirrels.get(id).position = this.map.get(ShamanBody)[0].position;
					this.squirrels.setShamans(new <int>[id--]);
				}
				if (this.map.has(RedShamanBody))
				{
					this.squirrels.get(id).team = Hero.TEAM_RED;
					this.squirrels.get(id).position = this.map.get(RedShamanBody)[0].position;
					this.squirrels.setShamans(new <int>[id--] , false);
				}
				if (this.map.has(BlackShamanBody))
				{
					this.squirrels.get(id).team = Hero.TEAM_BLACK;
					this.squirrels.get(id).position = this.map.get(BlackShamanBody)[0].position;
					this.squirrels.setShamans(new <int>[id--]);
				}

				if (this.dialogConfig.addHare && this.dialogConfig.squirrelsCount > 0)
					this.squirrels.setHares(new <int>[id--]);
			}

			if (this.lastTestedMap.mode != Locations.ROPED_MODE && this.lastTestedMap.mode != Locations.SNAKE_MODE)
				this.squirrels.place();
			else
				(this.squirrels as SquirrelCollectionEditor).placeRoped(this.lastTestedMap.mode == Locations.SNAKE_MODE);

			this.squirrels.show();

			(this.squirrels as SquirrelCollectionEditor).next();
		}

		private function loadLastMapData(mapData:MapData):void
		{
			mapData.time = getSeconds();

			(this.map as GameMapEditor).setTapeShamaning(this.footer.currentShamaningTape);

			if (this.isTesting)
				mapData.map = this.lastTestedMap.map;
			else
			{
				mapData.map = this.map.serialize();
				this.map.lastEditor = Game.selfId;
			}

			mapData.location = this.dialogMapInfo.locationComboBox.selectedItem['value'];
			mapData.mode = this.dialogMapInfo.mode;
			mapData.subLocation = this.dialogMapInfo.sub;
			mapData.number = this.currentMap.number;
			mapData.authorId = this.currentMap.authorId;

			if (!Game.editor_access)
				mapData.location = Locations.NONAME_ID;

			if (!this.isNewMap)
				mapData.number = this.currentMap.number;
		}

		private function roundPosition():void
		{
			var objects:Array = this.map.get(IGameObject);
			for each (var object:DisplayObject in objects)
			{
				object.x = Math.round(object.x);
				object.y = Math.round(object.y);
			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.S && e.ctrlKey)
				this.dialogConfig.show();

			if (e.keyCode == Keyboard.M && e.ctrlKey)
				Logger.add("MAP trace:", this.map.serialize());

			if (e.keyCode == Keyboard.Q && e.ctrlKey && e.altKey && Game.editor_access != PacketServer.EDITOR_NONE)
				this.dialogObjectsInspector.show();

			if (Game.stage.focus != this.map && Game.stage.focus != this.dialogMapInfo)
				return;

			switch (e.keyCode)
			{
				case Keyboard.NUMPAD_ADD:
					if (this.header.mapInfoButton.enabled && !e.ctrlKey)
					{
						if (this.dialogMapInfo.visible)
							this.dialogMapInfo.hide();
						else
							this.dialogMapInfo.show();
					}
					break;
				case Keyboard.NUMPAD_4:
					if (this.header.prevMapButton.enabled)
					{
						this.flagNextAndPrev = "Prev";
						onNextAndPrev(null);
					}
					break;
				case Keyboard.NUMPAD_6:
					if (this.header.nextMapButton.enabled)
					{
						this.flagNextAndPrev = "Next";
						onNextAndPrev(null);
					}
					break;
				case Keyboard.NUMPAD_DECIMAL:
					if (this.header.deleteMapButton.enabled && Game.editor_access > 0)
						onDelete(null);
					break;
				case Keyboard.ENTER:
					if (!this.dialogDelete.visible || Game.editor_access == PacketServer.EDITOR_NONE)
						return;
					onConfirmDelete();
					this.dialogDelete.hide();
					break;
			}
		}

		private function changeBackground(e:NewBackgroundEvent):void
		{
			this.map.backgroundId = e.id;
		}

		private function onShaman(e:ShamanEvent):void
		{
			if (!this.isTesting)
				return;

			this.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, e.className));
		}

		private function onAddElement(e:EditNewElementEvent):void
		{
			var id:int = EntityFactory.getId(e.className);
			(this.map as GameMapEditor).createObject(id);

			focusOnMap();
			saveStep();
		}

		private function focusOnMap():void
		{
			Game.stage.focus = this.map;
		}

		private function block():void
		{
			togglePanels(false);
			this.simulate = false;
			(this.map as GameMapEditor).enabled = false;
		}

		private function unBlock():void
		{
			this.mapInfo = this.map.serialize();

			togglePanels(true);
			this.squirrels.clear();
			this.map.deserialize(this.mapInfo);
			(this.map as GameMapEditor).enabled = !this.isTesting;
			this.simulate = this.isTesting;

			this.footer.heroTape.visible = true;
			this.footer.jointsTape.visible = true;
			this.footer.currentShamaningTape.visible = true;

			if (this.isTesting)
				setSquirrels();
		}

		private function exit():void
		{
			if (checkPressButton())
				return;

			this.currentMap.number = -1;

			if (!Game.editor_access)
			{
				Screens.show("Location");
				return;
			}

			this.squirrels.clear();
			this.map.clear();

			if (DialogLocation.isShowing())
			{
				Screens.show("Location");
				return;
			}

			openDialog();

			DialogLocation.show();

			reset();
			togglePanels(false);
		}

		private function onSave(e:Event = null):Boolean
		{
			loadLastMapData(this.newMap);

			if (!Game.editor_access && !this.lastTestedMap.isEqual(this.newMap))
			{
				this.dialogNeedTest.show();
				return false;
			}

			var currentLocation:int = this.dialogMapInfo.locationComboBox.selectedItem['value'];

			if (currentLocation != Locations.APPROVED_ID && currentLocation != Locations.NONAME_ID && !(map as GameMapEditor).isValid(currentLocation, this.dialogMapInfo.mode))
			{
				showSaveWarning();
				return false;
			}

			if (currentLocation != Locations.SCHOOL_ID && currentLocation != Locations.APPROVED_ID && currentLocation != Locations.NONAME_ID && !(map as GameMapEditor).isValid2(currentLocation, this.dialogMapInfo.mode))
			{
				showSaveWarning2();
				return false;
			}

			var seconds:int = getSeconds();
			if (seconds < Game.ROUND_MIN_TIME)
			{
				showSaveWarning();
				return false;
			}

			if (!this.isNewMap && Game.editor_access == PacketServer.EDITOR_SUPER && (this.newMap.location != this.currentMap.location) && (Locations.getLocation(this.currentMap.location).game || this.currentMap.location == Locations.SCHOOL_ID))
			{
				this.dialogCantSave.show();
				return false;
			}

			save();
			return true;
		}

		private function saveToContest(e:Event = null):Boolean
		{
			loadLastMapData(this.newMap);

			if (!Game.editor_access && !this.lastTestedMap.isEqual(this.newMap))
			{
				this.dialogNeedTest.show();
				return false;
			}

			if (this.dialogMapInfo.locationComboBox.selectedItem['value'] != Locations.BATTLE_ID)
			{
				this.dialogCantSaveBattleContest.show();
				return false;
			}

			if (!(map as GameMapEditor).isValid(this.dialogMapInfo.locationComboBox.selectedItem['value']))
			{
				showSaveWarning();
				return false;
			}

			var seconds:int = getSeconds();
			if (seconds < Game.ROUND_MIN_TIME)
			{
				showSaveWarning();
				return false;
			}

			onConfirmSaveToContest();
			return true;
		}

		private function save():void
		{
			if (this.dialogDelete)
				this.dialogDelete.hide();

			if (this.header.menuForModerApprove)
			{
				if (this.currentMap.location == Locations.NONAME_ID)
					this.newMap.copy(this.currentMap);
				this.newMap.location = Locations.APPROVED_ID;
			}

			if (this.header.editing)
			{
				if (this.header.menuForModerApprove || this.newMap.location != this.currentMap.location || this.newMap.mode != this.currentMap.mode || this.newMap.subLocation != this.currentMap.subLocation)
				{
					DialogLocation.removeFromList(this.currentMap.location, this.currentMap.number);
					DialogLocation.addMap(this.currentMap.number, this.newMap.location, this.newMap.mode, this.currentMap.authorId, this.newMap.subLocation);
				}

				Connection.sendData(PacketClient.MAPS_EDIT, this.currentMap.number, (DialogMapInfo.folder == Locations.PRE_RELEASE_FOLDER_ID) ? Locations.PRE_RELEASE_ID : this.newMap.location, this.newMap.subLocation, this.newMap.mode, this.newMap.location, this.newMap.time, StringUtil.MapLength(this.newMap.map), StringUtil.MapToByteArray(this.newMap.map));
				this.isNewMap = false;
				if (!this.header.menuForModerApprove)
				{
					this.currentMap.copy(this.newMap);
					this.mapInfo = this.newMap.map;
				}

				if (this.header.menuForModerApprove || Game.editor_access == PacketServer.EDITOR_APPROVAL && !this.dialogExit.visible) {
					if (DialogLocation.lengthList <= 0)
					{
						reset();
					}
					else
					{
						DialogLocation.loadMapNext();
					}
					return;
				}

				if (Game.editor_access == PacketServer.EDITOR_SUPER && !this.dialogExit.visible)
					this.header.onOpen(this.newMap.location);
				return;
			}

			if (!Game.editor_access || Game.editor_access == PacketServer.EDITOR_APPROVAL || Game.editor_access == PacketServer.EDITOR_APPROVAL_PLUS)
			{
				this.dialogSave.show();
				this.footer.visible = false;
				this.header.visible = false;
				(this.map as GameMapEditor).enabled = false;
				return;
			}

			Connection.sendData(PacketClient.MAPS_ADD, (this.newMap.mode == Locations.SNAKE_MODE) ? Locations.ROPED_MODE : this.newMap.mode, this.newMap.time, StringUtil.MapLength(this.newMap.map), StringUtil.MapToByteArray(this.newMap.map), this.newMap.location, this.newMap.subLocation);

			this.isNewMap = false;
			this.currentMap.copy(this.newMap);
			this.mapInfo = this.newMap.map;
			this.header.editing = true;
			this.dialogMapInfo.editing = true;
			if (Game.editor_access == PacketServer.EDITOR_SUPER && !this.dialogExit.visible)
				this.header.onOpen(this.newMap.location);
		}

		private function onLocalSave(e:Event = null):Boolean
		{
			FullScreenManager.instance().fullScreen = false;

			loadLastMapData(this.newMap);

			var shamanObjectsIds:Array = this.footer.currentShamaningTape.getIds();
			var data:ByteArray = new ByteArray();
			data.position = 0;

			data.writeUTF(this.newMap.map);
			data.writeInt(this.newMap.time);
			data.writeInt(shamanObjectsIds.length);

			for (var i:int = 0; i < shamanObjectsIds.length; i++)
				data.writeInt(shamanObjectsIds[i]);
			try
			{
				this.myFileReference.save(data, "round.map");
				this.myFileReference.addEventListener(Event.COMPLETE, onFileSaved);
			}
			catch (error: Error)
			{
				Logger.add("SquirrelGameEditor->onLocalSave: " + error.message);
			}

			return true;
		}

		private function onLocalLoad(e:Event = null):Boolean
		{
			FullScreenManager.instance().fullScreen = false;
			try
			{
				this.myFileLoad.browse();
				this.myFileLoad.addEventListener(Event.SELECT, onFileSelected);
			}catch(error: Error)
			{
				Logger.add('SquirrelGameEditor->onLocalLoad:' + error.message);
			}

			return true;
		}

		private function onFileSelected(e:Event):void
		{
			this.openBrowse = false;
			this.myFileLoad.load();
			this.myFileLoad.addEventListener(Event.COMPLETE, onFileLoaded);
		}

		private function onUndo(e:MouseEvent = null):void
		{
			if (this.posMap <= -1)
				return;

			this.undo = true;
			if (posMap == this.aMap.length - 1)
				this.aMap[posMap + 1] = this.map.serialize();

			this.posMap--;
			blockUndoRedo();
			this.map.deserialize(this.aMap[posMap + 1]);
			(this.map as GameMapEditor).selection.clear();
		}

		private function onRedo(e:MouseEvent = null):void
		{
			if (this.posMap >= this.aMap.length - 2)
				return;

			this.posMap++;
			this.map.deserialize(this.aMap[posMap + 1]);
			blockUndoRedo();
			(this.map as GameMapEditor).selection.clear();
		}

		private function blockUndoRedo():void
		{
			if (this.posMap == -1 && this.aMap.length == 0)
			{
				this.header.redoEditorButton.enabled = false;
				this.header.redoEditorButton.mouseEnabled = false;
				this.header.redoEditorButton.filters = FiltersUtil.GREY_FILTER;

				this.header.undoEditorButton.enabled = false;
				this.header.undoEditorButton.mouseEnabled = false;
				this.header.undoEditorButton.filters = FiltersUtil.GREY_FILTER;
				return;
			}

			if (this.posMap < 0)
			{
				this.header.undoEditorButton.enabled = false;
				this.header.undoEditorButton.mouseEnabled = false;
				this.header.undoEditorButton.filters = FiltersUtil.GREY_FILTER;
			}
			else
			{
				this.header.undoEditorButton.enabled = true;
				this.header.undoEditorButton.mouseEnabled = true;
				this.header.undoEditorButton.filters = [];
			}

			if (this.posMap < this.aMap.length -2)
			{
				this.header.redoEditorButton.enabled = true;
				this.header.redoEditorButton.mouseEnabled = true;
				this.header.redoEditorButton.filters = [];
			}
			else
			{
				this.header.redoEditorButton.enabled = false;
				this.header.redoEditorButton.mouseEnabled = false;
				this.header.redoEditorButton.filters = FiltersUtil.GREY_FILTER;
			}

			if (posMap > 0)
			{
				this.header.undoEditorButton.enabled = true;
				this.header.undoEditorButton.mouseEnabled = true;
				this.header.undoEditorButton.filters = [];
			}
		}

		private function togglePanels(value:Boolean):void
		{
			this.header.visible = value;
			this.footer.visible = value;
		}

		private function onConfirmDelete():void
		{
			if (!this.deleteFromDialog)
			{
				DialogLocation.deleteSelectedMap();
				togglePanels(false);
				DialogLocation.show();
				return;
			}

			DialogLocation.deleteMap(this.currentMap.location, this.currentMap.number);
			reset();
			togglePanels(false);
			this.map.drawVisibleObjects(true, true);
		}

		private function onTick(e:TimerEvent):void
		{
			HeaderShort.updateTimer(this.timer.repeatCount - int(e.currentTarget.currentCount));
		}

		private function onTimerComplete(e:TimerEvent):void
		{
			onEdit();
			this.header.onEdit(null);
		}

		private function onDelete(e:MouseEvent):void
		{
			this.deleteFromDialog = true;
			this.dialogDelete.show();
		}

		private function getSeconds():int
		{
			return this.dialogMapInfo.seconds + this.dialogMapInfo.minutes * 60;
		}

		private function initTimers():void
		{
			this.timer.addEventListener(TimerEvent.TIMER, onTick, false, 0, true);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete, false, 0, true);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			if (this.currentMap.authorId == -1 && this.map.lastEditor == 0)
				return;

			var player:Player = e.player;
			if (player.id == this.currentMap.authorId)
				this.dialogMapInfo.author = player.id;

			if (player.id == this.map.lastEditor)
				this.dialogMapInfo.editor = player.id;
		}

		private function initButtons():void
		{
			var buttonExit:ButtonBase = new ButtonBase(gls("Выход"));
			buttonExit.scaleX = buttonExit.scaleY = 0.65;
			buttonExit.x = 840;
			buttonExit.y = Config.GAME_HEIGHT - 613;
			buttonExit.addEventListener(MouseEvent.CLICK, onExit, false, 0, true);
			this.header.addChild(buttonExit);
		}

		private function initDialogs():void
		{
			this.dialogDelete = new DialogInfo(gls("Удаление карты"), gls("Ты уверен, что хочешь удалить карту?"), true, onConfirmDelete, 0, null, false);

			this.dialogCantSaveSimple = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте должны присутствовать\nорех, обычное дупло, белка и шаман."), false, null, 0, null, false);
			this.dialogCantSaveSimple2 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте не должны присутствовать\nобъекты битвы и других режимов игры."), false, null, 0, null, false);

			this.dialogCantSaveBattle = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте должны присутствовать\nядро, белка и шаман для каждой команды."), false, null, 0, null, false);
			this.dialogCantSaveBattle2 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте не должны присутствовать\nобъекты других режимов игры,\nорех и дупло."), false, null, 0, null, false);
			this.dialogCantSaveBattleContest = new DialogInfo(gls("Отправить карту"), gls("Конкурс карт проводится\nтолько для карт режима Битва."), false, null, 0, null, false);

			this.dialogCantSaveDragons = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте должны присутствовать\nорех, дупло и белка."), false, null, 0, null, false);
			this.dialogCantSaveDragons2 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте не должны присутствовать\nшаман, объекты битвы и других\nрежимов игры."), false, null, 0, null, false);

			this.dialogCantSaveRoped2 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте не должны присутствовать\nобъекты битвы и других режимов,\nа количество белок не должно превышать 2.\nРасстояние между белками\nдолжно быть небольшим."), false, null, 0, null, false);

			this.dialogCantSaveTwoShamans = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте должны присутствовать\nорех, белка, одно красное и одно\nсинее дупло, красный и синий шаман."), false, null, 0, null, false);
			this.dialogCantSaveTwoShamans2 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте не должны присутствовать\nобъекты битвы и других режимов игры."), false, null, 0, null, false);

			this.dialogCantSaveSurvival = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте должны присутствовать\nбелка и чёрный шаман."), false, null, 0, null, false);
			this.dialogCantSaveSurvival2 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте не должны присутствовать\nорех, дупло, объекты битвы и других\nрежимов игры."), false, null, 0, null, false);

			this.dialogCantSaveFlyAcorn1 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. на карте должны присутствовать\nорех, дупло и маршрут полета ореха"), false, null, 0, null, false);
			this.dialogCantSaveFlyAcorn2 = new DialogInfo(gls("Cохранить карту"), gls("Сохранить карту нельзя,\nт.к. у вас есть точка маршрута и к ней ничего не привязано"), false, null, 0, null, false);

			this.dialogSave = new DialogSaveMap(onCancelSave, onConfirmSave);
			this.dialogNeedTest = new DialogInfo(gls("Сохранение карты"), gls("Протестируйте карту перед отправкой"));
			this.dialogExit = new DialogExit(onConfirmSaveInExit, exit, onCancelExit);

			this.dialogCantSave = new DialogInfo(gls("Сохранить карту"), gls("У тебя недостаточно прав для сохранения этой карты в другой локации."));
		}

		private function showSaveWarning():void
		{
			switch (this.dialogMapInfo.mode)
			{
				case Locations.DRAGON_MODE:
					this.dialogCantSaveDragons.show();
					return;
				case Locations.TWO_SHAMANS_MODE:
					this.dialogCantSaveTwoShamans.show();
					return;
				case Locations.BLACK_SHAMAN_MODE:
					this.dialogCantSaveSurvival.show();
					return;
				case Locations.FLY_NUT_MODE:
					this.dialogCantSaveFlyAcorn1.show();
					return;
			}

			if (this.dialogMapInfo.locationComboBox.selectedItem['value'] == Locations.BATTLE_ID)
			{
				this.dialogCantSaveBattle.show();
				return;
			}

			this.dialogCantSaveSimple.show();
		}

		private function showSaveWarning2():void
		{
			switch (this.dialogMapInfo.mode)
			{
				case Locations.DRAGON_MODE:
					this.dialogCantSaveDragons2.show();
					return;
				case Locations.TWO_SHAMANS_MODE:
					this.dialogCantSaveTwoShamans2.show();
					return;
				case Locations.ROPED_MODE:
					this.dialogCantSaveRoped2.show();
					return;
				case Locations.BLACK_SHAMAN_MODE:
					this.dialogCantSaveSurvival2.show();
					return;
				case Locations.FLY_NUT_MODE:
					this.dialogCantSaveFlyAcorn2.show();
					return;
			}

			if (this.dialogMapInfo.locationComboBox.selectedItem['value'] == Locations.BATTLE_ID)
			{
				this.dialogCantSaveBattle2.show();
				return;
			}

			this.dialogCantSaveSimple2.show();
		}

		private function onConfirmSaveInExit():void
		{
			if (this.isTesting)
				onEdit();

			if (!onSave())
			{
				unBlock();
				return;
			}

			switch (Game.editor_access)
			{
				case PacketServer.EDITOR_APPROVAL:
					if (this.header.editing)
						openDialog();
					// FIXME: Falling down???
				case PacketServer.EDITOR_NONE:
					this.dialogExit.hide();
					return;
			}

			if (checkPressButton())
				return;

			openDialog();
		}

		private function onCancelExit():void
		{
			unBlock();
		}

		private function onCancelSave():void
		{
			this.footer.visible = true;
			this.header.visible = true;

			if (this.map == null)
				return;

			(this.map as GameMapEditor).enabled = true;
		}

		private function onConfirmSave():void
		{
			Connection.sendData(PacketClient.MAPS_ADD, (this.newMap.mode == Locations.SNAKE_MODE) ? Locations.ROPED_MODE : this.newMap.mode, this.newMap.time, StringUtil.MapLength(this.newMap.map), StringUtil.MapToByteArray(this.newMap.map));

			if (Game.editor_access != PacketServer.EDITOR_APPROVAL && Game.editor_access != PacketServer.EDITOR_APPROVAL_PLUS)
				DialogLocation.addMap(int(this.newMap.map), this.newMap.location, this.newMap.mode, Game.selfId, this.newMap.subLocation);

			if (Game.editor_access == PacketServer.EDITOR_APPROVAL || Game.editor_access == PacketServer.EDITOR_APPROVAL_PLUS)
			{
				this.footer.visible = false;
				this.header.visible = false;
				exit();
				return;
			}

			Screens.show("Location");
		}

		private function onConfirmSaveToContest():void
		{
			Connection.sendData(PacketClient.MAPS_ADD, (this.newMap.mode == Locations.SNAKE_MODE) ? Locations.ROPED_MODE : this.newMap.mode, this.newMap.time, StringUtil.MapLength(this.newMap.map), StringUtil.MapToByteArray(this.newMap.map), Locations.TENDER, 0);
			this.footer.visible = false;
			this.header.visible = false;
			exit();
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketMapsMap.PACKET_ID:
					var maps: PacketMapsMap = packet as PacketMapsMap;

					if (this.currentMap.number != maps.id)
						return;

					this.currentMap.load(maps);
					this.mapInfo = this.currentMap.map;

					this.dialogMapInfo.setTime(this.currentMap.time);
					this.dialogMapInfo.map = this.currentMap.number;
					this.dialogMapInfo.mode = this.currentMap.mode;
					this.dialogMapInfo.sub = this.currentMap.subLocation;
					this.dialogMapInfo.rating(this.currentMap.positiveVotes, this.currentMap.negativeVotes, this.currentMap.exitVotes, this.currentMap.exitDeads, this.currentMap.playsCount);
					this.header.numberField.htmlText = "<a href='event:#'>" + String(this.currentMap.number) + "</a>";

					reset();

					this.isTesting = false;
					this.simulate = false;

					this.squirrels.clear();
					this.map.deserialize(this.mapInfo);
					this.footer.onReloadMap(this.map.shamanTools);
					(this.map as GameMapEditor).setTapeShamaning(this.footer.currentShamaningTape);
					this.header.visible = true;

					(this.map as GameMapEditor).enabled = true;

					if (this.map.lastEditor == 0)
					{
						this.dialogMapInfo.editor = 0;
						Game.request(this.currentMap.authorId, PlayerInfoParser.NAME);
					}
					else
						Game.request([this.currentMap.authorId, this.map.lastEditor], PlayerInfoParser.NAME);

					focusOnMap();
					break;
				case PacketMapsId.PACKET_ID:
					var mapsId: PacketMapsId = packet as PacketMapsId;

					this.currentMap.number = mapsId.id;
					this.currentMap.subLocation = mapsId.sublocationId;

					if (this.currentMap.number == 0)
					{
						Logger.add("Error wrong number of map");
						return;
					}

					DialogLocation.addMap(this.currentMap.number, this.newMap.location, this.newMap.mode, Game.selfId, this.newMap.subLocation);

					this.dialogMapInfo.map = this.currentMap.number;
					this.header.numberField.htmlText = "<a href='event:#'>" + String(this.currentMap.number) + "</a>";
					this.dialogMapInfo.author = Game.selfId;
					break;
			}
		}
	}
}