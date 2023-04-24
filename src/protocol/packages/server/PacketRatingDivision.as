package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 50
	public class PacketRatingDivision extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 50;

		public var ratingType: int = -1;
		public var newSeason: int = -1;
		public var time: int = -1;

		// optional
		public var divisionId: int = -1;
		public var elementsId: Vector.<int> = null;

		public function PacketRatingDivision(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 50;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			ratingType = buffer.readByte();
			newSeason = buffer.readByte();
			time = buffer.readInt();

			// optional
			if (buffer.bytesAvailable > 0)
				divisionId = buffer.readInt();

			if (buffer.bytesAvailable > 0)
			{
				// elementsId initialization
				countI = buffer.readInt();
				elementsId = new Vector.<int>(countI);
				for (i = 0; i < countI; ++i)
					elementsId[i] = buffer.readInt();
			}

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
			newSeason = array[1];
			time = array[2];

			// optional
			if (arraySize < 3)
				return;

			divisionId = array[3];
			if (arraySize < 4)
				return;

			// elementsId initialization
			countI = array[4].length;
			elementsId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				elementsId[i] = array[4][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(ratingType);
			buffer.writeByte(newSeason);
			buffer.writeInt(time);

			// optional
			buffer.writeInt(divisionId);
			if (elementsId === null)
				return;
			// elementsId writing
			countI = elementsId.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(elementsId[i]);
		}
	}
}