package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 10
	public class PacketRoom extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 10;

		public var locationId: int = -1;
		public var subLocation: int = -1;
		public var players: Vector.<int> = null;
		public var isPrivate: Boolean = false;

		public function PacketRoom(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 10;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			locationId = buffer.readByte();
			subLocation = buffer.readByte();
			// players initialization
			countI = buffer.readInt();
			players = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				players[i] = buffer.readInt();
			isPrivate = Boolean(buffer.readByte());
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

			locationId = array[0];
			subLocation = array[1];
			// players initialization
			countI = array[2].length;
			players = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				players[i] = array[2][i];
			isPrivate = array[3];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(locationId);
			buffer.writeByte(subLocation);
			// players writing
			countI = players.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(players[i]);
			buffer.writeByte(int(isPrivate));
		}
	}
}