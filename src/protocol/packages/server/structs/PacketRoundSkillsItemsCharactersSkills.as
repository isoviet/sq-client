package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketRoundSkillsItemsCharactersSkills extends AbstractServerPacket
	{
		public var skill: int = -1;
		public var level: int = -1;

		public function PacketRoundSkillsItemsCharactersSkills(buffer: ByteArray)
		{
			skill = buffer.readShort();
			level = buffer.readByte();
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer.writeShort(skill);
			buffer.writeByte(level);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			skill = array[0];
			level = array[1];
		}
	}
}