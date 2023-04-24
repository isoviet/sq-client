package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 113
	public class PacketDiscountClothes extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 113;

		public var clothes: Vector.<int> = null;

		public function PacketDiscountClothes(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 113;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// clothes initialization
			countI = buffer.readInt();
			clothes = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				clothes[i] = buffer.readShort();
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

			// clothes initialization
			countI = array[0].length;
			clothes = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				clothes[i] = array[0][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// clothes writing
			countI = clothes.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeShort(clothes[i]);
		}
	}
}