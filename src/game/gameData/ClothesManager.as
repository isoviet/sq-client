package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import events.GameEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketClothesExpired;
	import protocol.packages.server.PacketClothesSlot;
	import protocol.packages.server.PacketClothesStorage;
	import protocol.packages.server.PacketClothesWear;

	import utils.ArrayUtil;

	public class ClothesManager
	{
		static public const KIND_PACKAGES:int = 0;
		static public const KIND_ACCESORIES:int = 1;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var clearSended:Boolean = false;

		static private var packages:Array = [];
		static private var packagesLevel:Object = {};
		static private var packagesTime:Object = {};
		static private var packagesReason:Object = {};
		static private var packagesExtraSkill:Object = {};

		static private var accessories:Array = [];
		static private var accessoriesReason:Object = {};

		static public var wornPackages:Array = [];
		static public var wornAccessories:Array = [];

		static public function init():void
		{
			Connection.listen(onPacket, [PacketClothesStorage.PACKET_ID, PacketClothesWear.PACKET_ID, PacketClothesExpired.PACKET_ID, PacketClothesSlot.PACKET_ID]);
			EnterFrameManager.addPerSecondTimer(onTime);
		}

		//TODO белка больше не надевается по частям, теперь только цельно по костюм
		//TODO Дополнительно снимать/одевать лучше сделать отдельно по имени картинки

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function isPackageWorn(id:int):Boolean
		{
			return wornPackages.indexOf(id) != -1;
		}

		static public function isAccessoryWorn(id:int):Boolean
		{
			return wornAccessories.indexOf(id) != -1;
		}

		static public function isWornItem(id:int, kind:int):Boolean
		{
			switch (kind)
			{
				case KIND_PACKAGES:
					return isPackageWorn(id);
				case KIND_ACCESORIES:
					return isAccessoryWorn(id);
			}
			return false;
		}

		static public function get outfitIds():Array
		{
			var answer:Array = [];
			for (var i:int = 0; i < packages.length; i++)
				answer.push(OutfitData.packageToOutfit(packages[i]));
			return ArrayUtil.valuesToUnic(answer);
		}

		static public function getPackageActive(id:int):Boolean
		{
			if (packages.indexOf(id) == -1)
				return false;
			return (getPackageTime(id) == 0) || (getPackageTime(id) > Game.unix_time + int(getTimer() / 1000));
		}

		static public function get packagesIds():Array
		{
			return packages;
		}

		static public function get accessoriesIds():Array
		{
			return accessories;
		}

		static public function getPackagesLevel(id:int):int
		{
			if (id in packagesLevel)
				return packagesLevel[id];
			return -1;
		}

		static public function get isScrat():Boolean
		{
			for (var i:int = 0; i < wornPackages.length; i++)
			{
				if (!OutfitData.isScratSkin(wornPackages[i]))
					continue;
				return true;
			}
			return false;
		}

		static public function get isScratty():Boolean
		{
			for (var i:int = 0; i < wornPackages.length; i++)
			{
				if (!OutfitData.isScrattySkin(wornPackages[i]))
					continue;
				return true;
			}
			return false;
		}

		static public function get haveScrat():Boolean
		{
			return packages.indexOf(OutfitData.SCRAT) != -1;
		}

		static public function get haveScratty():Boolean
		{
			return packages.indexOf(OutfitData.SCRATTY) != -1;
		}

		static public function haveItem(id:int, kind:int):Boolean
		{
			switch (kind)
			{
				case KIND_PACKAGES:
					return packages.indexOf(id) != -1;
				case KIND_ACCESORIES:
					return accessories.indexOf(id) != -1;
			}
			return false;
		}

		static public function wear(kind:int, id:int):void
		{
			switch (kind)
			{
				case KIND_PACKAGES:
					Connection.sendData(PacketClient.CLOTHES_WEAR, kind, id, 1);
					break;
				case KIND_ACCESORIES:
					Connection.sendData(PacketClient.CLOTHES_WEAR, kind, id, 1);
					break;
			}
		}

		static public function tryOn(kind:int, id:int):void
		{
			switch (kind)
			{
				case KIND_PACKAGES:
					Connection.sendData(PacketClient.CLOTHES_WEAR, kind, id, isPackageWorn(id) ? 0 : 1);
					break;
				case KIND_ACCESORIES:
					Connection.sendData(PacketClient.CLOTHES_WEAR, kind, id, isAccessoryWorn(id) ? 0 : 1);
					break;
			}
			EducationQuestManager.done(EducationQuestManager.WARDROBE);
		}

		static private function dress(kind:int, id:int, event:Boolean = false):Boolean
		{
			switch (kind)
			{
				case KIND_PACKAGES:
					if (isPackageWorn(id))
						return false;
					wornPackages.push(id);
					break;
				case KIND_ACCESORIES:
					if (isAccessoryWorn(id))
						return false;
					wornAccessories.push(id);
					break;
			}
			if (event)
				dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOTHES_HERO_CHANGE));
			return true;
		}

		static private function undress(kind:int, id:int, event:Boolean = false):Boolean
		{
			switch (kind)
			{
				case KIND_PACKAGES:
					if (!isPackageWorn(id))
						return false;
					wornPackages.splice(wornPackages.indexOf(id), 1);
					break;
				case KIND_ACCESORIES:
					if (!isAccessoryWorn(id))
						return false;
					wornAccessories.splice(wornAccessories.indexOf(id), 1);
					break;
			}
			if (event)
				dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOTHES_HERO_CHANGE));
			return true;
		}

		static public function convertToBones(packagesIds:Array, accessoriesIds:Array):Array
		{
			var answer:Array = [];
			for (var i:int = 0 ; i < packagesIds.length; i++)
				answer = answer.concat(OutfitData.skin_bones[packagesIds[i]]);
			for (i = 0 ; i < accessoriesIds.length; i++)
				answer = answer.concat(OutfitData.accessories_bones[accessoriesIds[i]]);
			return answer;
		}

		static public function getPackageTime(id:int):int
		{
			if (id in packagesTime)
				return packagesTime[id];
			return 0;
		}

		static public function getPackageExtraSkill(id:int):int
		{
			if (id in packagesExtraSkill)
				return packagesExtraSkill[id];
			return 0;
		}

		static private function onTime():void
		{
			if (clearSended)
				return;
			var currentTime:int = Game.unix_time + int(getTimer() / 1000);
			for each (var time:int in packagesTime)
			{
				if (time == 0)
					continue;
				if (time > currentTime)
					continue;
				Connection.sendData(PacketClient.CLEAR_TEMPORARY, PacketClient.BUY_PACKAGE_DAY);
				clearSended = true;
				break;
			}
		}

		static private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketClothesStorage.PACKET_ID:
					var storage:PacketClothesStorage = packet as PacketClothesStorage;

					var dressChange:Boolean = false;
					for (var i:int = 0 ; i < storage.packages.length; i++)
					{
						packages.push(storage.packages[i].id);
						packagesLevel[storage.packages[i].id] = storage.packages[i].level;
						packagesTime[storage.packages[i].id] = storage.packages[i].expirationTime;
						packagesReason[storage.packages[i].id] = storage.packages[i].awardReason;
						packagesExtraSkill[storage.packages[i].id] = storage.packages[i].freeSlot;

						if (storage.packages[i].isWeared)
						{
							if (dress(KIND_PACKAGES, storage.packages[i].id))
								dressChange = true;
						}
						else
						{
							if (undress(KIND_PACKAGES, storage.packages[i].id))
								dressChange = true;
						}
					}
					packages = ArrayUtil.valuesToUnic(packages);

					for (i = 0; i < storage.accessories.length; i++)
					{
						accessories.push(storage.accessories[i].id);
						accessoriesReason[storage.accessories[i].id] = storage.accessories[i].awardReason;

						if (storage.accessories[i].isWeared)
						{
							if (dress(KIND_ACCESORIES, storage.accessories[i].id))
								dressChange = true;
						}
						else
						{
							if (undress(KIND_ACCESORIES, storage.accessories[i].id))
								dressChange = true;
						}
					}
					accessories = ArrayUtil.valuesToUnic(accessories);

					dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOTHES_STORAGE_CHANGE));
					if (dressChange)
						dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOTHES_HERO_CHANGE));
					break;
				case PacketClothesWear.PACKET_ID:
					var wear:PacketClothesWear = packet as PacketClothesWear;
					for (i = 0; i < wear.items.length; i++)
					{
						if (wear.items[i].isWeared)
							dress(wear.items[i].kind, wear.items[i].clothesId);
						else
							undress(wear.items[i].kind, wear.items[i].clothesId);
					}
					dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOTHES_HERO_CHANGE));
					break;
				case PacketClothesExpired.PACKET_ID:
					var packetExpired:PacketClothesExpired = packet as PacketClothesExpired;
					if (packetExpired.packageId.length == 0)
					{
						clearSended = false;
						return;
					}
					for (i = 0; i < packetExpired.packageId.length; i++)
					{
						delete packagesLevel[packetExpired.packageId[i]];
						delete packagesTime[packetExpired.packageId[i]];
						delete packagesReason[packetExpired.packageId[i]];
						delete packagesExtraSkill[packetExpired.packageId[i]];

						packages.splice(packages.indexOf(packetExpired.packageId[i]), 1);
					}
					clearSended = false;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOTHES_STORAGE_CHANGE));
					break;
				case PacketClothesSlot.PACKET_ID:
					var packetSlot:PacketClothesSlot = packet as PacketClothesSlot;
					if (packetSlot.status != 0)
						return;
					packagesExtraSkill[packetSlot.packageId] = packetSlot.skillId;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOTHES_STORAGE_CHANGE_MAGIC));
					break;
			}
		}
	}
}