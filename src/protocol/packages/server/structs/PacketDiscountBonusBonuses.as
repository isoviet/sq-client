package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketDiscountBonusBonuses extends AbstractServerPacket
	{
		public var bonus: int = -1;
		public var time: int = -1;

		public function PacketDiscountBonusBonuses(buffer: ByteArray)
		{
			bonus = buffer.readByte();
			time = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(bonus);
			buffer.writeInt(time);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			bonus = array[0];
			time = array[1];
		}
	}
}