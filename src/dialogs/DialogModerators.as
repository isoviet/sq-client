package dialogs
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import fl.controls.List;

	import buttons.ButtonBase;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketMapsCheck;

	import utils.EditField;

	public class DialogModerators extends Dialog
	{
		static private const OFFSET_X:int = 10;

		static private var _instance:DialogModerators = null;

		private var list:List = new List();

		private var fieldCount:EditField = null;

		private var currentItems:Object = {};

		public function DialogModerators():void
		{
			_instance = this;

			super();

			init();

			Connection.listen(onPacket, PacketMapsCheck.PACKET_ID);
			Game.listen(onPlayerLoaded);
		}

		static public function show():void
		{
			if (!_instance)
				new DialogModerators();

			_instance.show();

			Connection.sendData(PacketClient.MAPS_CHECK);
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
			this.list.addEventListener(Event.CHANGE, updateCount);
			addChild(this.list);

			var format:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000);

			var fieldTitle:GameField = new GameField(gls("Проверено карт:"), OFFSET_X - 3, 210, format);
			addChild(fieldTitle);

			this.fieldCount = new EditField("", OFFSET_X, 230, 90, 15, format);
			addChild(this.fieldCount);

			var buttonSave:ButtonBase = new ButtonBase(gls("Начислить"));
			buttonSave.x = OFFSET_X + 100;
			buttonSave.y = 226;
			buttonSave.addEventListener(MouseEvent.CLICK, saveCount);
			addChild(buttonSave);

			place();

			this.width += 25;
			this.height += 40;
		}

		private function onPacket(packet:PacketMapsCheck):void
		{
			if (packet.items.length == 0)
				return;

			this.list.removeAll();
			this.currentItems = {};

			var ids:Array = [];

			for (var i:int = 0; i < packet.items.length; i++)
			{
				var item:Object = {'label': packet.items[i].innerId, 'value': packet.items[i].value};
				this.list.addItem(item);
				this.currentItems[packet.items[i].innerId] = item;
				ids.push(packet.items[i].innerId);
			}

			this.list.selectedIndex = 0;
			updateCount();

			Game.request(ids, PlayerInfoParser.NAME);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (!(player['id'] in this.currentItems))
				return;

			var item:Object = this.currentItems[player['id']];
			item['label'] = item['label'] + "     " + player.name;

			delete this.currentItems[player['id']];
		}

		private function updateCount(e:Event = null):void
		{
			this.fieldCount.text = this.list.selectedItem['value'];
		}

		private function saveCount(e:MouseEvent):void
		{
			if (!this.list.selectedItem || this.list.selectedItem['value'] < this.fieldCount.text)
				return;

			this.list.selectedItem['value'] = this.fieldCount.text;
			var label:String = this.list.selectedItem['label'];
			Connection.sendData(PacketClient.MAPS_CHECK, label.split("     ")[0], this.list.selectedItem['value']);
			Connection.sendData(PacketClient.MAPS_CHECK);
		}
	}
}