package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 15
	public class PacketFeathers extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 15;

		public var feathers: int = -1;
		public var reason: int = -1;

		public function PacketFeathers(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 15;

			if (buffer === null)
				return;

			feathers = buffer.readByte();
			reason = buffer.readByte();
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

			feathers = array[0];
			reason = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(feathers);
			buffer.writeByte(reason);
		}
	}
}