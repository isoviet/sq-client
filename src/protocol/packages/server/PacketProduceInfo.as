package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 36
	public class PacketProduceInfo extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 36;

		public var type: int = -1;
		public var timeLeft: int = -1;
		public var timeBonus: int = -1;

		public function PacketProduceInfo(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 36;

			if (buffer === null)
				return;

			type = buffer.readByte();
			timeLeft = buffer.readInt();
			timeBonus = buffer.readInt();
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
			timeLeft = array[1];
			timeBonus = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(type);
			buffer.writeInt(timeLeft);
			buffer.writeInt(timeBonus);
		}
	}
}