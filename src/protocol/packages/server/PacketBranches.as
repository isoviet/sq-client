package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 115
	public class PacketBranches extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 115;

		public var current: int = -1;
		public var bought: int = -1;

		public function PacketBranches(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 115;

			if (buffer === null)
				return;

			current = buffer.readByte();
			bought = buffer.readByte();
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

			current = array[0];
			bought = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(current);
			buffer.writeByte(bought);
		}
	}
}