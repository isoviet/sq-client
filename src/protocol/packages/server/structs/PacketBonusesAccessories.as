package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketBonusesAccessories extends AbstractServerPacket
	{
		public var accessoryId: int = -1;

		public function PacketBonusesAccessories(buffer: ByteArray)
		{
			accessoryId = buffer.readShort();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(accessoryId);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			accessoryId = array[0];
		}
	}
}