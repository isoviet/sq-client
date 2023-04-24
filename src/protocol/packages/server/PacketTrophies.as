package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 46
	public class PacketTrophies extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 46;

		public var event: int = -1;
		public var subIndex: int = -1;
		public var trophy: int = -1;

		public function PacketTrophies(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 46;

			if (buffer === null)
				return;

			event = buffer.readByte();
			subIndex = buffer.readShort();
			trophy = buffer.readByte();
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

			event = array[0];
			subIndex = array[1];
			trophy = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(event);
			buffer.writeShort(subIndex);
			buffer.writeByte(trophy);
		}
	}
}