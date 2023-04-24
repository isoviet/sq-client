package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 54
	public class PacketGiftsTarget extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 54;

		public var ids: Vector.<int> = null;

		public function PacketGiftsTarget(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 54;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// ids initialization
			countI = buffer.readInt();
			ids = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				ids[i] = buffer.readInt();
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

			// ids initialization
			countI = array[0].length;
			ids = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				ids[i] = array[0][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// ids writing
			countI = ids.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(ids[i]);
		}
	}
}