package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketTrainingItems extends AbstractServerPacket
	{
		public var type: int = -1;
		public var value: int = -1;

		public function PacketTrainingItems(buffer: ByteArray)
		{
			type = buffer.readByte();
			value = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(type);
			buffer.writeByte(value);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			type = array[0];
			value = array[1];
		}
	}
}