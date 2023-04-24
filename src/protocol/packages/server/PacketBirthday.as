package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 33
	public class PacketBirthday extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 33;
		public function PacketBirthday(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 33;

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