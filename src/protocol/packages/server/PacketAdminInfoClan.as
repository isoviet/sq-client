package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 4
	public class PacketAdminInfoClan extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 4;

		public var state: int = -1;
		public var clanId: int = -1;
		public var field: int = -1;
		public var data: ByteArray = null;

		public function PacketAdminInfoClan(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 4;

			if (buffer === null)
				return;

			state = buffer.readByte();
			clanId = buffer.readInt();
			field = buffer.readByte();
			data = readA(buffer);
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

			state = array[0];
			clanId = array[1];
			field = array[2];
			data = array[3];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(state);
			buffer.writeInt(clanId);
			buffer.writeByte(field);
			writeA(buffer, data);
		}
	}
}