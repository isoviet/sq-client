package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 19
	public class PacketExperience extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 19;

		public var exp: int = -1;
		public var reason: int = -1;

		public function PacketExperience(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 19;

			if (buffer === null)
				return;

			exp = buffer.readInt();
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

			exp = array[0];
			reason = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(exp);
			buffer.writeByte(reason);
		}
	}
}