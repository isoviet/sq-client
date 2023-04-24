package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 59
	public class PacketChatHistory extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 59;

		public var chatType: int = -1;
		public var messages: Vector.<PacketChatHistoryMessages> = null;

		public function PacketChatHistory(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 59;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			chatType = buffer.readByte();
			// messages initialization
			countI = buffer.readInt();
			messages = new Vector.<PacketChatHistoryMessages>(countI);
			for (i = 0; i < countI; ++i)
				messages[i] = new PacketChatHistoryMessages(buffer);
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

			var i: int = 0;
			var countI: int = 0;

			chatType = array[0];
			// messages initialization
			countI = array[1].length;
			messages = new Vector.<PacketChatHistoryMessages>(countI);
			for (i = 0; i < countI; ++i)
				messages[i] = new PacketChatHistoryMessages(array[1]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(chatType);
			// messages writing
			countI = messages.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				messages[i].build(buffer);
		}
	}
}