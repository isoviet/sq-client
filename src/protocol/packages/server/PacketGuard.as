package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 2
	public class PacketGuard extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 2;

		public var data: ByteArray = null;

		public function PacketGuard(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 2;

			if (buffer === null)
				return;

			data = readA(buffer);
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

			data = array[0];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			writeA(buffer, data);
		}
	}
}