package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 41
	public class PacketBundles extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 41;

		public var type: int = -1;
		public var collections: Vector.<int> = null;
		public var packages: Vector.<PacketBundlesPackages> = null;

		public function PacketBundles(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 41;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			type = buffer.readByte();
			// collections initialization
			countI = buffer.readInt();
			collections = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				collections[i] = buffer.readByte();
			// packages initialization
			countI = buffer.readInt();
			packages = new Vector.<PacketBundlesPackages>(countI);
			for (i = 0; i < countI; ++i)
				packages[i] = new PacketBundlesPackages(buffer);
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

			type = array[0];
			// collections initialization
			countI = array[1].length;
			collections = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				collections[i] = array[1][i];
			// packages initialization
			countI = array[2].length;
			packages = new Vector.<PacketBundlesPackages>(countI);
			for (i = 0; i < countI; ++i)
				packages[i] = new PacketBundlesPackages(array[2]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(type);
			// collections writing
			countI = collections.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeByte(collections[i]);
			// packages writing
			countI = packages.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				packages[i].build(buffer);
		}
	}
}