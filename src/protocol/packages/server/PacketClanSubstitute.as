package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 110
	public class PacketClanSubstitute extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 110;

		public var playerIds: Vector.<int> = null;

		// optional
		public var status: int = -1;

		public function PacketClanSubstitute(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 110;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// playerIds initialization
			countI = buffer.readInt();
			playerIds = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				playerIds[i] = buffer.readInt();

			// optional
			if (buffer.bytesAvailable > 0)
				status = buffer.readByte();

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

			// playerIds initialization
			countI = array[0].length;
			playerIds = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				playerIds[i] = array[0][i];

			// optional
			if (arraySize < 1)
				return;

			status = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// playerIds writing
			countI = playerIds.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(playerIds[i]);

			// optional
			buffer.writeByte(status);
		}
	}
}