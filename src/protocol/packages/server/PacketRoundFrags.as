package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 81
	public class PacketRoundFrags extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 81;

		public var redFrags: int = -1;
		public var blueFrags: int = -1;

		public function PacketRoundFrags(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 81;

			if (buffer === null)
				return;

			redFrags = buffer.readInt();
			blueFrags = buffer.readInt();
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

			redFrags = array[0];
			blueFrags = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(redFrags);
			buffer.writeInt(blueFrags);
		}
	}
}