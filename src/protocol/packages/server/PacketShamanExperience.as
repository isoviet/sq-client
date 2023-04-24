package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 20
	public class PacketShamanExperience extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 20;

		public var shamanExp: int = -1;
		public var reason: int = -1;

		public function PacketShamanExperience(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 20;

			if (buffer === null)
				return;

			shamanExp = buffer.readInt();
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

			shamanExp = array[0];
			reason = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(shamanExp);
			buffer.writeByte(reason);
		}
	}
}