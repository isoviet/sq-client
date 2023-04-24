package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 48
	public class PacketHolidayLottery extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 48;

		public var deferredBonusId: int = -1;

		public function PacketHolidayLottery(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 48;

			if (buffer === null)
				return;

			deferredBonusId = buffer.readInt();
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

			deferredBonusId = array[0];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(deferredBonusId);
		}
	}
}