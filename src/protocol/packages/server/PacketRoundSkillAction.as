package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 89
	public class PacketRoundSkillAction extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 89;

		public var type: int = -1;
		public var playerId: int = -1;
		public var targetId: int = -1;

		// optional
		public var data: int = -1;

		public function PacketRoundSkillAction(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 89;

			if (buffer === null)
				return;

			type = buffer.readByte();
			playerId = buffer.readInt();
			targetId = buffer.readInt();

			// optional
			if (buffer.bytesAvailable > 0)
				data = buffer.readInt();

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

			type = array[0];
			playerId = array[1];
			targetId = array[2];

			// optional
			if (arraySize < 3)
				return;

			data = array[3];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(type);
			buffer.writeInt(playerId);
			buffer.writeInt(targetId);

			// optional
			buffer.writeInt(data);
		}
	}
}