package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 17
	public class PacketEnergy extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 17;

		public var energy: int = -1;
		public var reason: int = -1;

		public function PacketEnergy(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 17;

			if (buffer === null)
				return;

			energy = buffer.readInt();
			reason = buffer.readByte();
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

			energy = array[0];
			reason = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(energy);
			buffer.writeByte(reason);
		}
	}
}