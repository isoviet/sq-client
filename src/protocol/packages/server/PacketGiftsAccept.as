package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 55
	public class PacketGiftsAccept extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 55;

		public var status: int = -1;
		public var id: int = -1;

		// optional
		public var data: int = -1;

		public function PacketGiftsAccept(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 55;

			if (buffer === null)
				return;

			status = buffer.readByte();
			id = buffer.readInt();

			// optional
			if (buffer.bytesAvailable > 0)
				data = buffer.readByte();

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

			status = array[0];
			id = array[1];

			// optional
			if (arraySize < 2)
				return;

			data = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(id);

			// optional
			buffer.writeByte(data);
		}
	}
}