package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketClothesStorageAccessories extends AbstractServerPacket
	{
		public var id: int = -1;
		public var isWeared: Boolean = false;
		public var awardReason: int = -1;

		public function PacketClothesStorageAccessories(buffer: ByteArray)
		{
			id = buffer.readShort();
			isWeared = Boolean(buffer.readByte());
			awardReason = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(id);
			buffer.writeByte(int(isWeared));
			buffer.writeByte(awardReason);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			id = array[0];
			isWeared = array[1];
			awardReason = array[2];
		}
	}
}