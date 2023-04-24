package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 66
	public class PacketClothesExpired extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 66;

		public var packageId: Vector.<int> = null;

		public function PacketClothesExpired(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 66;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// packageId initialization
			countI = buffer.readInt();
			packageId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				packageId[i] = buffer.readShort();
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

			var i: int = 0;
			var countI: int = 0;

			// packageId initialization
			countI = array[0].length;
			packageId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				packageId[i] = array[0][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// packageId writing
			countI = packageId.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeShort(packageId[i]);
		}
	}
}