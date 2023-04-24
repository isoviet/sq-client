package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketDeferredBonusItems extends AbstractServerPacket
	{
		public var id: int = -1;
		public var awardReason: int = -1;
		public var type: int = -1;
		public var time: int = -1;
		public var duration: int = -1;
		public var bonusId: int = -1;
		public var bonusCount: int = -1;
		public var bonusDuration: int = -1;

		public function PacketDeferredBonusItems(buffer: ByteArray)
		{
			id = buffer.readInt();
			awardReason = buffer.readByte();
			type = buffer.readByte();
			time = buffer.readInt();
			duration = buffer.readInt();
			bonusId = buffer.readShort();
			bonusCount = buffer.readShort();
			bonusDuration = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(id);
			buffer.writeByte(awardReason);
			buffer.writeByte(type);
			buffer.writeInt(time);
			buffer.writeInt(duration);
			buffer.writeShort(bonusId);
			buffer.writeShort(bonusCount);
			buffer.writeInt(bonusDuration);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			id = array[0];
			awardReason = array[1];
			type = array[2];
			time = array[3];
			duration = array[4];
			bonusId = array[5];
			bonusCount = array[6];
			bonusDuration = array[7];
		}
	}
}