package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 76
	public class PacketRoundNut extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 76;

		public var playerId: int = -1;
		public var state: int = -1;

		public function PacketRoundNut(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 76;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			state = buffer.readByte();
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
			state = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeByte(state);
		}
	}
}