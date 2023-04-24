package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 90
	public class PacketRoundSkillShaman extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 90;

		public var playerId: int = -1;
		public var type: int = -1;
		public var state: int = -1;

		public function PacketRoundSkillShaman(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 90;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			type = buffer.readByte();
			state = buffer.readByte();
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

			playerId = array[0];
			type = array[1];
			state = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeByte(type);
			buffer.writeByte(state);
		}
	}
}