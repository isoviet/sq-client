package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 80
	public class PacketRoundTeam extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 80;

		public var redPlayerId: Vector.<int> = null;
		public var bluePlayerId: Vector.<int> = null;

		public function PacketRoundTeam(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 80;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// redPlayerId initialization
			countI = buffer.readInt();
			redPlayerId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				redPlayerId[i] = buffer.readInt();
			// bluePlayerId initialization
			countI = buffer.readInt();
			bluePlayerId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				bluePlayerId[i] = buffer.readInt();
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

			// redPlayerId initialization
			countI = array[0].length;
			redPlayerId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				redPlayerId[i] = array[0][i];
			// bluePlayerId initialization
			countI = array[1].length;
			bluePlayerId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				bluePlayerId[i] = array[1][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// redPlayerId writing
			countI = redPlayerId.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(redPlayerId[i]);
			// bluePlayerId writing
			countI = bluePlayerId.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(bluePlayerId[i]);
		}
	}
}