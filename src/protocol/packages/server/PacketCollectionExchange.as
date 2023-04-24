package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 61
	public class PacketCollectionExchange extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 61;

		public var status: int = -1;
		public var clientId: int = -1;
		public var targetId: int = -1;
		public var clientItem: int = -1;
		public var targetItem: int = -1;

		public function PacketCollectionExchange(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 61;

			if (buffer === null)
				return;

			status = buffer.readByte();
			clientId = buffer.readInt();
			targetId = buffer.readInt();
			clientItem = buffer.readByte();
			targetItem = buffer.readByte();
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
			clientId = array[1];
			targetId = array[2];
			clientItem = array[3];
			targetItem = array[4];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeInt(clientId);
			buffer.writeInt(targetId);
			buffer.writeByte(clientItem);
			buffer.writeByte(targetItem);
		}
	}
}