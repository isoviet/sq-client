package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketMapsListMaps extends AbstractServerPacket
	{
		public var mapId: int = -1;
		public var markId: int = -1;
		public var playerId: int = -1;
		public var rating: int = -1;
		public var percentExit: int = -1;

		public function PacketMapsListMaps(buffer: ByteArray)
		{
			mapId = buffer.readInt();
			markId = buffer.readByte();
			playerId = buffer.readInt();
			rating = buffer.readInt();
			percentExit = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(mapId);
			buffer.writeByte(markId);
			buffer.writeInt(playerId);
			buffer.writeInt(rating);
			buffer.writeInt(percentExit);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			mapId = array[0];
			markId = array[1];
			playerId = array[2];
			rating = array[3];
			percentExit = array[4];
		}
	}
}