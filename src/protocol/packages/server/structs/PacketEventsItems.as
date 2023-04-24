package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketEventsItems extends AbstractServerPacket
	{
		public var id: String = "0";
		public var type: int = -1;
		public var actorId: int = -1;
		public var data: int = -1;
		public var time: int = -1;

		public function PacketEventsItems(buffer: ByteArray)
		{
			id = (new UInt64(buffer)).toString();
			type = buffer.readByte();
			actorId = buffer.readInt();
			data = buffer.readInt();
			time = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			writeUInt64(id, buffer);
			buffer.writeByte(type);
			buffer.writeInt(actorId);
			buffer.writeInt(data);
			buffer.writeInt(time);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			id = array[0];
			type = array[1];
			actorId = array[2];
			data = array[3];
			time = array[4];
		}
	}
}