package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 40
	public class PacketPromoBonus extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 40;

		public var state: int = -1;

		// optional
		public var type: int = -1;
		public var data: int = -1;

		public function PacketPromoBonus(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 40;

			if (buffer === null)
				return;

			state = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				type = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				data = buffer.readShort();

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

			state = array[0];

			// optional
			if (arraySize < 1)
				return;

			type = array[1];
			if (arraySize < 2)
				return;

			data = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(state);

			// optional
			buffer.writeByte(type);
			buffer.writeShort(data);
		}
	}
}