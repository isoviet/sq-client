package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 13
	public class PacketBan extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 13;

		public var targetId: int = -1;
		public var type: int = -1;
		public var reason: int = -1;
		public var moderatorId: int = -1;
		public var duration: int = -1;

		public function PacketBan(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 13;

			if (buffer === null)
				return;

			targetId = buffer.readInt();
			type = buffer.readByte();
			reason = buffer.readByte();
			moderatorId = buffer.readInt();
			duration = buffer.readInt();
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

			targetId = array[0];
			type = array[1];
			reason = array[2];
			moderatorId = array[3];
			duration = array[4];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(targetId);
			buffer.writeByte(type);
			buffer.writeByte(reason);
			buffer.writeInt(moderatorId);
			buffer.writeInt(duration);
		}
	}
}