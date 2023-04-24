package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 117
	public class PacketNyModeTake extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 117;

		public var status: int = -1;
		public var playerId: int = -1;
		public var index: int = -1;
		public var count: int = -1;

		public function PacketNyModeTake(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 117;

			if (buffer === null)
				return;

			status = buffer.readByte();
			playerId = buffer.readInt();
			index = buffer.readByte();
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

			status = array[0];
			playerId = array[1];
			index = array[2];
			count = array[3];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(playerId);
			buffer.writeByte(index);
			buffer.writeByte(count);
		}
	}
}