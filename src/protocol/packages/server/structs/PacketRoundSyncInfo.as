package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketRoundSyncInfo extends AbstractServerPacket
	{
		public var objectId: int = -1;
		public var posX: Number = -1;
		public var posY: Number = -1;
		public var angle: Number = -1;
		public var angular: Number = -1;
		public var velX: Number = -1;
		public var velY: Number = -1;

		public function PacketRoundSyncInfo(buffer: ByteArray)
		{
			objectId = buffer.readShort();
			posX = buffer.readFloat();
			posY = buffer.readFloat();
			angle = buffer.readFloat();
			angular = buffer.readFloat();
			velX = buffer.readFloat();
			velY = buffer.readFloat();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(objectId);
			buffer.writeFloat(posX);
			buffer.writeFloat(posY);
			buffer.writeFloat(angle);
			buffer.writeFloat(angular);
			buffer.writeFloat(velX);
			buffer.writeFloat(velY);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			objectId = array[0];
			posX = array[1];
			posY = array[2];
			angle = array[3];
			angular = array[4];
			velX = array[5];
			velY = array[6];
		}
	}
}