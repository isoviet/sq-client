package tape
{
	import flash.events.MouseEvent;

	import screens.ScreenGame;
	import tape.TapeData;

	import protocol.packages.server.structs.PacketClanPrivateRoomsItems;

	public class TapePrivateRoomData extends TapeData
	{
		static private const ROOM_BUTTONS:Object = {
			0: IslandsClanRoomButton,
			1: MountClanRoomButton,
			2: SwampClanRoomButton,
			3: DesertClanRoomButton,
			4: AnomalClanRoomButton,
			9: HardClanRoomButton,
			10: BattleClanRoomButton,
			13: StormClanRoomButton
		};

		private var rooms:Vector.<PacketClanPrivateRoomsItems>;

		public function TapePrivateRoomData()
		{
			super(TapePrivateRoomElement);
		}

		public function loadData(rooms: Vector.<PacketClanPrivateRoomsItems>):void
		{
			this.rooms = rooms;

			updateData();
		}

		public function addData(room: PacketClanPrivateRoomsItems):void
		{
			if (this.rooms == null)
				this.rooms = new Vector.<PacketClanPrivateRoomsItems>();

			this.rooms.push(room);

			updateData();
		}

		public function clearData():void
		{
			this.rooms = null;

			updateData();
		}

		public function deleteData(id:int):void
		{
			for each (var room:PacketClanPrivateRoomsItems in rooms)
			{
				if (room.roomId != id)
					return;

				this.rooms.splice(this.rooms.indexOf(room), 1);
			}

			updateData();
		}

		public function updateData():void
		{
			clear();
			this.rooms.sort(sortByType);

			for each (var room:PacketClanPrivateRoomsItems in rooms)
			{
				var element:TapePrivateRoomElement = new TapePrivateRoomElement(room.roomId, room.locationId, room.playersCount, room.modes, new ROOM_BUTTONS[room.locationId]());
				element.addEventListener(MouseEvent.CLICK, onSelectRoom);
				addObject(element);
			}
		}

		public function get roomsInfo():Vector.<PacketClanPrivateRoomsItems>
		{
			return this.rooms;
		}

		public function roomExist(id:int):Boolean
		{
			for each (var room:PacketClanPrivateRoomsItems in this.rooms)
			{
				if (room.roomId == id)
					return true;
			}
			return false;
		}

		override public function clear():void
		{
			super.clear();
		}

		private function onSelectRoom(e:MouseEvent):void
		{
			var room:TapePrivateRoomElement = e.currentTarget as TapePrivateRoomElement;

			ScreenGame.startPrivateRoom(room.id, room.type);
		}

		private function sortByType(a:PacketClanPrivateRoomsItems, b:PacketClanPrivateRoomsItems):int
		{
			if (a.locationId < b.locationId)
				return -1;

			if (a.locationId > b.locationId)
				return 1;

			if (a.roomId < b.roomId)
				return -1;

			return 1;
		}
	}
}