package dialogs
{
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.controls.ComboBox;
	import fl.controls.List;
	import fl.data.DataProvider;

	import game.mainGame.SquirrelGame;
	import game.mainGame.gameEditor.RangeMaps;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketMapsList;
	import protocol.packages.server.structs.PacketMapsListMaps;

	import utils.ComboBoxUtil;
	import utils.EditField;

	public class DialogLocation extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				color: #000000;
			}
			.number {
				font-weight: bold;
				text-decoration: none;
				font-size: 12px;
			}
			.number:hover {
				text-decoration: underline;
				font-size: 12px;
			}
			.newMap {
				color: #d72e00;
				text-decoration: underline;
				font-size: 11px;
			}
			.link {
				color: #000000;
				text-decoration: underline;
				font-size: 11px;
			}
			.record {
				font-size: 12px;
			}
			.record:hover {
				text-decoration: underline;
			}
		]]>).toString();

		static private const OFFSET_X:int = 10;

		static private var _instance:DialogLocation;

		private var folderComboBox:ComboBox = new ComboBox();
		private var comboBox:ComboBox = new ComboBox();
		private var modeComboBox:ComboBox = new ComboBox();
		private var subComboBox:ComboBox = new ComboBox();

		private var list:List = new List();

		private var selfClose:Boolean = false;

		private var currentItems:Object = {};
		private var allItems:Object = {};

		private var locationId:int = 0;
		private var modeId:int = 0;
		private var subId:int = 0;
		private var folderId:int = 0;

		private var loaded:Boolean = false;

		private var mapsCount:GameField = null;
		private var findField:EditField = null;
		private var totalCountField:GameField = null;
		private var deleteLink:GameField = null;
		private var newLink:GameField = null;
		private var releaseLink:GameField = null;
		private var goToLink:GameField = null;
		private var editLink:GameField = null;

		private var modersButton:SimpleButton = null;
		private var lagsLink:GameField = null;
		private var invisibleLink:GameField = null;

		private var dialogNotFound:DialogInfo = new DialogInfo(" ", gls("Карты с таким номером не существует."), false, null, 265);

		private var startIndexField:EditField;
		private var endIndexField:EditField;

		public function DialogLocation():void
		{
			_instance = this;

			super();

			var format:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 10, 0x000000);

			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.folderComboBox.x = OFFSET_X;
			this.folderComboBox.y = 0;
			this.folderComboBox.width = 130;
			this.folderComboBox.height = 17;
			this.folderComboBox.addEventListener(Event.CHANGE, onChangeFolder);
			this.folderComboBox.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.folderComboBox.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.folderComboBox.addItem({'label': gls("Релиз"), 'value': Locations.RELEASE_FOLDER_ID});
			this.folderComboBox.addItem({'label': gls("Готовы к релизу"), 'value': Locations.PRE_RELEASE_FOLDER_ID});
			this.folderComboBox.selectedIndex = 0;
			ComboBoxUtil.style(this.folderComboBox, format, format);
			addChild(this.folderComboBox);

			this.comboBox.x = OFFSET_X;
			this.comboBox.y = 22;
			this.comboBox.width = 130;
			this.comboBox.height = 17;
			this.comboBox.addEventListener(Event.CHANGE, onChangeLocation);
			this.comboBox.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.comboBox.addEventListener(MouseEvent.ROLL_OVER, onOver);
			ComboBoxUtil.style(this.comboBox, format, format);
			addChild(this.comboBox);

			this.subComboBox.x = OFFSET_X;
			this.subComboBox.y = 44;
			this.subComboBox.width = 130;
			this.subComboBox.height = 17;
			this.subComboBox.addEventListener(Event.CHANGE, onChangeSub);
			this.subComboBox.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.subComboBox.addEventListener(MouseEvent.ROLL_OVER, onOver);
			ComboBoxUtil.style(this.subComboBox, format, format);
			addChild(this.subComboBox);

			this.modeComboBox.x = OFFSET_X;
			this.modeComboBox.y = 68;
			this.modeComboBox.width = 130;
			this.modeComboBox.height = 17;
			this.modeComboBox.addEventListener(Event.CHANGE, onChangeMode);
			this.modeComboBox.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.modeComboBox.addEventListener(MouseEvent.ROLL_OVER, onOver);
			ComboBoxUtil.style(this.modeComboBox, format, format);
			addChild(this.modeComboBox);

			var backgroundList:ListSkin = new ListSkin();
			backgroundList.x = OFFSET_X;
			backgroundList.y = 93;
			backgroundList.height -= 50;
			addChild(backgroundList);

			this.list.x = OFFSET_X;
			this.list.y = 93;
			this.list.setSize(197, 110);
			this.list.rowHeight = 13;
			this.list.allowMultipleSelection = true;
			this.list.setStyle("cellRenderer", ListStyleRendererLocation);
			this.list.addEventListener(MouseEvent.CLICK, onChangeList);
			addChild(this.list);

			var editFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 11, 0x3A2506);

			var rangeField:GameField = new GameField(gls("<body>Диапазон</body>"), OFFSET_X + 55, backgroundList.y + backgroundList.height + 5, style);
			addChild(rangeField);

			this.startIndexField = new EditField("", OFFSET_X + 20, rangeField.y + rangeField.height + 5, 50, 15, editFormat);
			this.startIndexField.background = false;
			this.startIndexField.restrict = "0-9";
			this.startIndexField.addEventListener(Event.CHANGE, onChangeRange);
			addChild(startIndexField);

			this.endIndexField = new EditField("", OFFSET_X + 100, this.startIndexField.y, 50, 15, editFormat);
			this.endIndexField.background = false;
			this.endIndexField.restrict = "0-9";
			this.endIndexField.addEventListener(Event.CHANGE, onChangeRange);
			addChild(endIndexField);

			var startLabelIndex:GameField = new GameField(gls("<body>От</body>"), OFFSET_X, this.startIndexField.y, style);
			addChild(startLabelIndex);

			var endLabelIndex:GameField = new GameField(gls("<body>до</body>"), this.startIndexField.x + this.startIndexField.width + 10, this.startIndexField.y, style);
			addChild(endLabelIndex);

			this.editLink = new GameField(gls("<body><a href='event:' class='link'>Редактировать</a></body>"), OFFSET_X, 271, style);
			this.editLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.editLink.addEventListener(MouseEvent.MOUSE_UP, onEdit);
			this.editLink.addEventListener(MouseEvent.ROLL_OVER, onOver);
			addChild(this.editLink);

			this.deleteLink = new GameField(gls("<body><a href='event:' class='link'>Удалить</a></body>"), OFFSET_X + 90, 271, style);
			this.deleteLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.deleteLink.addEventListener(MouseEvent.MOUSE_UP, onDelete);
			addChild(this.deleteLink);

			this.newLink = new GameField(gls("<body><a href='event:#' class='newMap'>Создать новую карту</a></body>"), OFFSET_X, 289, style);
			this.newLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.newLink.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.newLink.addEventListener(MouseEvent.MOUSE_UP, onNew);
			addChild(this.newLink);

			this.releaseLink = new GameField(gls("<body><a href='event:#' class='newMap'>Зарелизить все карты</a></body>"), OFFSET_X, 289, style);
			this.releaseLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.releaseLink.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.releaseLink.addEventListener(MouseEvent.MOUSE_UP, releaseMaps);
			addChild(this.releaseLink);

			this.findField = new EditField(gls("Поиск по №"), OFFSET_X, 308, 97, 15, editFormat);
			this.findField.restrict = "0-9";
			this.findField.background = false;
			addChild(this.findField);

			this.goToLink = new GameField(gls("<body><a href='event:#' class='link'>Перейти</a></body>"), 125, 308, style);
			this.goToLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.goToLink.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.goToLink.addEventListener(MouseEvent.MOUSE_UP, onFind);
			addChild(this.goToLink);

			this.mapsCount = new GameField("", OFFSET_X, 325, new TextFormat(null, 11, 0x000000, false));
			this.mapsCount.height = 20;
			this.mapsCount.width = 150;
			addChild(this.mapsCount);

			this.totalCountField = new GameField("", OFFSET_X, 340, new TextFormat(null, 11, 0x000000, false));
			addChild(this.totalCountField);

			this.modersButton = new Convert();
			this.modersButton.x = OFFSET_X + 145;
			this.modersButton.y = 0;
			this.modersButton.visible = false;
			this.modersButton.addEventListener(MouseEvent.CLICK, showModers);
			addChild(this.modersButton);

			this.lagsLink = new GameField(gls("<body><a href='event:' class='newMap'>Лаги</a></body>"), OFFSET_X + 130, 289, style);
			this.lagsLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.lagsLink.addEventListener(MouseEvent.MOUSE_UP, estimateLags);
			//addChild(this.lagsLink);

			this.invisibleLink = new GameField(gls("<body><a href='event:' class='newMap'>Невидимые</a></body>"), OFFSET_X + 130, 289, style);
			this.invisibleLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.invisibleLink.addEventListener(MouseEvent.MOUSE_UP, findInvisible);
			addChild(this.invisibleLink);

			place();

			this.width += 15;
			this.height += 50;

			Connection.listen(onPacket, PacketMapsList.PACKET_ID);
			Game.listen(onPlayerLoaded);
		}

		static public function get lengthList(): int
		{
			return _instance.list.length;
		}

		static public function addMap(number:int, location:int, mode:int, authorId:int, subLocation:int):void
		{
			_instance.addMap(number, location, mode, authorId, DialogMapInfo.folder, subLocation);
		}

		static public function deleteMap(locationId:int, map:int):void
		{
			var index:int = _instance.list.selectedIndex;

			_instance.removeFromList(locationId, map);
			Connection.sendData(PacketClient.MAPS_REMOVE, map);

			if (!RangeMaps.isEmpty)
			{
				RangeMaps.delMap(map);
				if (!RangeMaps.isEmpty)
					(SquirrelGame.instance as SquirrelGameEditor).onOpen(_instance.comboBox.selectedItem['value'], RangeMaps.currentMap, _instance.folderComboBox.selectedItem['value'], _instance.subComboBox.selectedItem == null ? 0 : _instance.subComboBox.selectedItem['value']);
				else
					(SquirrelGame.instance as SquirrelGameEditor).onExit();
				return;
			}

			if (index <= 0)
			{
				_instance.show();
				if (index < 0 || _instance.list.length == 0)
					return;
			}

			_instance.loadMap(index >= _instance.list.length ? _instance.list.length - 1 : index);
		}

		static public function loadMapNext():void
		{
			var index:int = _instance.list.selectedIndex;
			_instance.loadMap(index);
		}

		static public function loadNextMap(value:int = -1):void
		{
			if (!RangeMaps.isEmpty)
			{
				(SquirrelGame.instance as SquirrelGameEditor).onOpen(_instance.comboBox.selectedItem['value'], RangeMaps.currentMap, _instance.folderComboBox.selectedItem['value'], _instance.subComboBox.selectedItem == null ? 0 : _instance.subComboBox.selectedItem['value']);
				return;
			}

			var index:int = 0;
			if (value > 0)
				index = _instance.getIndexMap(value);
			_instance.loadMap(index + 1);
		}

		static public function loadPrevMap(value:int = -1):void
		{
			if (!RangeMaps.isEmpty)
			{
				(SquirrelGame.instance as SquirrelGameEditor).onOpen(_instance.comboBox.selectedItem['value'], RangeMaps.currentMap, _instance.folderComboBox.selectedItem['value'], _instance.subComboBox.selectedItem == null ? 0 : _instance.subComboBox.selectedItem['value']);
				return;
			}

			var index:int = 1;
			if (value > 0)
				index = _instance.getIndexMap(value);
			_instance.loadMap(index - 1);
		}

		static public function deleteSelectedMap():void
		{
			var location:Object = _instance.comboBox.selectedItem;
			if (location == null)
				return;

			var map:Object = _instance.list.selectedItem;
			if (map == null)
				return;

			var number:int = _instance.getMapNumber(_instance.list.selectedItem);
			_instance.removeFromList(location['value']);
			Connection.sendData(PacketClient.MAPS_REMOVE, number);
		}

		static public function removeFromList(locationId:int, map:int):void
		{
			_instance.removeFromList(locationId, map);
		}

		static public function show():void
		{
			_instance.show();
		}

		static public function hideSelf():void
		{
			_instance.hideSelf();
		}

		static public function isShowing():Boolean
		{
			return _instance.visible;
		}

		static public function checkMap(value:int, str:String):Boolean
		{
			switch (str)
			{
				case "Next":
					if (RangeMaps.isEmpty)
						return (_instance.list.length - 1 > _instance.getIndexMap(value));
					else
						return RangeMaps.nextMap();
				case "Prev":
					if (RangeMaps.isEmpty)
						return (_instance.getIndexMap(value) > 0);
					else
						return RangeMaps.prevMap();

			}
			return false;
		}

		override public function show():void
		{
			if (!this.loaded)
			{
				this.modersButton.visible = (Game.editor_access == PacketServer.EDITOR_FULL);
				this.deleteLink.visible = canDelete;
				this.newLink.visible = Game.editor_access != PacketServer.EDITOR_SUPER || (Game.editor_access == PacketServer.EDITOR_SUPER && this.locationId == Locations.NONAME_ID);
				this.releaseLink.visible = false;
				this.lagsLink.visible = (Game.editor_access == PacketServer.EDITOR_FULL);
				this.invisibleLink.visible = (Game.editor_access == PacketServer.EDITOR_FULL);
				this.folderComboBox.visible = (Game.editor_access == PacketServer.EDITOR_FULL);
				updateListLocation();

				Connection.sendData(PacketClient.MAPS_LIST, this.locationId, 0, this.modeId);

				updateListSub(this.locationId);
				updateListMode(this.locationId);
				this.loaded = true;
			}

			clearRange();

			this.visible = true;

			addToSprite();

			this.selfClose = false;

			selectLocation(this.locationId);

			requestMaps(this.comboBox.selectedItem['value'], this.folderId);

			(SquirrelGame.instance as SquirrelGameEditor).reset();
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			Game.stage.focus = Game.stage;

			if (this.parent != null)
				this.parent.removeChild(this);

			if (this.selfClose)
				return;

			Screens.show("Location");
		}

		private function get canDelete():Boolean
		{
			return (Game.editor_access != PacketServer.EDITOR_SUPER || (Game.editor_access == PacketServer.EDITOR_SUPER && (this.locationId == Locations.NONAME_ID || this.locationId == Locations.APPROVED_ID)));
		}

		private function onChangeList(e:MouseEvent):void
		{
			this.editLink.visible = true;

			RangeMaps.clear();
			if (this.list.selectedItems.length > 1)
				for each(var item:Object in this.list.selectedItems)
					RangeMaps.addMap(getMapNumber(item));

			this.startIndexField.text = RangeMaps.isEmpty ? "" : String(RangeMaps.first);

			this.endIndexField.text = RangeMaps.isEmpty ? "" : String(RangeMaps.last);

			this.deleteLink.visible = canDelete && RangeMaps.isEmpty;
			this.goToLink.visible = this.findField.visible = RangeMaps.isEmpty;
		}

		private function clearRange():void
		{
			RangeMaps.clear();

			this.startIndexField.text = "";
			this.endIndexField.text = "";

			this.deleteLink.visible = canDelete;
			this.findField.visible = this.goToLink.visible = this.editLink.visible = true;
		}

		private function updateListLocation():void
		{
			var provider:DataProvider = new DataProvider();
			for each (var location:Location in Locations.list)
			{
				if (!checkLocation(location.id))
					continue;
				provider.addItem({'label': location.name, 'value': location.id});
			}
			this.comboBox.dataProvider = provider;
			this.comboBox.selectedIndex = 0;
			this.comboBox.drawNow();
		}

		private function updateListSub(locationId:int):void
		{
			this.subComboBox.visible = Locations.getLocation(locationId).subs != null;
			this.subId = 0;

			if (!this.subComboBox.visible)
				return;

			var provider:DataProvider = new DataProvider();

			for (var i:int = 0; i < Locations.getLocation(locationId).subs.length; i++)
				provider.addItem({'label': Locations.getLocation(locationId).subs[i]['name'], 'value': i});

			this.subComboBox.dataProvider = provider;
			this.subComboBox.drawNow();
		}

		private function updateListMode(locationId:int):void
		{
			var modes:Array = Locations.getLocation(locationId).subs != null ? Locations.getLocation(locationId).subs[this.subId]['modes'] : Locations.getLocation(locationId).mapModes;

			this.modeComboBox.visible = modes != null;
			this.modeId = 0;

			if (!this.modeComboBox.visible)
				return;

			var provider:DataProvider = new DataProvider();
			var index:int = 0;

			if (modes)
			{
				for each (index in modes)
					provider.addItem({'label': Locations.MODES[index].name, 'value': index});
			}
			else for each (var mode:Object in Locations.MODES)
			{
				if (mode.name != null)
					provider.addItem({'label': mode.name, 'value': index});
				index++;
			}

			this.modeComboBox.dataProvider = provider;
			this.modeComboBox.drawNow();
			this.modeId = this.modeComboBox.getItemAt(0)['value'];
			Logger.add("updateListMode", this.modeId);
		}

		private function checkLocation(id:int):Boolean
		{
			if (id == Locations.PRE_RELEASE_ID)
				return false;

			if (this.folderComboBox.selectedItem['value'] == Locations.PRE_RELEASE_FOLDER_ID)
				return Locations.getLocation(id).game;

			if (Game.editor_access != PacketServer.EDITOR_FULL && (id == Locations.SANDBOX_ID || id == Locations.WILD_ID || id == Locations.BAD_ID || id == Locations.TENDER || id == Locations.SCHOOL_ID))
				return false;

			if (Game.editor_access != PacketServer.EDITOR_APPROVAL && Game.editor_access != PacketServer.EDITOR_APPROVAL_PLUS)
				return true;

			if (id != Locations.NONAME_ID)
				return false;

			this.locationId = (Game.editor_access == PacketServer.EDITOR_APPROVAL_PLUS ? Locations.TENDER : Locations.NONAME_ID);
			return true;
		}

		private function loadMap(index:int):void
		{
			var location:Object = this.comboBox.selectedItem;
			if (location == null)
				return;

			if (!_instance.list.length)
				return;

			if (index < 0 || index >= this.list.length)
				return;

			var item:Object = this.list.getItemAt(index);
			if (item == null)
				return;

			this.list.selectedIndex = index;

			var number:int = this.getMapNumber(item);

			(SquirrelGame.instance as SquirrelGameEditor).onOpen(location['value'], number, this.folderComboBox.selectedItem['value'], this.subComboBox.selectedItem == null ? 0 : this.subComboBox.selectedItem['value']);
			hideSelf();
		}

		private function getIndexMap(id:int):int
		{
			for (var i:int = 0; i < this.list.length; i++)
			{
				var number:int = this.getMapNumber(this.list.getItemAt(i));
				if (number != id)
					continue;

				this.list.selectedIndex = i;
				return i;
			}
			return 1;
		}

		private function requestMaps(locationIdNew:int, folderIdNew:int, update:Boolean = false):void
		{
			if (!update && this.locationId == locationIdNew && this.folderId == folderIdNew)
				return;

			this.locationId = locationIdNew;
			this.folderId = folderIdNew;

			var locationToRequest:int = (this.folderId == Locations.PRE_RELEASE_FOLDER_ID) ? Locations.PRE_RELEASE_ID : this.locationId;

			if (!(locationToRequest in this.allItems) || ((this.allItems[locationToRequest]['mods'] as Array).indexOf(this.modeId)) == -1 || this.subId != 0)
			{
				this.list.removeAll();
				if (Locations.getLocation(locationToRequest).subs == null)
					Connection.sendData(PacketClient.MAPS_LIST, locationToRequest, 0, this.modeId);
				else
				{
					var modes:Array = Locations.getLocation(locationToRequest).subs[this.subId]['modes'];
					for (var i:int = 0; i < modes.length; i++)
						Connection.sendData(PacketClient.MAPS_LIST, locationToRequest, this.subId, modes[i]);
				}
				return;
			}

			loadItems(this.locationId);
		}

		private function hideSelf():void
		{
			this.selfClose = true;
			hide();
		}

		private function addMap(numberNew:int, locationNew:int, modeNew:int, authorIdNew:int, folderNew:int, subLocation:int):void
		{
			var locationToAdd:int = (folderNew == Locations.PRE_RELEASE_FOLDER_ID) ? Locations.PRE_RELEASE_ID : locationNew;

			if (!(locationToAdd in this.allItems))
				return;

			var items:Array = this.allItems[locationToAdd]['items'];
			items.push({'label': numberNew, 'value': numberNew, 'playerId': authorIdNew, 'mode': modeNew, 'rating': "0", 'percent': "100", 'forSort': numberNew, 'sub': subLocation});
			if (folderNew == Locations.PRE_RELEASE_FOLDER_ID)
				items[items.length - 1]['folderMark'] = locationNew;

			if ("total_count" in this.allItems[locationToAdd])
				this.allItems[locationToAdd]['total_count']++;

			if (folderNew != this.folderId)
				return;

			if (locationNew != this.locationId)
				return;

			if (modeNew != (Locations.getLocation(locationId).multiMapMode ? (this.modeComboBox.selectedItem != null ? this.modeComboBox.selectedItem['value'] : this.modeComboBox.getItemAt(0)['value']) : 0))
				return;

			var index:int = list.selectedIndex;
			loadItems(locationNew);
			list.selectedIndex = index;
		}

		private function onChangeLocation(e:Event):void
		{
			clearRange();

			var item:Object = this.comboBox.selectedItem;
			if (item == null)
				return;

			this.comboBox.drawNow();

			updateListSub(item['value']);
			updateListMode(item['value']);
			requestMaps(item['value'], this.folderId);
			this.deleteLink.visible = canDelete;
			this.newLink.visible = (this.folderId != Locations.PRE_RELEASE_FOLDER_ID) && (Game.editor_access != PacketServer.EDITOR_SUPER || (Game.editor_access == PacketServer.EDITOR_SUPER && this.locationId == Locations.NONAME_ID));
		}

		private function onChangeMode(e:Event):void
		{
			clearRange();

			var item:Object = this.modeComboBox.selectedItem;
			if (item == null)
				return;

			this.modeComboBox.drawNow();
			this.modeId = item['value'];

			requestMaps(this.locationId, this.folderId, true);
		}

		private function onChangeSub(e:Event):void
		{
			clearRange();

			var item:Object = this.subComboBox.selectedItem;
			if (item == null)
				return;

			this.subComboBox.drawNow();
			this.subId = item['value'];

			updateListMode(this.locationId);

			requestMaps(this.locationId, this.folderId, true);
		}

		private function onChangeFolder(e:Event):void
		{
			clearRange();

			var item:Object = this.folderComboBox.selectedItem;
			if (item == null)
				return;

			updateListLocation();

			updateListSub(this.comboBox.selectedItem['value']);
			updateListMode(this.comboBox.selectedItem['value']);
			requestMaps(this.comboBox.selectedItem['value'], item['value']);

			this.deleteLink.visible = canDelete;
			this.newLink.visible = (this.folderId != Locations.PRE_RELEASE_FOLDER_ID) && (Game.editor_access != PacketServer.EDITOR_SUPER || (Game.editor_access == PacketServer.EDITOR_SUPER && this.locationId == Locations.NONAME_ID));
			this.releaseLink.visible = (this.folderId == Locations.PRE_RELEASE_FOLDER_ID) && (Game.editor_access == PacketServer.EDITOR_FULL);
			this.invisibleLink.visible = (this.folderId != Locations.PRE_RELEASE_FOLDER_ID) && (Game.editor_access == PacketServer.EDITOR_FULL);
		}

		private function selectLocation(id:int):void
		{
			for (var i:int = 0; i < this.comboBox.length; i++)
			{
				var item:Object = this.comboBox.getItemAt(i);
				if (item['value'] != id)
					continue;

				this.comboBox.selectedIndex = i;
				break;
			}
		}

		private function loadItems(locationId:int):void
		{
			var modeId:int = 0;
			if (Locations.getLocation(locationId).multiMapMode || Locations.getLocation(locationId).subs != null)
				modeId = this.modeComboBox.selectedItem != null ? this.modeComboBox.selectedItem['value'] : this.modeComboBox.getItemAt(0)['value'];
			modeId = (modeId == Locations.SNAKE_MODE) ? Locations.ROPED_MODE : modeId;

			this.list.removeAll();

			this.currentItems = {};

			var locationToShow:int = (this.folderId == Locations.PRE_RELEASE_FOLDER_ID) ? Locations.PRE_RELEASE_ID : locationId;

			if (!(locationToShow in this.allItems))
				return;

			var playersIds:Array = [];

			for each (var item:Object in this.allItems[locationToShow]['items'])
			{
				if ((this.folderId == Locations.PRE_RELEASE_FOLDER_ID) && (locationId != item['folderMark']))
					continue;

				var playerId:int = item['playerId'];
				var itemModeId:int = item['mode'];

				if (itemModeId != modeId || item['sub'] != this.subId)
					continue;

				playersIds.push(playerId);
				if (!(playerId in this.currentItems))
					this.currentItems[playerId] = [];
				this.currentItems[playerId].push(item);

				this.list.addItem(item);
			}

			this.list.sortItemsOn("forSort", Array.NUMERIC);

			Game.request(playersIds, PlayerInfoParser.NAME);

			this.mapsCount.text = gls("Количество карт: {0}", this.list.length);
			this.totalCountField.text = ("total_count" in this.allItems[locationToShow]) ? gls("Общее количество карт: {0}", this.allItems[locationToShow]['total_count']) : "";
		}

		private function onDelete(e:Event = null):void
		{
			if (this.comboBox.selectedItem == null)
				return;
			if (this.list.selectedItem == null)
				return;
			(SquirrelGame.instance as SquirrelGameEditor).showDeleteDialog();
		}

		private function onChangeRange(e:Event):void
		{
			RangeMaps.clear();

			var startIndex:int = int(this.startIndexField.text);
			var endIndex:int = int(this.endIndexField.text);

			if (startIndex >= endIndex || (startIndex != getMapNumber(this.list.getItemAt(getIndexMap(startIndex)))) || (endIndex != getMapNumber(this.list.getItemAt(getIndexMap(endIndex)))))
			{
				this.deleteLink.visible = this.editLink.visible = false;
				return;
			}

			for (var i:int = getIndexMap(int(this.startIndexField.text)); i < this.list.length; i++)
				RangeMaps.addMap(getMapNumber(this.list.getItemAt(i)));

			this.editLink.visible = true;
			this.deleteLink.visible = canDelete;
		}

		private function onEdit(e:Event):void
		{
			var location:Object = this.comboBox.selectedItem;
			if (location == null)
				return;

			if (!RangeMaps.isEmpty)
			{
				(SquirrelGame.instance as SquirrelGameEditor).onOpen(location['value'], RangeMaps.first, this.folderComboBox.selectedItem['value'], this.subComboBox.selectedItem == null ? 0 : this.subComboBox.selectedItem['value']);
				hideSelf();
				return;
			}

			var item:Object = this.list.selectedItem;
			if (item == null)
				return;

			hideSelf();

			(SquirrelGame.instance as SquirrelGameEditor).onOpen(location['value'], getMapNumber(item), this.folderComboBox.selectedItem['value'], this.subComboBox.selectedItem == null ? 0 : this.subComboBox.selectedItem['value']);
		}

		private function onFind(e:Event):void
		{
			if (this.findField.text == "" || this.findField.text == gls("Поиск по №"))
				return;

			var location:Object = this.comboBox.selectedItem;
			if (location == null)
				return;

			var number:int = int(this.findField.text);

			if (Game.editor_access == PacketServer.EDITOR_FULL)
			{
				(SquirrelGame.instance as SquirrelGameEditor).onOpen(location['value'], number, this.folderComboBox.selectedItem['value'], this.subComboBox.selectedItem == null ? 0 : this.subComboBox.selectedItem['value']);
				hideSelf();
				return;
			}

			for each (var item:Object in this.allItems[location['value']]['items'])
			{
				var value:int = getMapNumber(item);
				if (value != number)
					continue;

				(SquirrelGame.instance as SquirrelGameEditor).onOpen(location['value'], number, this.folderComboBox.selectedItem['value'], this.subComboBox.selectedItem == null ? 0 : this.subComboBox.selectedItem['value']);
				hideSelf();
				return;
			}

			this.dialogNotFound.show();
		}

		private function onNew(e:Event):void
		{
			clearRange();

			hideSelf();

			(SquirrelGame.instance as SquirrelGameEditor).onNew(this.locationId, this.modeId, this.subId);
		}

		private function releaseMaps(e:Event):void
		{
			if (this.folderId != Locations.PRE_RELEASE_FOLDER_ID)
				return;

			this.list.removeAll();

			for each (var item:Object in this.allItems[Locations.PRE_RELEASE_ID]['items'])
			{
				Connection.sendData(PacketClient.MAPS_EDIT, item['forSort'], item['folderMark'], item['sub'], item['mode'], item['folderMark']);
				addMap(item['forSort'], item['folderMark'], item['mode'], item['playerId'], Locations.RELEASE_FOLDER_ID, item['sub']);
			}

			delete this.allItems[Locations.PRE_RELEASE_ID];

			this.mapsCount.text = gls("Количество карт: 0");
			this.totalCountField.text = gls("Общее количество карт: 0");
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (!(player['id'] in this.currentItems))
				return;

			for each (var item:Object in this.currentItems[player['id']])
			{
				item['label'] = item['label'] + "     " + player.name.substr(0, 10) + ", " + item['percent'] + "%, " + item['rating'];
				this.list.invalidateItem(item);
			}

			delete this.currentItems[player['id']];
		}

		private function getMapNumber(item:Object):int
		{
			return item['value'];
		}

		private function removeFromList(locationIdDelete:int, mapDelete:int = -1):void
		{
			var locationToDelete:int = (this.folderId == Locations.PRE_RELEASE_FOLDER_ID) ? Locations.PRE_RELEASE_ID : locationIdDelete;

			if (!(locationToDelete in this.allItems))
				return;

			var map:int = (mapDelete != -1 ? mapDelete : getMapNumber(this.list.selectedItem));

			var items:Array = this.allItems[locationToDelete]['items'];
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i]['value'] != map)
					continue;
				items.splice(i, 1);
				break;
			}
			this.allItems[locationToDelete]['items'] = items;
			if ("total_count" in this.allItems[locationToDelete])
				this.allItems[locationToDelete]['total_count']--;

			var index:int = this.list.selectedIndex;
			loadItems(locationIdDelete);
			this.list.selectedIndex = index;
		}

		private function onPacket(packet:PacketMapsList):void
		{
			var locationToSave:int = (this.folderId == Locations.PRE_RELEASE_FOLDER_ID) ? Locations.PRE_RELEASE_ID : packet.locationId;

			this.list.removeAll();

			var newItems:Array = [];
			var mode:int = packet.mode;
			var model: PacketMapsListMaps = null;

			for (var i:int = 0; i < packet.maps.length; i++)
			{
				model = packet.maps[i];

				var map:int = model.mapId;
				var mark:int = model.markId;
				var playerId:int = model.playerId;
				var rating:int = model.rating;
				var percent:int = model.percentExit;

				var item:Object = {'label': map, 'value': map, 'mode': mode, 'rating': rating, 'percent': percent, 'forSort': map, 'playerId': playerId, 'folderMark': mark, 'sub': packet.sublocationId};

				this.list.addItem(item);
				newItems.push(item);
			}

			if (this.allItems[locationToSave] != null)
			{
				this.allItems[locationToSave]['items'] = (this.allItems[locationToSave]['items'] as Array).concat(newItems);
				this.allItems[locationToSave]['mods'].push(mode);
			}
			else
			{
				this.allItems[locationToSave] = {};
				this.allItems[locationToSave]['items'] = newItems;
				this.allItems[locationToSave]['mods'] = [mode];
			}
			this.allItems[locationToSave]['total_count'] = packet.totalCount;

			loadItems(packet.locationId);
		}

		private function onClick(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.CLICK);
			e.stopImmediatePropagation();
		}

		private function onOver(e:MouseEvent):void
		{

		}

		private function showModers(e:MouseEvent):void
		{
			DialogModerators.show();
		}

		private function estimateLags(e:MouseEvent):void
		{
			DialogEstimateLags.show(this.allItems[this.locationId]['items'].concat());
		}

		private function findInvisible(e:MouseEvent):void
		{
			DialogFindInvisible.show(this.locationId, this.allItems[this.locationId]['items'].concat(), this.subId);
		}
	}
}