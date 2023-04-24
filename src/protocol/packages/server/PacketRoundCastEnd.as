package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 75
	public class PacketRoundCastEnd extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 75;

		public var playerId: int = -1;
		public var castType: int = -1;
		public var itemId: int = -1;
		public var success: int = -1;

		public function PacketRoundCastEnd(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 75;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			castType = buffer.readByte();
			itemId = buffer.readByte();
			success = buffer.readByte();
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
			castType = array[1];
			itemId = array[2];
			success = array[3];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeByte(castType);
			buffer.writeByte(itemId);
			buffer.writeByte(success);
		}
	}
}