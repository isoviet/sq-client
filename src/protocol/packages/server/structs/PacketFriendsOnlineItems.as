package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketFriendsOnlineItems extends AbstractServerPacket
	{
		public var locationId: int = -1;
		public var count: int = -1;

		public function PacketFriendsOnlineItems(buffer: ByteArray)
		{
			locationId = buffer.readByte();
			count = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(locationId);
			buffer.writeByte(count);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			locationId = array[0];
			count = array[1];
		}
	}
}