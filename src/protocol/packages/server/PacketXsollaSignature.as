package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 31
	public class PacketXsollaSignature extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 31;

		public var singature: String = "";

		public function PacketXsollaSignature(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 31;

			if (buffer === null)
				return;

			singature = readS(buffer);
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

			singature = array[0];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			buffer.writeUTF(singature);
		}
	}
}