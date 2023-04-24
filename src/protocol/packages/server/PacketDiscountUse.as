package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 114
	public class PacketDiscountUse extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 114;

		public var discount: int = -1;
		public var data: int = -1;

		public function PacketDiscountUse(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 114;

			if (buffer === null)
				return;

			discount = buffer.readByte();
			data = buffer.readInt();
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

			discount = array[0];
			data = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(discount);
			buffer.writeInt(data);
		}
	}
}