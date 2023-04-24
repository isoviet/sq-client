package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketClanPrivateRoomsItems extends AbstractServerPacket
	{
		public var roomId: int = -1;
		public var locationId: int = -1;
		public var sublocationId: int = -1;
		public var playersCount: int = -1;
		public var modes: int = -1;

		public function PacketClanPrivateRoomsItems(buffer: ByteArray)
		{
			roomId = buffer.readInt();
			locationId = buffer.readByte();
			sublocationId = buffer.readByte();
			playersCount = buffer.readByte();
			modes = buffer.readShort();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(roomId);
			buffer.writeByte(locationId);
			buffer.writeByte(sublocationId);
			buffer.writeByte(playersCount);
			buffer.writeShort(modes);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			roomId = array[0];
			locationId = array[1];
			sublocationId = array[2];
			playersCount = array[3];
			modes = array[4];
		}
	}
}