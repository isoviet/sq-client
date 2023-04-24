package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 109
	public class PacketClanLeave extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 109;

		public var playerId: int = -1;

		public function PacketClanLeave(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 109;

			if (buffer === null)
				return;

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

			playerId = array[0];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
		}
	}
}