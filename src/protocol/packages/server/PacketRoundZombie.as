package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 96
	public class PacketRoundZombie extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 96;

		public var victimId: int = -1;
		public var isFirst: Boolean = false;

		// optional
		public var player: int = -1;

		public function PacketRoundZombie(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 96;

			if (buffer === null)
				return;

			victimId = buffer.readInt();
			isFirst = Boolean(buffer.readByte());

			// optional
			if (buffer.bytesAvailable > 0)
				player = buffer.readInt();

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

			victimId = array[0];
			isFirst = array[1];

			// optional
			if (arraySize < 2)
				return;

			player = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(victimId);
			buffer.writeByte(int(isFirst));

			// optional
			buffer.writeInt(player);
		}
	}
}