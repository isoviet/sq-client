package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 3
	public class PacketAdminInfo extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 3;

		public var state: int = -1;
		public var type: int = -1;
		public var netId: String = "0";
		public var innerId: int = -1;
		public var field: int = -1;
		public var data: ByteArray = null;

		public function PacketAdminInfo(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 3;

			if (buffer === null)
				return;

			state = buffer.readByte();
			type = buffer.readByte();
			netId = (new UInt64(buffer)).toString();
			innerId = buffer.readInt();
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
			type = array[1];
			netId = array[2];
			innerId = array[3];
			field = array[4];
			data = array[5];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(state);
			buffer.writeByte(type);
			writeUInt64(netId, buffer);
			buffer.writeInt(innerId);
			buffer.writeByte(field);
			writeA(buffer, data);
		}
	}
}