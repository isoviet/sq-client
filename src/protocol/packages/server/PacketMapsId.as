package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 99
	public class PacketMapsId extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 99;

		public var id: int = -1;

		// optional
		public var locationId: int = -1;
		public var sublocationId: int = -1;

		public function PacketMapsId(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 99;

			if (buffer === null)
				return;

			id = buffer.readInt();

			// optional
			if (buffer.bytesAvailable > 0)
				locationId = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				sublocationId = buffer.readByte();

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

			id = array[0];

			// optional
			if (arraySize < 1)
				return;

			locationId = array[1];
			if (arraySize < 2)
				return;

			sublocationId = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(id);

			// optional
			buffer.writeByte(locationId);
			buffer.writeByte(sublocationId);
		}
	}
}