package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketRoundSkillsItemsCharacters extends AbstractServerPacket
	{
		public var character: int = -1;
		public var skills: Vector.<PacketRoundSkillsItemsCharactersSkills> = null;

		public function PacketRoundSkillsItemsCharacters(buffer: ByteArray)
		{
			var i: int = 0;
			var countI: int = 0;

			character = buffer.readByte();
			// skills initialization
			countI = buffer.readInt();
			skills = new Vector.<PacketRoundSkillsItemsCharactersSkills>(countI);
			for (i = 0; i < countI; ++i)
				skills[i] = new PacketRoundSkillsItemsCharactersSkills(buffer);
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(character);
			// skills writing
			countI = skills.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				skills[i].build(buffer);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			var i: int = 0;
			var countI: int = 0;

			character = array[0];
			// skills initialization
			countI = array[1].length;
			skills = new Vector.<PacketRoundSkillsItemsCharactersSkills>(countI);
			for (i = 0; i < countI; ++i)
				skills[i] = new PacketRoundSkillsItemsCharactersSkills(array[1]);
		}
	}
}