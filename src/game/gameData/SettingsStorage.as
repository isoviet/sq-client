package game.gameData
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import game.mainGame.perks.ui.FastPerksBar;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketStorageInfo;
	import protocol.packages.server.structs.PacketStorageInfoItems;

	public class SettingsStorage
	{
		static public const HOT_KEYS:int = 0;
		static public const SETTINGS:int = 1;
		static public const NOTIFICATIONS:int = 2;
		static public const CHAT_SETTINGS:int = 3;
		static public const DIALOGS_BUYING:int = 4;

		static private const SETTINGS_NAMES:Array = ['quality', 'highlight', 'blackout'];

		static private var storage:Object = {};
		static private var callbacks:Object = {};

		static public function init():void
		{
			Connection.listen(onPacket, [PacketStorageInfo.PACKET_ID]);
		}

		static public function addCallback(type:int, callback:Function):void
		{
			callbacks[type] = callback;
		}

		static public function save(type:int, data:Object):void
		{
			storage[type] = data;

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			switch (type)
			{
				case HOT_KEYS:
					var array:Array = [];
					for (var i:int = 0; i < FastPerksBar.MAX_BUTTONS; i++)
					{
						if (!(i in data))
							break;
						array.push(data[i]['class'], data[i]['perk']);
					}
					var length:int = int(array.length * 0.5);
					byteArray.writeByte(length);
					for (i = 0; i < length; i++)
					{
						byteArray.writeByte(array[i * 2]);
						byteArray.writeShort(array[i * 2 + 1]);
					}
					break;
				case SETTINGS:
					for (i = 0; i < SETTINGS_NAMES.length; i++)
						byteArray.writeByte(SETTINGS_NAMES[i] in data ? data[SETTINGS_NAMES[i]] : 0);
					break;
				case NOTIFICATIONS:
					byteArray.writeShort(data['closeout_period']);
					byteArray.writeShort(data['stock_package']);
					byteArray.writeInt(data['news_id']);
					break;
				case CHAT_SETTINGS:
					byteArray.writeShort(data['chatState']);
					break;
				case DIALOGS_BUYING:
					for (i = 0; i < DialogOfferManager.NAMES.length; i++)
						byteArray.writeInt(DialogOfferManager.NAMES[i] in data ? data[DialogOfferManager.NAMES[i]] : 0);
					break;
			}
			Connection.sendData(PacketClient.STORAGE_SET, type, byteArray);
		}

		static public function load(type:int):Object
		{
			if (!(type in storage))
				return {};
			return storage[type];
		}

		static private function onPacket(packet:PacketStorageInfo):void
		{
			var settings:Vector.<PacketStorageInfoItems> = packet.items;

			for (var i:int = 0; i < settings.length; i++)
			{
				var data:Object = {};
				var byteArray:ByteArray = settings[i].data;
				try
				{
					switch (settings[i].type)
					{
						case HOT_KEYS:
							var length:uint = byteArray.readByte();
							for (var j:int = 0; j < length; j++)
							{
								data[j] = {};
								data[j]['class'] = byteArray.readByte();
								data[j]['perk'] = byteArray.readShort();
							}
							break;
						case SETTINGS:
							for (j = 0; j < SETTINGS_NAMES.length; j++)
								data[SETTINGS_NAMES[j]] = byteArray.readByte();
							break;
						case NOTIFICATIONS:
							data['closeout_period'] = byteArray.readShort();
							data['stock_package'] = byteArray.readShort();
							data['news_id'] = byteArray.readInt();
							break;
						case CHAT_SETTINGS:
							data['chatState'] = byteArray.readShort();
							break;
						case DIALOGS_BUYING:
							for (j = 0; j < DialogOfferManager.NAMES.length; j++)
								data[DialogOfferManager.NAMES[j]] = byteArray.readInt();
							break;
					}
				}
				catch(e:Error)
				{
					Logger.add("Error on load settings. Type " + settings[i]);
					Connection.sendData(PacketClient.STORAGE_SET, settings[i], new ByteArray());
				}

				storage[settings[i].type.toString()] = data;
				if (settings[i].type in callbacks)
					callbacks[settings[i].type.toString()]();
			}
		}
	}
}