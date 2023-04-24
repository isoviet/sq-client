package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 44
	public class PacketCollections extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 44;

		public var collections: Vector.<PacketCollectionsCollections> = null;

		public function PacketCollections(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 44;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// collections initialization
			countI = buffer.readInt();
			collections = new Vector.<PacketCollectionsCollections>(countI);
			for (i = 0; i < countI; ++i)
				collections[i] = new PacketCollectionsCollections(buffer);
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

			// collections initialization
			countI = array[0].length;
			collections = new Vector.<PacketCollectionsCollections>(countI);
			for (i = 0; i < countI; ++i)
				collections[i] = new PacketCollectionsCollections(array[0]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// collections writing
			countI = collections.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				collections[i].build(buffer);
		}
	}
}