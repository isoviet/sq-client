package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketBundlesPackages extends AbstractServerPacket
	{
		public var id: int = -1;
		public var duration: int = -1;

		public function PacketBundlesPackages(buffer: ByteArray)
		{
			id = buffer.readShort();
			duration = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(id);
			buffer.writeInt(duration);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			id = array[0];
			duration = array[1];
		}
	}
}