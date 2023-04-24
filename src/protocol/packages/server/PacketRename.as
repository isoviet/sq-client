package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 30
	public class PacketRename extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 30;

		public var status: int = -1;

		public function PacketRename(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 30;

			if (buffer === null)
				return;

			status = buffer.readByte();
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
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
		}
	}
}