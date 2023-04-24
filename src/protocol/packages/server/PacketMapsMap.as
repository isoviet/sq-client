package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 98
	public class PacketMapsMap extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 98;

		public var id: int = -1;
		public var mode: int = -1;
		public var authorId: int = -1;
		public var duration: int = -1;
		public var data: ByteArray = null;
		public var positiveRating: int = -1;
		public var negativeRating: int = -1;
		public var exitRating: int = -1;
		public var deadExits: int = -1;
		public var playsCount: int = -1;
		public var hollowCount: int = -1;

		public function PacketMapsMap(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 98;

			if (buffer === null)
				return;

			id = buffer.readInt();
			mode = buffer.readByte();
			authorId = buffer.readInt();
			duration = buffer.readShort();
			data = readA(buffer);
			positiveRating = buffer.readInt();
			negativeRating = buffer.readInt();
			exitRating = buffer.readInt();
			deadExits = buffer.readInt();
			playsCount = buffer.readInt();
			hollowCount = buffer.readInt();
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

			id = array[0];
			mode = array[1];
			authorId = array[2];
			duration = array[3];
			data = array[4];
			positiveRating = array[5];
			negativeRating = array[6];
			exitRating = array[7];
			deadExits = array[8];
			playsCount = array[9];
			hollowCount = array[10];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(id);
			buffer.writeByte(mode);
			buffer.writeInt(authorId);
			buffer.writeShort(duration);
			writeA(buffer, data);
			buffer.writeInt(positiveRating);
			buffer.writeInt(negativeRating);
			buffer.writeInt(exitRating);
			buffer.writeInt(deadExits);
			buffer.writeInt(playsCount);
			buffer.writeInt(hollowCount);
		}
	}
}