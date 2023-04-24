package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 104
	public class PacketClanBalance extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 104;

		public var coins: int = -1;
		public var nuts: int = -1;

		public function PacketClanBalance(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 104;

			if (buffer === null)
				return;

			coins = buffer.readInt();
			nuts = buffer.readInt();
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

			coins = array[0];
			nuts = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(coins);
			buffer.writeInt(nuts);
		}
	}
}