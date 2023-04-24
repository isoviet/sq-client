package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 91
	public class PacketRoundCommand extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 91;

		public var playerId: int = -1;
		public var dataJson: Object = null;

		public function PacketRoundCommand(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 91;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			dataJson = convertJsonString(buffer);
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
			dataJson = convertStringJson(array[1]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeUTF(by.blooddy.crypto.serialization.JSON.encode(dataJson));
		}
	}
}