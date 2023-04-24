package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 26
	public class PacketInvite extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 26;

		public var status: int = -1;
		public var playerId: int = -1;

		public function PacketInvite(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 26;

			if (buffer === null)
				return;

			status = buffer.readByte();
			playerId = buffer.readInt();
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
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(playerId);
		}
	}
}