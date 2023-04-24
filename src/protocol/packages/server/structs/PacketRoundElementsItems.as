package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketRoundElementsItems extends AbstractServerPacket
	{
		public var kind: int = -1;
		public var unsignedElementId: uint = NaN;

		public function PacketRoundElementsItems(buffer: ByteArray)
		{
			kind = buffer.readByte();
			unsignedElementId = readUnsignedByte(buffer);
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(kind);
			buffer.writeByte(unsignedElementId);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			kind = array[0];
			unsignedElementId = array[1];
		}
	}
}