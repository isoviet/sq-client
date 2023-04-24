package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 74
	public class PacketRoundCastBegin extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 74;

		public var playerId: int = -1;
		public var itemId: int = -1;
		public var dataJson: Object = null;

		public function PacketRoundCastBegin(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 74;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			itemId = buffer.readByte();
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
			itemId = array[1];
			dataJson = convertStringJson(array[2]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeByte(itemId);
			buffer.writeUTF(by.blooddy.crypto.serialization.JSON.encode(dataJson));
		}
	}
}