package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 93
	public class PacketRoundElement extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 93;

		public var playerId: int = -1;
		public var kind: int = -1;
		public var unsignedElementId: uint = NaN;
		public var index: int = -1;

		public function PacketRoundElement(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 93;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			kind = buffer.readByte();
			unsignedElementId = readUnsignedByte(buffer);
			index = buffer.readByte();
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
			kind = array[1];
			unsignedElementId = array[2];
			index = array[3];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeByte(kind);
			buffer.writeByte(unsignedElementId);
			buffer.writeByte(index);
		}
	}
}