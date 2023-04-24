package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 11
	public class PacketOnline extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 11;

		public var locationsOnline: Vector.<int> = null;

		public function PacketOnline(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 11;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// locationsOnline initialization
			countI = buffer.readInt();
			locationsOnline = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				locationsOnline[i] = buffer.readInt();
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

			var i: int = 0;
			var countI: int = 0;

			// locationsOnline initialization
			countI = array[0].length;
			locationsOnline = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				locationsOnline[i] = array[0][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// locationsOnline writing
			countI = locationsOnline.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeInt(locationsOnline[i]);
		}
	}
}