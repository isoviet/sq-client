package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 25
	public class PacketBuy extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 25;

		public var status: int = -1;
		public var playerId: int = -1;
		public var goodId: int = -1;
		public var coins: int = -1;
		public var nuts: int = -1;
		public var targetId: int = -1;
		public var data: int = -1;

		public function PacketBuy(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 25;

			if (buffer === null)
				return;

			status = buffer.readByte();
			playerId = buffer.readInt();
			goodId = buffer.readInt();
			coins = buffer.readInt();
			nuts = buffer.readInt();
			targetId = buffer.readInt();
			data = buffer.readInt();
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

			status = array[0];
			playerId = array[1];
			goodId = array[2];
			coins = array[3];
			nuts = array[4];
			targetId = array[5];
			data = array[6];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(playerId);
			buffer.writeInt(goodId);
			buffer.writeInt(coins);
			buffer.writeInt(nuts);
			buffer.writeInt(targetId);
			buffer.writeInt(data);
		}
	}
}