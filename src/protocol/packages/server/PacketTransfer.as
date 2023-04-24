package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 116
	public class PacketTransfer extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 116;

		public var status: int = -1;

		// optional
		public var playerId: int = -1;
		public var time: int = -1;

		public function PacketTransfer(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 116;

			if (buffer === null)
				return;

			status = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				playerId = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				time = buffer.readInt();

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

			// optional
			if (arraySize < 1)
				return;

			playerId = array[1];
			if (arraySize < 2)
				return;

			time = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);

			// optional
			buffer.writeInt(playerId);
			buffer.writeInt(time);
		}
	}
}