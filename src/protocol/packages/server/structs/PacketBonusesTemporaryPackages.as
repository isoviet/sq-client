package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketBonusesTemporaryPackages extends AbstractServerPacket
	{
		public var packageId: int = -1;
		public var duration: int = -1;

		public function PacketBonusesTemporaryPackages(buffer: ByteArray)
		{
			packageId = buffer.readShort();
			duration = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(packageId);
			buffer.writeInt(duration);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			packageId = array[0];
			duration = array[1];
		}
	}
}