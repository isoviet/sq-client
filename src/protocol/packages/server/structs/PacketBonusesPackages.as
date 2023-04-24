package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketBonusesPackages extends AbstractServerPacket
	{
		public var packageId: int = -1;

		public function PacketBonusesPackages(buffer: ByteArray)
		{
			packageId = buffer.readShort();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(packageId);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			packageId = array[0];
		}
	}
}