package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 67
	public class PacketClothesSlot extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 67;

		public var status: int = -1;
		public var packageId: int = -1;
		public var skillId: int = -1;

		public function PacketClothesSlot(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 67;

			if (buffer === null)
				return;

			status = buffer.readByte();
			packageId = buffer.readShort();
			skillId = buffer.readShort();
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

			status = array[0];
			packageId = array[1];
			skillId = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeShort(packageId);
			buffer.writeShort(skillId);
		}
	}
}