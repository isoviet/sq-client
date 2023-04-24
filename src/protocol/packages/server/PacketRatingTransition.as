package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 51
	public class PacketRatingTransition extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 51;

		public var ratingType: int = -1;
		public var transitionType: int = -1;
		public var elementId: int = -1;

		public function PacketRatingTransition(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 51;

			if (buffer === null)
				return;

			ratingType = buffer.readByte();
			transitionType = buffer.readByte();
			elementId = buffer.readInt();
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
			transitionType = array[1];
			elementId = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(ratingType);
			buffer.writeByte(transitionType);
			buffer.writeInt(elementId);
		}
	}
}