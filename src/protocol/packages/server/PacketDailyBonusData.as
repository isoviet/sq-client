package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 35
	public class PacketDailyBonusData extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 35;

		public var day: int = -1;
		public var haveBonus: int = -1;

		public function PacketDailyBonusData(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 35;

			if (buffer === null)
				return;

			day = buffer.readByte();
			haveBonus = buffer.readByte();
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

			day = array[0];
			haveBonus = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(day);
			buffer.writeByte(haveBonus);
		}
	}
}