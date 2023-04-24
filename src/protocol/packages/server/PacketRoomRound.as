package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 71
	public class PacketRoomRound extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 71;

		public var type: int = -1;

		// optional
		public var delay: int = -1;
		public var mapId: int = -1;
		public var mode: int = -1;
		public var mapAuthor: int = -1;
		public var mapDuration: int = -1;
		public var mapData: ByteArray = null;
		public var rating: int = -1;

		public function PacketRoomRound(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 71;

			if (buffer === null)
				return;

			type = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				delay = buffer.readShort();

			if (buffer.bytesAvailable > 0)
				mapId = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				mode = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				mapAuthor = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				mapDuration = buffer.readShort();

			if (buffer.bytesAvailable > 0)
				mapData = readA(buffer);

			if (buffer.bytesAvailable > 0)
				rating = buffer.readInt();

		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer = new ByteArray();

			innerBuild(buffer);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			type = array[0];

			// optional
			if (arraySize < 1)
				return;

			delay = array[1];
			if (arraySize < 2)
				return;

			mapId = array[2];
			if (arraySize < 3)
				return;

			mode = array[3];
			if (arraySize < 4)
				return;

			mapAuthor = array[4];
			if (arraySize < 5)
				return;

			mapDuration = array[5];
			if (arraySize < 6)
				return;

			mapData = array[6];
			if (arraySize < 7)
				return;

			rating = array[7];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(type);

			// optional
			buffer.writeShort(delay);
			buffer.writeInt(mapId);
			buffer.writeByte(mode);
			buffer.writeInt(mapAuthor);
			buffer.writeShort(mapDuration);
			if (mapData === null)
				return;
			writeA(buffer, mapData);
			buffer.writeInt(rating);
		}
	}
}