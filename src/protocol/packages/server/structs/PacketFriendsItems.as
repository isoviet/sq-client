package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketFriendsItems extends AbstractServerPacket
	{
		public var friend: int = -1;
		public var removed: int = -1;

		public function PacketFriendsItems(buffer: ByteArray)
		{
			friend = buffer.readInt();
			removed = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(friend);
			buffer.writeByte(removed);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			friend = array[0];
			removed = array[1];
		}
	}
}