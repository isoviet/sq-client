package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 85
	public class PacketRoundSync extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 85;

		public var playerId: int = -1;
		public var info: Vector.<PacketRoundSyncInfo> = null;

		public function PacketRoundSync(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 85;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			playerId = buffer.readInt();
			// info initialization
			countI = buffer.readInt();
			info = new Vector.<PacketRoundSyncInfo>(countI);
			for (i = 0; i < countI; ++i)
				info[i] = new PacketRoundSyncInfo(buffer);
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

			playerId = array[0];
			// info initialization
			countI = array[1].length;
			info = new Vector.<PacketRoundSyncInfo>(countI);
			for (i = 0; i < countI; ++i)
				info[i] = new PacketRoundSyncInfo(array[1]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeInt(playerId);
			// info writing
			countI = info.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				info[i].build(buffer);
		}
	}
}