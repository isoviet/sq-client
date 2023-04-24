package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketClothesWearItems extends AbstractServerPacket
	{
		public var kind: int = -1;
		public var clothesId: int = -1;
		public var isWeared: Boolean = false;

		public function PacketClothesWearItems(buffer: ByteArray)
		{
			kind = buffer.readByte();
			clothesId = buffer.readShort();
			isWeared = Boolean(buffer.readByte());
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(kind);
			buffer.writeShort(clothesId);
			buffer.writeByte(int(isWeared));

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			kind = array[0];
			clothesId = array[1];
			isWeared = array[2];
		}
	}
}