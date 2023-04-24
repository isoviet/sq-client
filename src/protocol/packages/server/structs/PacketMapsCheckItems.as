package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketMapsCheckItems extends AbstractServerPacket
	{
		public var innerId: int = -1;
		public var value: int = -1;

		public function PacketMapsCheckItems(buffer: ByteArray)
		{
			innerId = buffer.readInt();
			value = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(innerId);
			buffer.writeInt(value);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			innerId = array[0];
			value = array[1];
		}
	}
}