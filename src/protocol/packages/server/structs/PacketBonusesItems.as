package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketBonusesItems extends AbstractServerPacket
	{
		public var itemId: int = -1;
		public var count: int = -1;

		public function PacketBonusesItems(buffer: ByteArray)
		{
			itemId = buffer.readByte();
			count = buffer.readShort();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(itemId);
			buffer.writeShort(count);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			itemId = array[0];
			count = array[1];
		}
	}
}