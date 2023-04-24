package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// 7
	public class PacketLogin extends AbstractServerPacket
	{
		public static var PACKET_ID: int = 7;

		public var status: int = -1;

		// optional
		public var innerId: int = -1;
		public var unixTime: int = -1;
		public var tag: int = -1;
		public var canOffer: int = -1;
		public var advertising: int = -1;
		public var email: String = "";
		public var editor: int = -1;
		public var inviterId: int = -1;
		public var registerTime: int = -1;
		public var logoutTime: int = -1;
		public var paymentTime: int = -1;
		public var items: Vector.<int> = null;
		public var clanApplication: int = -1;
		public var newsRepost: Vector.<int> = null;
		public var discounts: Vector.<PacketLoginDiscounts> = null;
		public var shamanInfo: Vector.<PacketLoginShamanInfo> = null;
		public var key: int = -1;
		public var services: Vector.<int> = null;

		public function PacketLogin(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = 7;

			if (buffer === null)
				return;

			var i: int = 0;
			var countI: int = 0;

			status = buffer.readByte();

			// optional
			if (buffer.bytesAvailable > 0)
				innerId = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				unixTime = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				tag = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				canOffer = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				advertising = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				email = readS(buffer);

			if (buffer.bytesAvailable > 0)
				editor = buffer.readByte();

			if (buffer.bytesAvailable > 0)
				inviterId = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				registerTime = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				logoutTime = buffer.readInt();

			if (buffer.bytesAvailable > 0)
				paymentTime = buffer.readInt();

			if (buffer.bytesAvailable > 0)
			{
				// items initialization
				countI = buffer.readInt();
				items = new Vector.<int>(countI);
				for (i = 0; i < countI; ++i)
					items[i] = buffer.readShort();
			}

			if (buffer.bytesAvailable > 0)
				clanApplication = buffer.readInt();

			if (buffer.bytesAvailable > 0)
			{
				// newsRepost initialization
				countI = buffer.readInt();
				newsRepost = new Vector.<int>(countI);
				for (i = 0; i < countI; ++i)
					newsRepost[i] = buffer.readShort();
			}

			if (buffer.bytesAvailable > 0)
			{
				// discounts initialization
				countI = buffer.readInt();
				discounts = new Vector.<PacketLoginDiscounts>(countI);
				for (i = 0; i < countI; ++i)
					discounts[i] = new PacketLoginDiscounts(buffer);
			}

			if (buffer.bytesAvailable > 0)
			{
				// shamanInfo initialization
				countI = buffer.readInt();
				shamanInfo = new Vector.<PacketLoginShamanInfo>(countI);
				for (i = 0; i < countI; ++i)
					shamanInfo[i] = new PacketLoginShamanInfo(buffer);
			}

			if (buffer.bytesAvailable > 0)
				key = buffer.readInt();

			if (buffer.bytesAvailable > 0)
			{
				// services initialization
				countI = buffer.readInt();
				services = new Vector.<int>(countI);
				for (i = 0; i < countI; ++i)
					services[i] = buffer.readByte();
			}

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

			// optional
			if (arraySize < 1)
				return;

			innerId = array[1];
			if (arraySize < 2)
				return;

			unixTime = array[2];
			if (arraySize < 3)
				return;

			tag = array[3];
			if (arraySize < 4)
				return;

			canOffer = array[4];
			if (arraySize < 5)
				return;

			advertising = array[5];
			if (arraySize < 6)
				return;

			email = array[6];
			if (arraySize < 7)
				return;

			editor = array[7];
			if (arraySize < 8)
				return;

			inviterId = array[8];
			if (arraySize < 9)
				return;

			registerTime = array[9];
			if (arraySize < 10)
				return;

			logoutTime = array[10];
			if (arraySize < 11)
				return;

			paymentTime = array[11];
			if (arraySize < 12)
				return;

			// items initialization
			countI = array[12].length;
			items = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				items[i] = array[12][i];
			if (arraySize < 13)
				return;

			clanApplication = array[13];
			if (arraySize < 14)
				return;

			// newsRepost initialization
			countI = array[14].length;
			newsRepost = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				newsRepost[i] = array[14][i];
			if (arraySize < 15)
				return;

			// discounts initialization
			countI = array[15].length;
			discounts = new Vector.<PacketLoginDiscounts>(countI);
			for (i = 0; i < countI; ++i)
				discounts[i] = new PacketLoginDiscounts(array[15]);
			if (arraySize < 16)
				return;

			// shamanInfo initialization
			countI = array[16].length;
			shamanInfo = new Vector.<PacketLoginShamanInfo>(countI);
			for (i = 0; i < countI; ++i)
				shamanInfo[i] = new PacketLoginShamanInfo(array[16]);
			if (arraySize < 17)
				return;

			key = array[17];
			if (arraySize < 18)
				return;

			// services initialization
			countI = array[18].length;
			services = new Vector.<int>(countI);
			for (i = 0; i < countI; ++i)
				services[i] = array[18][i];
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			var i: int = 0;
			var countI: int = 0;

			buffer.writeByte(status);

			// optional
			buffer.writeInt(innerId);
			buffer.writeInt(unixTime);
			buffer.writeInt(tag);
			buffer.writeByte(canOffer);
			buffer.writeByte(advertising);
			buffer.writeUTF(email);
			buffer.writeByte(editor);
			buffer.writeInt(inviterId);
			buffer.writeInt(registerTime);
			buffer.writeInt(logoutTime);
			buffer.writeInt(paymentTime);
			if (items === null)
				return;
			// items writing
			countI = items.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeShort(items[i]);
			buffer.writeInt(clanApplication);
			if (newsRepost === null)
				return;
			// newsRepost writing
			countI = newsRepost.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeShort(newsRepost[i]);
			if (discounts === null)
				return;
			// discounts writing
			countI = discounts.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				discounts[i].build(buffer);
			if (shamanInfo === null)
				return;
			// shamanInfo writing
			countI = shamanInfo.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				shamanInfo[i].build(buffer);
			buffer.writeInt(key);
			if (services === null)
				return;
			// services writing
			countI = services.length;
			buffer.writeInt(countI);
			for (i = 0; i < countI; ++i)
				buffer.writeByte(services[i]);
		}
	}
}