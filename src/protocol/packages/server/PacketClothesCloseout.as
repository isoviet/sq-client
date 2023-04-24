package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 64
	public class PacketClothesCloseout extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 64;

		public var expirationTime: int = -1;
		public var packages: Vector.<int> = null;

		public function PacketClothesCloseout(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 64;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			expirationTime = buffer.readInt();
			// packages initialization
			countI = buffer.readInt();
			packages = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				packages[i] = buffer.readShort();
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

			expirationTime = array[0];
			// packages initialization
			countI = array[1].length;
			packages = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				packages[i] = array[1][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeInt(expirationTime);
			// packages writing
			countI = packages.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeShort(packages[i]);
		}
	}
}