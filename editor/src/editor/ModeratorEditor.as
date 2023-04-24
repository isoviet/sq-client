package editor
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.forms.DataForm;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketAdminInfo;

	public class ModeratorEditor extends Sprite
	{
		private var fileLoad:FileReference = new FileReference();

		private var players:Object = {};
		private var fields:Object = {};
		private var payment:Object = {};

		private var lastY:int = 20;

		private var totalCount:int = 0;
		private var currentCount:int = 0;

		public function ModeratorEditor()
		{
			var link:EditorField = new EditorField("<body><a href='event:#'>Выбрать файл</a></body>", 10, 0, Formats.style);
			link.addEventListener(MouseEvent.CLICK, selectFile);
			addChild(link);

			link = new EditorField("<body><a href='event:#'>Начислить</a></body>", 150, 0, Formats.style);
			link.addEventListener(MouseEvent.CLICK, paySalary);
			addChild(link);

			Connection.listen(onPacket, PacketAdminInfo.PACKET_ID)
		}

		private function selectFile(e:MouseEvent):void
		{
			this.fileLoad.addEventListener(Event.SELECT, onSelect);
			this.fileLoad.browse();
		}

		private function onSelect(e:Event):void
		{
			this.fileLoad.addEventListener(Event.COMPLETE, onLoaded);
			this.fileLoad.load();
		}

		private function onLoaded(e:Event):void
		{
			this.fileLoad.data.position = 0;

			var data:String = this.fileLoad.data.toString();
			var array:Array = data.split("\n");

			this.totalCount = array.length;
			this.currentCount = 0;

			for (var i:int = 0; i < array.length; i++)
			{
				var record:Array = (array[i] as String).split("\t");
				players[record[0]] = record[1];

				Connection.sendData(PacketClient.ADMIN_REQUEST_INNER, record[0], DataForm.PROFILE);
				Connection.sendData(PacketClient.ADMIN_REQUEST_INNER, record[0], DataForm.COINS);
			}
		}

		private function paySalary(e:MouseEvent):void
		{
			if (this.totalCount != this.currentCount)
				return;
			for (var id:String in this.payment)
				Connection.sendData(PacketClient.ADMIN_EDIT_PLAYER, int(id), DataForm.COINS, this.payment[id]);
			this.payment = {};
			this.totalCount = 0;
		}

		private function addField(text:String, id:int, posX:int = 0):void
		{
			trace("addField", text);
			var field:TextField = new TextField();
			FormUtils.setTextField(field, this, posX, 0, 200, 18, 100);
			field.text = text;

			if (id in this.fields)
				field.y = this.fields[id];
			else
			{
				field.y = this.lastY;
				this.fields[id] = this.lastY;
				this.lastY += 20;
			}
		}

		private function onPacket(packet:PacketAdminInfo):void
		{
			if (!(packet.innerId in players))
				return;
			switch (packet.field)
			{
				case DataForm.PROFILE:
					packet.data.position = 0;
					var playerName:String = packet.data.readUTF();
					addField(playerName, packet.innerId);
					break;
				case DataForm.COINS:
					packet.data.position = 0;
					var coinsFree:int = packet.data.readInt();
					var coinsPaid:int = packet.data.readInt();

					var count:int = coinsFree + coinsPaid;
					addField(count.toString(), packet.innerId, 225);
					coinsFree += players[packet.innerId];
					count = coinsFree + coinsPaid;
					addField(count.toString(), packet.innerId, 325);

					var byteArray:ByteArray = new ByteArray();
					byteArray.endian = Endian.LITTLE_ENDIAN;
					byteArray.writeInt(coinsFree);

					delete players[packet.innerId];
					this.payment[packet.innerId] = byteArray;

					this.currentCount++;
					break;
			}
		}
	}
}