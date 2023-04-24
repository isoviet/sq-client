package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketStorageInfoItems extends AbstractServerPacket
	{
		public var type: int = -1;
		public var data: ByteArray = null;

		public function PacketStorageInfoItems(buffer: ByteArray)
		{
			type = buffer.readByte();
			data = readA(buffer);
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(type);
			writeA(buffer, data);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			type = array[0];
			data = array[1];
		}
	}
}