package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 16
	public class PacketEnergyLimits extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 16;

		public var energy: int = -1;
		public var mana: int = -1;

		public function PacketEnergyLimits(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 16;

			if (buffer === null)
				return;

			energy = buffer.readInt();
			mana = buffer.readInt();
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
			mana = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(energy);
			buffer.writeInt(mana);
		}
	}
}