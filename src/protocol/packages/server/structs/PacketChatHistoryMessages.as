package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketChatHistoryMessages extends AbstractServerPacket
	{
		public var playerId: int = -1;
		public var message: String = "";

		public function PacketChatHistoryMessages(buffer: ByteArray)
		{
			playerId = buffer.readInt();
			message = readS(buffer);
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(playerId);
			buffer.writeUTF(message);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			playerId = array[0];
			message = array[1];
		}
	}
}