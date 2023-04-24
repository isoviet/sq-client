package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 62
	public class PacketCollectionPickup extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 62;

		public var unsignedElementId: uint = NaN;
		public var count: int = -1;

		public function PacketCollectionPickup(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 62;

			if (buffer === null)
				return;

			unsignedElementId = readUnsignedByte(buffer);
			count = buffer.readByte();
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

			unsignedElementId = array[0];
			count = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(unsignedElementId);
			buffer.writeByte(count);
		}
	}
}