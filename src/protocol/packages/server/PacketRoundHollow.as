package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 77
	public class PacketRoundHollow extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 77;

		public var success: int = -1;
		public var playerId: int = -1;
		public var hollowType: int = -1;

		// optional
		public var gameTime: int = -1;
		public var value: int = -1;

		public function PacketRoundHollow(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 77;

			if (buffer === null)
				return;

			success = buffer.readByte();
			playerId = buffer.readInt();
			hollowType = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				gameTime = buffer.readShort();

			if (buffer.bytesAvailable > 0)
				value = buffer.readByte();

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

			success = array[0];
			playerId = array[1];
			hollowType = array[2];

			// optional
			if (arraySize < 3)
				return;

			gameTime = array[3];
			if (arraySize < 4)
				return;

			value = array[4];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(success);
			buffer.writeInt(playerId);
			buffer.writeByte(hollowType);

			// optional
			buffer.writeShort(gameTime);
			buffer.writeByte(value);
		}
	}
}