package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 5
	public class PacketAdminMessage extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 5;

		public var message: String = "";

		public function PacketAdminMessage(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 5;

			if (buffer === null)
				return;

			message = readS(buffer);
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

			message = array[0];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeUTF(message);
		}
	}
}