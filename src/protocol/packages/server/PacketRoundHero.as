package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 73
	public class PacketRoundHero extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 73;

		public var playerId: int = -1;
		public var keycode: int = -1;
		public var posX: Number = -1;
		public var posY: Number = -1;
		public var velX: Number = -1;
		public var velY: Number = -1;

		// optional
		public var health: int = -1;

		public function PacketRoundHero(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 73;

			if (buffer === null)
				return;

			playerId = buffer.readInt();
			keycode = buffer.readByte();
			posX = buffer.readFloat();
			posY = buffer.readFloat();
			velX = buffer.readFloat();
			velY = buffer.readFloat();

			// optional
			if (buffer.bytesAvailable > 0)
				health = buffer.readByte();

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
			keycode = array[1];
			posX = array[2];
			posY = array[3];
			velX = array[4];
			velY = array[5];

			// optional
			if (arraySize < 6)
				return;

			health = array[6];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(playerId);
			buffer.writeByte(keycode);
			buffer.writeFloat(posX);
			buffer.writeFloat(posY);
			buffer.writeFloat(velX);
			buffer.writeFloat(velY);

			// optional
			buffer.writeByte(health);
		}
	}
}