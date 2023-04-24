package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 112
	public class PacketDiscountBonus extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 112;

		public var bonuses: Vector.<PacketDiscountBonusBonuses> = null;

		// optional
		public var resetPayment: int = -1;

		public function PacketDiscountBonus(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 112;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// bonuses initialization
			countI = buffer.readInt();
			bonuses = new Vector.<PacketDiscountBonusBonuses>(countI);
			for (i = 0; i < countI; ++i)
				bonuses[i] = new PacketDiscountBonusBonuses(buffer);

			// optional
			if (buffer.bytesAvailable > 0)
				resetPayment = buffer.readByte();

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

			// bonuses initialization
			countI = array[0].length;
			bonuses = new Vector.<PacketDiscountBonusBonuses>(countI);
			for (i = 0; i < countI; ++i)
				bonuses[i] = new PacketDiscountBonusBonuses(array[0]);

			// optional
			if (arraySize < 1)
				return;

			resetPayment = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// bonuses writing
			countI = bonuses.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				bonuses[i].build(buffer);

			// optional
			buffer.writeByte(resetPayment);
		}
	}
}