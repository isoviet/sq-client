package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 47
	public class PacketHolidayBalance extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 47;

		public var elements: int = -1;
		public var tickets: int = -1;
		public var rating: int = -1;

		public function PacketHolidayBalance(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 47;

			if (buffer === null)
				return;

			elements = buffer.readShort();
			tickets = buffer.readByte();
			rating = buffer.readInt();
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

			elements = array[0];
			tickets = array[1];
			rating = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeShort(elements);
			buffer.writeByte(tickets);
			buffer.writeInt(rating);
		}
	}
}