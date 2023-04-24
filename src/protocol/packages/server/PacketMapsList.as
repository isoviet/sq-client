package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 97
	public class PacketMapsList extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 97;

		public var locationId: int = -1;
		public var sublocationId: int = -1;
		public var mode: int = -1;
		public var maps: Vector.<PacketMapsListMaps> = null;
		public var totalCount: int = -1;

		public function PacketMapsList(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 97;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			locationId = buffer.readByte();
			sublocationId = buffer.readByte();
			mode = buffer.readByte();
			// maps initialization
			countI = buffer.readInt();
			maps = new Vector.<PacketMapsListMaps>(countI);
			for (i = 0; i < countI; ++i)
				maps[i] = new PacketMapsListMaps(buffer);
			totalCount = buffer.readInt();
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

			locationId = array[0];
			sublocationId = array[1];
			mode = array[2];
			// maps initialization
			countI = array[3].length;
			maps = new Vector.<PacketMapsListMaps>(countI);
			for (i = 0; i < countI; ++i)
				maps[i] = new PacketMapsListMaps(array[3]);
			totalCount = array[4];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(locationId);
			buffer.writeByte(sublocationId);
			buffer.writeByte(mode);
			// maps writing
			countI = maps.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				maps[i].build(buffer);
			buffer.writeInt(totalCount);
		}
	}
}