package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 34
	public class PacketOffers extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 34;

		public var offer: int = -1;

		public function PacketOffers(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 34;

			if (buffer === null)
				return;

			offer = buffer.readByte();
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

			offer = array[0];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(offer);
		}
	}
}