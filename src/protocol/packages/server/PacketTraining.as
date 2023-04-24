package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 39
	public class PacketTraining extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 39;

		public var items: Vector.<PacketTrainingItems> = null;

		public function PacketTraining(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 39;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// items initialization
			countI = buffer.readInt();
			items = new Vector.<PacketTrainingItems>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = new PacketTrainingItems(buffer);
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
			items = new Vector.<PacketTrainingItems>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = new PacketTrainingItems(array[0]);
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