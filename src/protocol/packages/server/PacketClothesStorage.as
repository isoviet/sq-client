package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 63
	public class PacketClothesStorage extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 63;

		public var packages: Vector.<PacketClothesStoragePackages> = null;
		public var accessories: Vector.<PacketClothesStorageAccessories> = null;

		public function PacketClothesStorage(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 63;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// packages initialization
			countI = buffer.readInt();
			packages = new Vector.<PacketClothesStoragePackages>(countI);
			for (i = 0; i < countI; ++i)
				packages[i] = new PacketClothesStoragePackages(buffer);
			// accessories initialization
			countI = buffer.readInt();
			accessories = new Vector.<PacketClothesStorageAccessories>(countI);
			for (i = 0; i < countI; ++i)
				accessories[i] = new PacketClothesStorageAccessories(buffer);
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

			// packages initialization
			countI = array[0].length;
			packages = new Vector.<PacketClothesStoragePackages>(countI);
			for (i = 0; i < countI; ++i)
				packages[i] = new PacketClothesStoragePackages(array[0]);
			// accessories initialization
			countI = array[1].length;
			accessories = new Vector.<PacketClothesStorageAccessories>(countI);
			for (i = 0; i < countI; ++i)
				accessories[i] = new PacketClothesStorageAccessories(array[1]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// packages writing
			countI = packages.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				packages[i].build(buffer);
			// accessories writing
			countI = accessories.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				accessories[i].build(buffer);
		}
	}
}