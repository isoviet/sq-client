package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 95
	public class PacketRoundSmile extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 95;

		public var player: int = -1;
		public var smile: int = -1;

		public function PacketRoundSmile(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 95;

			if (buffer === null)
				return;

			player = buffer.readInt();
			smile = buffer.readByte();
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

			player = array[0];
			smile = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(player);
			buffer.writeByte(smile);
		}
	}
}