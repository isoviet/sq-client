package dialogs
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import fl.controls.List;

	import events.EditNewElementEvent;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.editor.inspector.InspectorDialog;
	import game.mainGame.gameEditor.GameMapEditor;

	import utils.EditField;
	import utils.MapInvisiblesChecker;

	public class DialogObjectsInspector extends Dialog
	{
		static private const OFFSET_X:int = 25;
		static private const DEFAULT_FIND_TEXT:String = gls("Поиск по имени");

		private var allItems:Array = [];
		private var list:List = new List();
		private var map:GameMapEditor;

		private var findField:EditField = null;

		public function DialogObjectsInspector(map:GameMapEditor)
		{
			super(gls("Инспектор объектов"));

			this.map = map;
			init();
		}

		public function removeAll():void
		{
			this.list.removeAll();
			this.allItems = [];
		}

		private function init():void
		{
			var backgroundList:ListSkin = new ListSkin();
			backgroundList.x = OFFSET_X;
			backgroundList.y = 10;
			backgroundList.width = 220;
			backgroundList.height = 250;
			addChild(backgroundList);

			this.list.x = OFFSET_X;
			this.list.y = 10;
			this.list.setSize(220, 250);
			this.list.rowHeight = 13;
			this.list.setStyle("cellRenderer", ListStyleRendererLocation);
			this.list.iconField = "iconSource";
			addChild(this.list);

			this.list.doubleClickEnabled = true;

			this.findField = new EditField(DEFAULT_FIND_TEXT, OFFSET_X, 280, 220, 18, new TextFormat(GameField.DEFAULT_FONT, 11, 0x3A2506));
			this.findField.restrict = "а-яё А-ЯЁa-zA-Z";
			this.findField.addEventListener(Event.CHANGE, filterItems);
			addChild(this.findField);

			place();

			this.width += 50;
			this.height += 80;

			this.list.addEventListener(MouseEvent.CLICK, selectItem);
			this.list.addEventListener(MouseEvent.DOUBLE_CLICK, setCamera);

			this.list.addEventListener(KeyboardEvent.KEY_DOWN, deleteItem);

			this.map.addEventListener(EditNewElementEvent.ADD, addOnMap);
			this.map.addEventListener(EditNewElementEvent.REMOVE, removeFromMap);

			this.map.selection.addEventListener(EditNewElementEvent.SELECT, selectOnMap);

			InspectorDialog.addChangeListener(onChangeObject);
		}

		private function onChangeObject(object:*):void
		{
			var obj:Object = getListItem(object);
			if (!obj)
				return;
			obj['iconSource'] = (("fixed" in object && object['fixed'] == true) || !("fixed" in object)) ? StaticIcon : DynamicIcon;
			obj['marked'] = MapInvisiblesChecker.checkInvisible(object['alpha']);
			obj['alpha'] = obj['marked'] ? 0 : 1;
			updateItem(obj);
		}

		private function getListItem(object:*):Object
		{
			for each (var item:Object in this.allItems)
			{
				if (item['value']['name'] != object['name'])
					continue;

				return item;
			}

			return null;
		}

		private function setCamera(e:MouseEvent):void
		{
			var selectedItem:String = (e.currentTarget as List).selectedItem['value']['name'];
			var obj:DisplayObject = this.map.getByName(selectedItem) as DisplayObject;

			var point:Point = new Point(-1, -1);
			point.x *= ((obj.x - this.stage.stageWidth) + (this.stage.stageWidth >> 1));
			point.y *= ((obj.y - this.stage.stageHeight) + (this.stage.stageHeight >> 1));

			this.map.game.shift = point;
			Game.stage.focus = this.map;
		}

		private function selectOnMap(e:EditNewElementEvent):void
		{
			if (e.className == null)
			{
				this.list.selectedIndex = -1;
				return;
			}

			var selectedItem:Object = getListItem(e.className);
			if (!selectedItem)
				return;

			if (!checkFilter(selectedItem))
			{
				this.list.selectedIndex = -1;
				return;
			}

			this.list.selectedItem = selectedItem;
		}

		private function deleteItem(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.DELETE)
				return;

			this.list.selectedIndex = -1;
			this.map.selection.deleteSelected();
			this.map.createObject(null);
		}

		private function selectItem(e:MouseEvent):void
		{
			var selectedItem:String = (e.currentTarget as List).selectedItem['value']['name'];

			this.map.selection.clear();
			this.map.selection.add(this.map.getByName(selectedItem));
		}

		private function removeFromMap(e:EditNewElementEvent):void
		{
			var delObject:Object = e.className as Object;
			for (var i:int = 0; i < this.allItems.length; i++)
			{
				if (this.allItems[i]['value']['name'] != delObject['name'])
					continue;

				if (checkFilter(this.allItems[i]))
				{
					this.list.removeItem(this.allItems[i]);
					this.list.selectedIndex = -1;
				}

				this.allItems.splice(i, 1);
			}
		}

		private function addOnMap(e:EditNewElementEvent):void
		{
			var object:DisplayObject = e.className as DisplayObject;

			if (object == null || EntityFactory.getName(object) == "")
				return;

			var item:Object = createListItem(object);
			this.allItems.push(item);

			if (!checkFilter(item))
				return;

			this.list.addItem(item);
			this.list.sortItems(compareFunction);
		}

		private function createListItem(object:Object):Object
		{
			var item:Object = {};
			var gameBodyName:String = EntityFactory.getName(object);

			item['value'] = object;
			item['label'] = gameBodyName;
			item['alpha'] = MapInvisiblesChecker.checkInvisible(object['alpha']) ? 0 : 1;
			item['marked'] = !Boolean(item['alpha']);

			if ('fixed' in object)
				item['iconSource'] = (object['fixed'] == true ? StaticIcon : DynamicIcon);
			else
				item['iconSource'] = StaticIcon;

			return item;
		}

		private function filterItems(e:Event):void
		{
			this.list.removeAll();

			for each (var item:Object in this.allItems)
			{
				if (checkFilter(item))
					this.list.addItem(item);
			}

			this.list.sortItems(compareFunction);
		}

		private function updateItem(item:Object):void
		{
			if (!checkFilter(item))
				return;

			this.list.removeItem(item);
			this.list.addItem(item);
			this.list.sortItems(compareFunction);
		}

		private function checkFilter(item:Object):Boolean
		{
			var searchName:String = this.findField.text;
			return ((item['label'] as String).toLowerCase().substring(0, searchName.length) == searchName.toLowerCase() || searchName == "" || searchName == DEFAULT_FIND_TEXT);
		}

		private function compareFunction(itemA:Object, itemB:Object):int
		{
			if (itemA['alpha'] < itemB['alpha'])
				return -1;
			else
				return (itemA['alpha'] == itemB['alpha']) ? (itemA['label'] < itemB['label'] ? -1 : 1) : 1;
		}
	}
}