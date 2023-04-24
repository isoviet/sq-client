package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 79
	public class PacketRoundRespawn extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 79;

		public var status: int = -1;
		public var playerId: int = -1;
		public var respawnType: int = -1;

		public function PacketRoundRespawn(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 79;

			if (buffer === null)
				return;

			status = buffer.readByte();
			playerId = buffer.readInt();
			respawnType = buffer.readByte();
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
			respawnType = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(playerId);
			buffer.writeByte(respawnType);
		}
	}
}