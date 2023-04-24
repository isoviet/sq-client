package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 83
	public class PacketRoundShaman extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 83;

		public var playerId: Vector.<int> = null;
		public var teams: Vector.<int> = null;

		public function PacketRoundShaman(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 83;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// playerId initialization
			countI = buffer.readInt();
			playerId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				playerId[i] = buffer.readInt();
			// teams initialization
			countI = buffer.readInt();
			teams = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				teams[i] = buffer.readByte();
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

			// playerId initialization
			countI = array[0].length;
			playerId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				playerId[i] = array[0][i];
			// teams initialization
			countI = array[1].length;
			teams = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				teams[i] = array[1][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// playerId writing
			countI = playerId.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(playerId[i]);
			// teams writing
			countI = teams.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeByte(teams[i]);
		}
	}
}