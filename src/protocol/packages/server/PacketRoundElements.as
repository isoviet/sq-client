package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 94
	public class PacketRoundElements extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 94;

		public var items: Vector.<PacketRoundElementsItems> = null;

		public function PacketRoundElements(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 94;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// items initialization
			countI = buffer.readInt();
			items = new Vector.<PacketRoundElementsItems>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = new PacketRoundElementsItems(buffer);
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
			items = new Vector.<PacketRoundElementsItems>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = new PacketRoundElementsItems(array[0]);
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