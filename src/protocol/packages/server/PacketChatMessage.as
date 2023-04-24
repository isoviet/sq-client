package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 58
	public class PacketChatMessage extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 58;

		public var chatType: int = -1;
		public var playerId: int = -1;
		public var message: String = "";

		public function PacketChatMessage(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 58;

			if (buffer === null)
				return;

			chatType = buffer.readByte();
			playerId = buffer.readInt();
			message = readS(buffer);
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

			chatType = array[0];
			playerId = array[1];
			message = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(chatType);
			buffer.writeInt(playerId);
			buffer.writeUTF(message);
		}
	}
}