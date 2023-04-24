package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class PacketRoundSkillsItems extends AbstractServerPacket
	{
		public var playerId: int = -1;
		public var characters: Vector.<PacketRoundSkillsItemsCharacters> = null;

		public function PacketRoundSkillsItems(buffer: ByteArray)
		{
			var i: int = 0;
			var countI: int = 0;

			playerId = buffer.readInt();
			// characters initialization
			countI = buffer.readInt();
			characters = new Vector.<PacketRoundSkillsItemsCharacters>(countI);
			for (i = 0; i < countI; ++i)
				characters[i] = new PacketRoundSkillsItemsCharacters(buffer);
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeInt(playerId);
			// characters writing
			countI = characters.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				characters[i].build(buffer);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			var i: int = 0;
			var countI: int = 0;

			playerId = array[0];
			// characters initialization
			countI = array[1].length;
			characters = new Vector.<PacketRoundSkillsItemsCharacters>(countI);
			for (i = 0; i < countI; ++i)
				characters[i] = new PacketRoundSkillsItemsCharacters(array[1]);
		}
	}
}