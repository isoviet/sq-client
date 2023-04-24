package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketGiftsItems extends AbstractServerPacket
	{
		public var id: int = -1;
		public var type: int = -1;
		public var senderId: int = -1;
		public var time: int = -1;

		public function PacketGiftsItems(buffer: ByteArray)
		{
			id = buffer.readInt();
			type = buffer.readByte();
			senderId = buffer.readInt();
			time = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(id);
			buffer.writeByte(type);
			buffer.writeInt(senderId);
			buffer.writeInt(time);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			id = array[0];
			type = array[1];
			senderId = array[2];
			time = array[3];
		}
	}
}