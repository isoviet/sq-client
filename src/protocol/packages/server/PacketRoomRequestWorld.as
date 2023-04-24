package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 70
	public class PacketRoomRequestWorld extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 70;

		public var targetId: int = -1;

		public function PacketRoomRequestWorld(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 70;

			if (buffer === null)
				return;

			targetId = buffer.readInt();
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

			targetId = array[0];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(targetId);
		}
	}
}