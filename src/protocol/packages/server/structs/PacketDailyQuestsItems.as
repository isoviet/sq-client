package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketDailyQuestsItems extends AbstractServerPacket
	{
		public var type: int = -1;
		public var location: int = -1;
		public var value: int = -1;
		public var time: int = -1;

		public function PacketDailyQuestsItems(buffer: ByteArray)
		{
			type = buffer.readByte();
			location = buffer.readByte();
			value = buffer.readByte();
			time = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(type);
			buffer.writeByte(location);
			buffer.writeByte(value);
			buffer.writeInt(time);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			type = array[0];
			location = array[1];
			value = array[2];
			time = array[3];
		}
	}
}