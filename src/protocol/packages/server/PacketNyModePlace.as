package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 118
	public class PacketNyModePlace extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 118;

		public var status: int = -1;
		public var playerId: int = -1;
		public var count: int = -1;

		public function PacketNyModePlace(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 118;

			if (buffer === null)
				return;

			status = buffer.readByte();
			playerId = buffer.readInt();
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
			count = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(playerId);
			buffer.writeByte(count);
		}
	}
}