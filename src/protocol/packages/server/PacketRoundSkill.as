package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 88
	public class PacketRoundSkill extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 88;

		public var playerId: int = -1;
		public var type: int = -1;
		public var state: int = -1;

		// optional
		public var data: int = -1;
		public var targetId: int = -1;
		public var scriptJson: Object = null;

		public function PacketRoundSkill(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 88;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			type = buffer.readByte();
			state = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				data = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				targetId = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				scriptJson = convertJsonString(buffer);

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

			// optional
			if (arraySize < 3)
				return;

			data = array[3];
			if (arraySize < 4)
				return;

			targetId = array[4];
			if (arraySize < 5)
				return;

			scriptJson = convertStringJson(array[5]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeByte(type);
			buffer.writeByte(state);

			// optional
			buffer.writeByte(data);
			buffer.writeInt(targetId);
			if (scriptJson === null)
				return;
			buffer.writeUTF(by.blooddy.crypto.serialization.JSON.encode(scriptJson));
		}
	}
}