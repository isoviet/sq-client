package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketClothesStoragePackages extends AbstractServerPacket
	{
		public var id: int = -1;
		public var level: int = -1;
		public var expirationTime: int = -1;
		public var isWeared: Boolean = false;
		public var freeSlot: int = -1;
		public var awardReason: int = -1;

		public function PacketClothesStoragePackages(buffer: ByteArray)
		{
			id = buffer.readShort();
			level = buffer.readByte();
			expirationTime = buffer.readInt();
			isWeared = Boolean(buffer.readByte());
			freeSlot = buffer.readShort();
			awardReason = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(id);
			buffer.writeByte(level);
			buffer.writeInt(expirationTime);
			buffer.writeByte(int(isWeared));
			buffer.writeShort(freeSlot);
			buffer.writeByte(awardReason);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			id = array[0];
			level = array[1];
			expirationTime = array[2];
			isWeared = array[3];
			freeSlot = array[4];
			awardReason = array[5];
		}
	}
}