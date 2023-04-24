package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketCollectionsCollections extends AbstractServerPacket
	{
		public var type: int = -1;
		public var unsignedElementId: uint = NaN;
		public var count: int = -1;

		public function PacketCollectionsCollections(buffer: ByteArray)
		{
			type = buffer.readByte();
			unsignedElementId = readUnsignedByte(buffer);
			count = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(type);
			buffer.writeByte(unsignedElementId);
			buffer.writeInt(count);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			type = array[0];
			unsignedElementId = array[1];
			count = array[2];
		}
	}
}