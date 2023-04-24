package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 9
	public class PacketInfoNet extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 9;

		public var data: ByteArray = null;
		public var mask: int = -1;

		public function PacketInfoNet(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 9;

			if (buffer === null)
				return;

			data = readA(buffer);
			mask = buffer.readInt();
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
			mask = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			writeA(buffer, data);
			buffer.writeInt(mask);
		}
	}
}