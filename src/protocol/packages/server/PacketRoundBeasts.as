package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 84
	public class PacketRoundBeasts extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 84;

		public var items: Vector.<PacketRoundBeastsItems> = null;

		public function PacketRoundBeasts(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 84;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// items initialization
			countI = buffer.readInt();
			items = new Vector.<PacketRoundBeastsItems>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = new PacketRoundBeastsItems(buffer);
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

			// items initialization
			countI = array[0].length;
			items = new Vector.<PacketRoundBeastsItems>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = new PacketRoundBeastsItems(array[0]);
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// items writing
			countI = items.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				items[i].build(buffer);
		}
	}
}