package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketAwardCountersItems extends AbstractServerPacket
	{
		public var counterId: int = -1;
		public var value: int = -1;

		public function PacketAwardCountersItems(buffer: ByteArray)
		{
			counterId = buffer.readByte();
			value = buffer.readShort();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(counterId);
			buffer.writeShort(value);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			counterId = array[0];
			value = array[1];
		}
	}
}