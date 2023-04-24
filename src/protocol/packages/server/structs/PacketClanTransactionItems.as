package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketClanTransactionItems extends AbstractServerPacket
	{
		public var playerId: int = -1;
		public var type: int = -1;
		public var coins: int = -1;
		public var nuts: int = -1;
		public var data: int = -1;
		public var time: int = -1;

		public function PacketClanTransactionItems(buffer: ByteArray)
		{
			playerId = buffer.readInt();
			type = buffer.readByte();
			coins = buffer.readInt();
			nuts = buffer.readInt();
			data = buffer.readInt();
			time = buffer.readInt();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeInt(playerId);
			buffer.writeByte(type);
			buffer.writeInt(coins);
			buffer.writeInt(nuts);
			buffer.writeInt(data);
			buffer.writeInt(time);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			playerId = array[0];
			type = array[1];
			coins = array[2];
			nuts = array[3];
			data = array[4];
			time = array[5];
		}
	}
}