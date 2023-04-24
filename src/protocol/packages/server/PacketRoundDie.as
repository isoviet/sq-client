package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 78
	public class PacketRoundDie extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 78;

		public var playerId: int = -1;
		public var posX: Number = -1;
		public var posY: Number = -1;
		public var reason: int = -1;

		// optional
		public var killerId: int = -1;

		public function PacketRoundDie(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 78;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			posX = buffer.readFloat();
			posY = buffer.readFloat();
			reason = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				killerId = buffer.readInt();

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

			playerId = array[0];
			posX = array[1];
			posY = array[2];
			reason = array[3];

			// optional
			if (arraySize < 4)
				return;

			killerId = array[4];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeFloat(posX);
			buffer.writeFloat(posY);
			buffer.writeByte(reason);

			// optional
			buffer.writeInt(killerId);
		}
	}
}