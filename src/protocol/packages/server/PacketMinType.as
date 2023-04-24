package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 0
	public class PacketMinType extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 0;
		public function PacketMinType(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 0;

			if (buffer === null)
				return;
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
		}

		override protected function innerBuild(buffer: ByteArray): void
		{

		}
	}
}