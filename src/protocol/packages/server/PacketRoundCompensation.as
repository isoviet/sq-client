package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 92
	public class PacketRoundCompensation extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 92;

		public var type: int = -1;
		public var amount: int = -1;

		public function PacketRoundCompensation(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 92;

			if (buffer === null)
				return;

			type = buffer.readByte();
			amount = buffer.readInt();
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

			type = array[0];
			amount = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(type);
			buffer.writeInt(amount);
		}
	}
}