package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 49
	public class PacketRatingScores extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 49;

		public var ratingType: int = -1;
		public var value: int = -1;

		public function PacketRatingScores(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 49;

			if (buffer === null)
				return;

			ratingType = buffer.readByte();
			value = buffer.readInt();
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

			ratingType = array[0];
			value = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(ratingType);
			buffer.writeInt(value);
		}
	}
}