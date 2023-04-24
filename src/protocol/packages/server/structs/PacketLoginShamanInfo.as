package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketLoginShamanInfo extends AbstractServerPacket
	{
		public var skillId: int = -1;
		public var levelFree: int = -1;
		public var levelPaid: int = -1;

		public function PacketLoginShamanInfo(buffer: ByteArray)
		{
			skillId = buffer.readByte();
			levelFree = buffer.readByte();
			levelPaid = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeByte(skillId);
			buffer.writeByte(levelFree);
			buffer.writeByte(levelPaid);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			skillId = array[0];
			levelFree = array[1];
			levelPaid = array[2];
		}
	}
}