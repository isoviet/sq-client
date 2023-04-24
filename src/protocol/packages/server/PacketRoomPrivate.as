package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 72
	public class PacketRoomPrivate extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 72;

		public var status: int = -1;
		public var roomId: int = -1;

		public function PacketRoomPrivate(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 72;

			if (buffer === null)
				return;

			status = buffer.readByte();
			roomId = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer = new ByteArray();

			innerBuild(buffer);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			status = array[0];
			roomId = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(roomId);
		}
	}
}