package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 6
	public class PacketSessionInfo extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 6;

		public var status: int = -1;
		public var netIdFirst: int = -1;
		public var netIdSecond: int = -1;
		public var type: int = -1;
		public var sessionNumber: int = -1;
		public var sessionId: String = "";

		public function PacketSessionInfo(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 6;

			if (buffer === null)
				return;

			status = buffer.readByte();
			netIdFirst = buffer.readInt();
			netIdSecond = buffer.readInt();
			type = buffer.readByte();
			sessionNumber = buffer.readInt();
			sessionId = readS(buffer);
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

			status = array[0];
			netIdFirst = array[1];
			netIdSecond = array[2];
			type = array[3];
			sessionNumber = array[4];
			sessionId = array[5];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(netIdFirst);
			buffer.writeInt(netIdSecond);
			buffer.writeByte(type);
			buffer.writeInt(sessionNumber);
			buffer.writeUTF(sessionId);
		}
	}
}