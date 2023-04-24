package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 106
	public class PacketClanMembers extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 106;

		public var clanId: int = -1;
		public var playerIds: Vector.<int> = null;

		public function PacketClanMembers(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 106;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			clanId = buffer.readInt();
			// playerIds initialization
			countI = buffer.readInt();
			playerIds = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				playerIds[i] = buffer.readInt();
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

			clanId = array[0];
			// playerIds initialization
			countI = array[1].length;
			playerIds = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				playerIds[i] = array[1][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeInt(clanId);
			// playerIds writing
			countI = playerIds.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(playerIds[i]);
		}
	}
}