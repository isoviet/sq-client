package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 111
	public class PacketClanTotemBonus extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 111;

		public var totemId: int = -1;

		// optional
		public var bonus: int = -1;

		public function PacketClanTotemBonus(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 111;

			if (buffer === null)
				return;

			totemId = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				bonus = buffer.readShort();

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

			totemId = array[0];

			// optional
			if (arraySize < 1)
				return;

			bonus = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(totemId);

			// optional
			buffer.writeShort(bonus);
		}
	}
}