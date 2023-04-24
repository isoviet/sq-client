package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 42
	public class PacketBonuses extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 42;

		public var status: int = -1;
		public var awardReason: int = -1;

		// optional
		public var coins: int = -1;
		public var nuts: int = -1;
		public var energy: int = -1;
		public var mana: int = -1;
		public var experience: int = -1;
		public var vipDuration: int = -1;
		public var manaRegenerationDuration: int = -1;
		public var holidayElements: int = -1;
		public var holidayBoosterDuration: int = -1;
		public var collections: Vector.<int> = null;
		public var temporaryPackages: Vector.<PacketBonusesTemporaryPackages> = null;
		public var packages: Vector.<PacketBonusesPackages> = null;
		public var accessories: Vector.<PacketBonusesAccessories> = null;
		public var items: Vector.<PacketBonusesItems> = null;
		public var data: int = -1;

		public function PacketBonuses(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 42;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			status = buffer.readByte();
			awardReason = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				coins = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				nuts = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				energy = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				mana = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				experience = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				vipDuration = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				manaRegenerationDuration = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				holidayElements = buffer.readShort();

			if (buffer.bytesAvailable > 0)
				holidayBoosterDuration = buffer.readInt();

			if (buffer.bytesAvailable > 0)
			{
				// collections initialization
				countI = buffer.readInt();
				collections = new Vector.<int>(countI);
				for (i = 0; i < countI; ++i)
					collections[i] = buffer.readByte();
			}

			if (buffer.bytesAvailable > 0)
			{
				// temporaryPackages initialization
				countI = buffer.readInt();
				temporaryPackages = new Vector.<PacketBonusesTemporaryPackages>(countI);
				for (i = 0; i < countI; ++i)
					temporaryPackages[i] = new PacketBonusesTemporaryPackages(buffer);
			}

			if (buffer.bytesAvailable > 0)
			{
				// packages initialization
				countI = buffer.readInt();
				packages = new Vector.<PacketBonusesPackages>(countI);
				for (i = 0; i < countI; ++i)
					packages[i] = new PacketBonusesPackages(buffer);
			}

			if (buffer.bytesAvailable > 0)
			{
				// accessories initialization
				countI = buffer.readInt();
				accessories = new Vector.<PacketBonusesAccessories>(countI);
				for (i = 0; i < countI; ++i)
					accessories[i] = new PacketBonusesAccessories(buffer);
			}

			if (buffer.bytesAvailable > 0)
			{
				// items initialization
				countI = buffer.readInt();
				items = new Vector.<PacketBonusesItems>(countI);
				for (i = 0; i < countI; ++i)
					items[i] = new PacketBonusesItems(buffer);
			}

			if (buffer.bytesAvailable > 0)
				data = buffer.readInt();

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

			status = array[0];
			awardReason = array[1];

			// optional
			if (arraySize < 2)
				return;

			coins = array[2];
			if (arraySize < 3)
				return;

			nuts = array[3];
			if (arraySize < 4)
				return;

			energy = array[4];
			if (arraySize < 5)
				return;

			mana = array[5];
			if (arraySize < 6)
				return;

			experience = array[6];
			if (arraySize < 7)
				return;

			vipDuration = array[7];
			if (arraySize < 8)
				return;

			manaRegenerationDuration = array[8];
			if (arraySize < 9)
				return;

			holidayElements = array[9];
			if (arraySize < 10)
				return;

			holidayBoosterDuration = array[10];
			if (arraySize < 11)
				return;

			// collections initialization
			countI = array[11].length;
			collections = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				collections[i] = array[11][i];
			if (arraySize < 12)
				return;

			// temporaryPackages initialization
			countI = array[12].length;
			temporaryPackages = new Vector.<PacketBonusesTemporaryPackages>(countI);
			for (i = 0; i < countI; ++i)
				temporaryPackages[i] = new PacketBonusesTemporaryPackages(array[12]);
			if (arraySize < 13)
				return;

			// packages initialization
			countI = array[13].length;
			packages = new Vector.<PacketBonusesPackages>(countI);
			for (i = 0; i < countI; ++i)
				packages[i] = new PacketBonusesPackages(array[13]);
			if (arraySize < 14)
				return;

			// accessories initialization
			countI = array[14].length;
			accessories = new Vector.<PacketBonusesAccessories>(countI);
			for (i = 0; i < countI; ++i)
				accessories[i] = new PacketBonusesAccessories(array[14]);
			if (arraySize < 15)
				return;

			// items initialization
			countI = array[15].length;
			items = new Vector.<PacketBonusesItems>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = new PacketBonusesItems(array[15]);
			if (arraySize < 16)
				return;

			data = array[16];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(status);
			buffer.writeByte(awardReason);

			// optional
			buffer.writeInt(coins);
			buffer.writeInt(nuts);
			buffer.writeInt(energy);
			buffer.writeInt(mana);
			buffer.writeInt(experience);
			buffer.writeInt(vipDuration);
			buffer.writeInt(manaRegenerationDuration);
			buffer.writeShort(holidayElements);
			buffer.writeInt(holidayBoosterDuration);
			if (collections === null)
				return;
			// collections writing
			countI = collections.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeByte(collections[i]);
			if (temporaryPackages === null)
				return;
			// temporaryPackages writing
			countI = temporaryPackages.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				temporaryPackages[i].build(buffer);
			if (packages === null)
				return;
			// packages writing
			countI = packages.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				packages[i].build(buffer);
			if (accessories === null)
				return;
			// accessories writing
			countI = accessories.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				accessories[i].build(buffer);
			if (items === null)
				return;
			// items writing
			countI = items.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				items[i].build(buffer);
			buffer.writeInt(data);
		}
	}
}