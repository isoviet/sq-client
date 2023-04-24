package clans.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.containers.ScrollPane;
	import fl.controls.CheckBox;

	import clans.ClanApplication;
	import events.ApplicationsUpdateEvent;
	import menu.MenuProfile;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.DateUtil;
	import utils.PlayerUtil;

	public class ApplicationList extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
			}
			a {
				color: #017ACC;
				text-decoration: none;
				margin-right: 0px;
				font-weight: bold;
			}
			a:hover {
				text-decoration: underline;
			}
		]]>).toString();

		static private const ELEMENT_HEIGHT:int = 25;
		static private const PLACES_COUNT:int = 3;

		private var data:Vector.<ClanApplication> = null;
		private var places:Vector.<ApplicationSprite> = null;
		private var checkBoxes:Vector.<CheckBox> = null;
		private var requstedIds:Array = [];

		private var selectAll:CheckBox = null;

		private var sortNameField:GameField = null;
		private var sortLevelField:GameField = null;
		private var sortDateField:GameField = null;

		private var scrollPaneList:ScrollPane = null;
		private var listSprie:Sprite = null;
		private var emptyListField:GameField = null;

		private var style:StyleSheet;

		public function ApplicationList():void
		{
			init();
		}

		public function clear():void
		{
			toggleList(false);
			for (var i:int = 0; i < this.data.length; i++)
				this.data[i].removeEventListener("LOADED", updateView);

			this.data = new Vector.<ClanApplication>();
			dispatchEvent(new ApplicationsUpdateEvent(this.data.length));
		}

		public function addData(data:Vector.<ClanApplication>):void
		{
			this.data = this.data.concat(data);

			var unic:Vector.<ClanApplication> = new Vector.<ClanApplication>;
			var existValues:Object = {};

			for (var i:int = this.data.length - 1; i >= 0; i--)
			{
				if (typeof existValues[this.data[i].playerId] == "undefined" || existValues[this.data[i].playerId] == null)
					unic.push(this.data[i]);
				else
					this.data[i].removeEventListener("LOADED", updateView);

				existValues[this.data[i].playerId] = this.data[i];
			}

			this.data = unic;
			toggleList(this.data.length > 0);

			for (i = 0; i < this.data.length; i++)
			{
				var index:int = this.requstedIds.indexOf(this.data[i].playerId);
				if (index != -1)
					this.requstedIds.splice(index, 1);

				this.data[i].addEventListener("LOADED", updateView);
			}

			dispatchEvent(new ApplicationsUpdateEvent(this.data.length));
			updateData();
			updateView();
		}

		private function toggleList(value:Boolean):void
		{
			this.sortNameField.visible = value;
			this.sortLevelField.visible = value;
			this.sortDateField.visible = value;
			this.selectAll.visible = value;

			this.emptyListField.visible = !value;
		}

		public function inviteSelected():void
		{
			this.selectAll.selected = false;

			var ids:Array = [];

			for (var i:int = 0; i < this.data.length; i++)
				if (this.data[i].selected)
					ids.push(this.data[i].playerId);

			this.data = this.data.filter(filterFunction);

			updateData();
			updateView();
			toggleList(this.data.length > 0);

			dispatchEvent(new ApplicationsUpdateEvent(this.data.length));

			Connection.sendData(PacketClient.CLAN_ACCEPT, ids, PacketClient.CLAN_ACCEPT_INVITE);
		}

		public function refuseSelected():void
		{
			this.selectAll.selected = false;

			var ids:Array = [];

			for (var i:int = 0; i < this.data.length; i++)
				if (this.data[i].selected)
					ids.push(this.data[i].playerId);

			this.data = this.data.filter(filterFunction);

			updateData();
			updateView();
			toggleList(this.data.length > 0);

			dispatchEvent(new ApplicationsUpdateEvent(this.data.length));

			Connection.sendData(PacketClient.CLAN_ACCEPT, ids, PacketClient.CLAN_ACCEPT_REJECT);
		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.data = new Vector.<ClanApplication>();

			this.places = new Vector.<ApplicationSprite>();
			this.checkBoxes = new Vector.<CheckBox>();

			var applicationListBg:ApplicationBackground = new ApplicationBackground();
			applicationListBg.x = -5;
			applicationListBg.y = -4;
			applicationListBg.height = PLACES_COUNT * ELEMENT_HEIGHT + 40;
			addChild(applicationListBg);

			this.selectAll = new CheckBox();
			this.selectAll.x = -1;
			this.selectAll.y = -3;
			this.selectAll.label = "";
			this.selectAll.addEventListener(Event.CHANGE, onSelectAll);
			addChild(this.selectAll);

			var sortFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 11, 0x000000);

			this.sortNameField = new GameField(gls("Имя"), 23, 0, sortFormat);
			addChild(this.sortNameField);

			this.sortLevelField = new GameField(gls("Уровень"), 140, 0, sortFormat);
			addChild(this.sortLevelField);

			this.sortDateField = new GameField(gls("Дата"), 236, 0, sortFormat);
			addChild(this.sortDateField);

			var format:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 18, 0x663C0D, true);
			this.emptyListField = new GameField(gls("Заявок нет"), 110, 40, format);
			this.emptyListField.visible = false;
			addChild(this.emptyListField);

			this.scrollPaneList = new ScrollPane();
			this.scrollPaneList.setSize(314, PLACES_COUNT * ELEMENT_HEIGHT);
			this.scrollPaneList.x = 0;
			this.scrollPaneList.y = 30;
			addChild(this.scrollPaneList);

			this.listSprie = new Sprite();

			this.scrollPaneList.source = this.listSprie;
		}

		private function updateData():void
		{
			for (var i:int = 0; i < this.places.length; i++)
			{
				this.places[i].fieldName.removeEventListener(MouseEvent.MOUSE_DOWN, showMenu);
				this.checkBoxes[i].removeEventListener(Event.CHANGE, selectItem);

				if (!this.places[i].parent)
					continue;

				this.places[i].parent.removeChild(this.places[i]);
				this.checkBoxes[i].parent.removeChild(this.checkBoxes[i]);
			}

			this.places = new Vector.<ApplicationSprite>();
			this.checkBoxes = new Vector.<CheckBox>();

			var y:int = 0;

			for (i = 0; i < this.data.length; i++)
			{
				var element:ApplicationSprite = new ApplicationSprite();
				element.y = y;
				element.name = i.toString();
				element.fieldName.styleSheet = this.style;
				element.fieldName.addEventListener(MouseEvent.MOUSE_DOWN, showMenu);
				this.listSprie.addChild(element);
				this.places.push(element);

				var checkBox:CheckBox = new CheckBox();
				checkBox.name = i.toString();
				checkBox.x = element.x - 1;
				checkBox.y = element.y - 4;
				checkBox.label = "";
				checkBox.addEventListener(Event.CHANGE, selectItem);
				this.listSprie.addChild(checkBox);
				this.checkBoxes.push(checkBox);

				y += ELEMENT_HEIGHT;
			}

			this.scrollPaneList.update();
		}

		private function updateView(e:Event = null):void
		{
			var playersIds:Array = [];

			for (var i:int = 0; i < this.data.length; i++)
			{
				if (this.data[i].player == null)
				{
					if (this.requstedIds.indexOf(this.data[i].playerId) != -1)
						continue;

					playersIds.push(this.data[i].playerId);
					continue;
				}

				this.places[i].visible = true;
				this.checkBoxes[i].selected = this.data[i].selected;
				this.places[i].fieldLevel.text = "[" + this.data[i].level + "]";
				this.places[i].fieldData.text = DateUtil.getFormatedDate(this.data[i].time);

				PlayerUtil.formatName(this.places[i].fieldName, this.data[i].player, 122, true, true, true);
			}

			this.requstedIds = this.requstedIds.concat(playersIds);

			if (playersIds.length != 0)
				Game.request(playersIds, PlayerInfoParser.NAME | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.CLAN);
		}

		private function onSelectAll(e:Event):void
		{
			for (var i:int = 0; i < this.data.length; i++)
				this.data[i].selected = this.selectAll.selected;

			updateView();
		}

		private function selectItem(e:Event):void
		{
			this.data[int(e.currentTarget.name)].selected = Boolean(e.currentTarget.selected);
		}

		private function showMenu(e:MouseEvent):void
		{
			var playerId:int = this.data[int(e.target.parent.name)].playerId;
			MenuProfile.showMenu(playerId);
		}

		private function filterFunction(item:ClanApplication, index:int, parentArray:Vector.<ClanApplication>):Boolean
		{
			if (parentArray) {/*unused*/}

			if (item.selected)
			{
				index = this.requstedIds.indexOf(item.playerId);
				if (index != -1)
					this.requstedIds.splice(index, 1);

				item.removeEventListener("LOADED", updateView);
			}

			return !item.selected;
		}
	}
}