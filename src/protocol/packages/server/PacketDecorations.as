package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 45
	public class PacketDecorations extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 45;

		public var decorationId: Vector.<int> = null;

		public function PacketDecorations(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 45;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// decorationId initialization
			countI = buffer.readInt();
			decorationId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				decorationId[i] = buffer.readByte();
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

			// decorationId initialization
			countI = array[0].length;
			decorationId = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				decorationId[i] = array[0][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// decorationId writing
			countI = decorationId.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeByte(decorationId[i]);
		}
	}
}