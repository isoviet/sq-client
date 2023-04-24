package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 18
	public class PacketMana extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 18;

		public var mana: int = -1;
		public var reason: int = -1;

		public function PacketMana(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 18;

			if (buffer === null)
				return;

			mana = buffer.readInt();
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

			mana = array[0];
			reason = array[1];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeInt(mana);
			buffer.writeByte(reason);
		}
	}
}