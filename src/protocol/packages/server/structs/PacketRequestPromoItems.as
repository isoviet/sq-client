package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketRequestPromoItems extends AbstractServerPacket
	{
		public var code: String = "";
		public var bonus: int = -1;
		public var maxCount: int = -1;
		public var usedCount: int = -1;

		public function PacketRequestPromoItems(buffer: ByteArray)
		{
			code = readS(buffer);
			bonus = buffer.readByte();
			maxCount = buffer.readShort();
			usedCount = buffer.readShort();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeUTF(code);
			buffer.writeByte(bonus);
			buffer.writeShort(maxCount);
			buffer.writeShort(usedCount);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			code = array[0];
			bonus = array[1];
			maxCount = array[2];
			usedCount = array[3];
		}
	}
}