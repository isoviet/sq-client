package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketExpirationsItems extends AbstractServerPacket
	{
		public var type: int = -1;
		public var exists: int = -1;
		public var duration: int = -1;

		public function PacketExpirationsItems(buffer: ByteArray)
		{
			type = buffer.readByte();
			exists = buffer.readByte();
			duration = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(type);
			buffer.writeByte(exists);
			buffer.writeInt(duration);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			type = array[0];
			exists = array[1];
			duration = array[2];
		}
	}
}