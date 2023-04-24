package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 32
	public class PacketSmiles extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 32;

		public var smiles: Vector.<int> = null;

		public function PacketSmiles(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 32;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			// smiles initialization
			countI = buffer.readInt();
			smiles = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				smiles[i] = buffer.readByte();
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

			// smiles initialization
			countI = array[0].length;
			smiles = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				smiles[i] = array[0][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			// smiles writing
			countI = smiles.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeByte(smiles[i]);
		}
	}
}