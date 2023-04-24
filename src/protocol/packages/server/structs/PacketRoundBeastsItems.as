package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketRoundBeastsItems extends AbstractServerPacket
	{
		public var beastType: int = -1;
		public var ids: Vector.<int> = null;

		public function PacketRoundBeastsItems(buffer: ByteArray)
		{
			var i: int = 0;
			var countI: int = 0;

			beastType = buffer.readByte();
			// ids initialization
			countI = buffer.readInt();
			ids = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				ids[i] = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(beastType);
			// ids writing
			countI = ids.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(ids[i]);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			var i: int = 0;
			var countI: int = 0;

			beastType = array[0];
			// ids initialization
			countI = array[1].length;
			ids = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				ids[i] = array[1][i];
		}
	}
}