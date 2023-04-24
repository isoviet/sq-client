package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketLoginDiscounts extends AbstractServerPacket
	{
		public var type: int = -1;
		public var time: int = -1;

		public function PacketLoginDiscounts(buffer: ByteArray)
		{
			type = buffer.readByte();
			time = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(type);
			buffer.writeInt(time);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			type = array[0];
			time = array[1];
		}
	}
}