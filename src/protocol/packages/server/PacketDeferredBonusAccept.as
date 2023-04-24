package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 57
	public class PacketDeferredBonusAccept extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 57;

		public var status: int = -1;
		public var id: int = -1;

		// optional
		public var awardReason: int = -1;
		public var type: int = -1;
		public var bonusId: int = -1;
		public var bonusCount: int = -1;
		public var bonusDuration: int = -1;

		public function PacketDeferredBonusAccept(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 57;

			if (buffer === null)
				return;

			status = buffer.readByte();
			id = buffer.readInt();

			// optional
			if (buffer.bytesAvailable > 0)
				awardReason = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				type = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				bonusId = buffer.readShort();

			if (buffer.bytesAvailable > 0)
				bonusCount = buffer.readShort();

			if (buffer.bytesAvailable > 0)
				bonusDuration = buffer.readInt();

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
			id = array[1];

			// optional
			if (arraySize < 2)
				return;

			awardReason = array[2];
			if (arraySize < 3)
				return;

			type = array[3];
			if (arraySize < 4)
				return;

			bonusId = array[4];
			if (arraySize < 5)
				return;

			bonusCount = array[5];
			if (arraySize < 6)
				return;

			bonusDuration = array[6];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(id);

			// optional
			buffer.writeByte(awardReason);
			buffer.writeByte(type);
			buffer.writeShort(bonusId);
			buffer.writeShort(bonusCount);
			buffer.writeInt(bonusDuration);
		}
	}
}