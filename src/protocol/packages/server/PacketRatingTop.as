package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 52
	public class PacketRatingTop extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 52;

		public var ratingType: int = -1;
		public var elements: Vector.<int> = null;

		public function PacketRatingTop(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 52;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			ratingType = buffer.readByte();
			// elements initialization
			countI = buffer.readInt();
			elements = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				elements[i] = buffer.readInt();
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

			ratingType = array[0];
			// elements initialization
			countI = array[1].length;
			elements = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				elements[i] = array[1][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(ratingType);
			// elements writing
			countI = elements.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(elements[i]);
		}
	}
}