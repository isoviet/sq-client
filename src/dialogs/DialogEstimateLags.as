package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import fl.controls.List;

	import game.mainGame.gameEditor.MapData;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketMapsMap;

	import utils.MapLagsEstimator;

	public class DialogEstimateLags extends Dialog
	{
		static private const OFFSET_X:int = 10;

		static private var _instance:DialogEstimateLags = null;

		private var list:List = new List();
		private var listItems:Object = {};
		private var mapIds:Array = null;

		private var fieldMapsCount:GameField = null;

		public function DialogEstimateLags():void
		{
			_instance = this;

			super(gls("Лаги карт"));

			init();
		}

		static public function show(maps:Array):void
		{
			if (!_instance)
				new DialogEstimateLags();

			_instance.mapIds = maps;
			_instance.show();
		}

		override public function show():void
		{
			super.show();

			this.list.removeAll();
			this.fieldMapsCount.text = "";

			Connection.listen(onPacket, PacketMapsMap.PACKET_ID);

			estimateLags(this.mapIds.pop());
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide(e);

			Connection.forget(onPacket, PacketMapsMap.PACKET_ID);
		}

		private function init():void
		{
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

			place();

			this.width += 25;
			this.height += 95;

			this.fieldMapsCount = new GameField("", OFFSET_X, this.list.y + 180, new TextFormat(null, 12, 0x000000));
			addChild(this.fieldMapsCount);
		}

		private function estimateLags(map:Object):void
		{
			var mapId:int = String(map['label']).split(" ")[0];
			var item:Object = {'label': mapId};
			this.listItems[mapId] = item;
			Connection.sendData(PacketClient.MAPS_GET, mapId);
		}

		private function onEstimate(mapId:int, lagsIndex:int):void
		{
			this.listItems[mapId]['label'] += gls("   Лаги: {0}", lagsIndex);
			if (lagsIndex >= MapLagsEstimator.LAGS_INDEX_TRESHOLD)
				this.listItems[mapId]['marked'] = true;
			this.listItems[mapId]['forSort'] = lagsIndex;
			this.list.addItem(this.listItems[mapId]);
			this.list.sortItemsOn("forSort", Array.DESCENDING | Array.NUMERIC);
			delete this.listItems[mapId];

			this.fieldMapsCount.text = gls("Кол-во непроверенных карт: {0}", this.mapIds.length);

			if (this.mapIds.length == 0)
			{
				this.fieldMapsCount.text = gls("Все карты проверены");
				return;
			}

			estimateLags(this.mapIds.pop());
		}

		private function onPacket(packet:PacketMapsMap):void
		{
			if (!(packet.id in this.listItems))
				return;

			var mapData:MapData = new MapData();
			mapData.number = packet.id;
			mapData.load(packet);

			MapLagsEstimator.estimateLags(mapData, onEstimate);
		}
	}
}