package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketReturnedFriendItems extends AbstractServerPacket
	{
		public var friendId: int = -1;
		public var success: int = -1;

		public function PacketReturnedFriendItems(buffer: ByteArray)
		{
			friendId = buffer.readInt();
			success = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(friendId);
			buffer.writeByte(success);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			friendId = array[0];
			success = array[1];
		}
	}
}