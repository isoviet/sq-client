package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.controls.List;

	import game.mainGame.SquirrelGame;
	import game.mainGame.gameEditor.MapData;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketMapsMap;

	import utils.MapInvisiblesChecker;

	public class DialogFindInvisible extends Dialog
	{
		static private const OFFSET_X:int = 10;

		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				color: #000000;
			}
			.link {
				color: #000000;
				text-decoration: underline;
				font-size: 11px;
			}
		]]>).toString();

		static private var _instance:DialogFindInvisible = null;

		private var list:List = new List();
		private var listItems:Object = {};
		private var mapIds:Array = null;

		private var editLink:GameField = null;
		private var fieldMapsCount:GameField = null;

		private var locationId:int;
		private var subLocationId:int;

		public function DialogFindInvisible():void
		{
			_instance = this;

			super(gls("Невидимые объекты"));

			init();
		}

		static public function show(locationId:int, maps:Array, subLocationId:int):void
		{
			if (!_instance)
				new DialogFindInvisible();

			_instance.mapIds = maps;
			_instance.locationId = locationId;
			_instance.subLocationId = subLocationId;
			_instance.show();
		}

		override public function show():void
		{
			super.show();

			this.list.removeAll();
			this.fieldMapsCount.text = "";

			Connection.listen(onPacket, PacketMapsMap.PACKET_ID);

			checkInvisibles(this.mapIds.pop());
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide(e);

			Connection.forget(onPacket, PacketMapsMap.PACKET_ID);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var backgroundList:ListSkin = new ListSkin();
			backgroundList.x = OFFSET_X;
			backgroundList.y = 20;
			addChild(backgroundList);

			this.list.x = OFFSET_X;
			this.list.y = 26;
			this.list.setSize(197, 160);
			this.list.rowHeight = 13;
			this.list.setStyle("cellRenderer", ListStyleRendererLocation);
			addChild(this.list);

			this.fieldMapsCount = new GameField("", OFFSET_X, this.list.y + 165, new TextFormat(null, 12, 0x000000));
			addChild(this.fieldMapsCount);

			this.editLink = new GameField(gls("<body><a href='event:' class='link'>Редактировать</a></body>"), OFFSET_X + 120, this.fieldMapsCount.y, style);
			this.editLink.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			addChild(this.editLink);

			place();

			this.width += 25;
			this.height += 95;
		}

		private function checkInvisibles(map:Object):void
		{
			var mapId:int = String(map['label']).split(" ")[0];
			var item:Object = {'label': mapId, 'value': mapId};
			this.listItems[mapId] = item;
			Connection.sendData(PacketClient.MAPS_GET, mapId);
		}

		private function onCheck(mapId:int, invisiblesCount:int):void
		{
			if (invisiblesCount != 0)
			{
				this.listItems[mapId]['label'] += gls("   Невидимых: {0}", invisiblesCount);
				this.listItems[mapId]['forSort'] = invisiblesCount;

				this.list.addItem(this.listItems[mapId]);
				this.list.sortItemsOn("forSort", Array.DESCENDING | Array.NUMERIC);
			}

			delete this.listItems[mapId];
			this.fieldMapsCount.text = gls("Кол-во карт: {0}\nКол-во непроверенных карт: {1}", this.list.length, this.mapIds.length);

			if (this.mapIds.length == 0)
			{
				this.fieldMapsCount.text = gls("Кол-во карт: {0}\nВсе карты проверены", this.list.length);
				return;
			}

			checkInvisibles(this.mapIds.pop());
		}

		private function onPacket(packet:PacketMapsMap):void
		{
			if (!(packet.id in this.listItems))
				return;

			var mapData:MapData = new MapData();
			mapData.number = packet.id;
			mapData.load(packet);

			MapInvisiblesChecker.findInvisible(mapData, onCheck);
		}

		private function onClick(e:MouseEvent):void
		{
			var item:Object = this.list.selectedItem;
			if (item == null)
				return;

			(SquirrelGame.instance as SquirrelGameEditor).onOpen(this.locationId, item['value'], Locations.RELEASE_FOLDER_ID, this.subLocationId);
			DialogLocation.hideSelf();

			GameSounds.play(SoundConstants.CLICK);

			e.stopImmediatePropagation();
		}
	}
}