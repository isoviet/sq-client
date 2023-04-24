package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 12
	public class PacketPlayWith extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 12;

		public var type: int = -1;

		// optional
		public var locationId: int = -1;
		public var subLocation: int = -1;
		public var roomId: int = -1;

		public function PacketPlayWith(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 12;

			if (buffer === null)
				return;

			type = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				locationId = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				subLocation = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				roomId = buffer.readInt();

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

			locationId = array[1];
			if (arraySize < 2)
				return;

			subLocation = array[2];
			if (arraySize < 3)
				return;

			roomId = array[3];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(type);

			// optional
			buffer.writeByte(locationId);
			buffer.writeByte(subLocation);
			buffer.writeInt(roomId);
		}
	}
}