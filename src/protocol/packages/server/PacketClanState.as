package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 101
	public class PacketClanState extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 101;

		public var status: int = -1;

		// optional
		public var clanId: int = -1;

		public function PacketClanState(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 101;

			if (buffer === null)
				return;

			status = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				clanId = buffer.readInt();

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

			clanId = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);

			// optional
			buffer.writeInt(clanId);
		}
	}
}