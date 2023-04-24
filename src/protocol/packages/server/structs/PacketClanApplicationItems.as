package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketClanApplicationItems extends AbstractServerPacket
	{
		public var playerId: int = -1;
		public var time: int = -1;

		public function PacketClanApplicationItems(buffer: ByteArray)
		{
			playerId = buffer.readInt();
			time = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(playerId);
			buffer.writeInt(time);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			playerId = array[0];
			time = array[1];
		}
	}
}