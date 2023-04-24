package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 60
	public class PacketCollectionAssemble extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 60;

		public var status: int = -1;
		public var type: int = -1;
		public var unsignedElementId: uint = NaN;

		public function PacketCollectionAssemble(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 60;

			if (buffer === null)
				return;

			status = buffer.readByte();
			type = buffer.readByte();
			unsignedElementId = readUnsignedByte(buffer);
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
			type = array[1];
			unsignedElementId = array[2];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeByte(status);
			buffer.writeByte(type);
			buffer.writeByte(unsignedElementId);
		}
	}
}