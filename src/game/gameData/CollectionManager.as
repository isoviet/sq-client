package game.gameData
{
	import flash.events.EventDispatcher;

	import dialogs.DialogRepost;
	import dialogs.collections.DialogCollectionExchangeComplete;
	import events.GameEvent;
	import loaders.RuntimeLoader;
	import views.storage.CollectionsView;
	import views.storage.ScratsClothesView;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBuy;
	import protocol.packages.server.PacketCollectionAssemble;
	import protocol.packages.server.PacketCollectionExchange;
	import protocol.packages.server.PacketCollectionPickup;
	import protocol.packages.server.PacketCollections;
	import protocol.packages.server.PacketRoundElement;
	import protocol.packages.server.PacketRoundElements;
	import protocol.packages.server.structs.PacketCollectionsCollections;

	import utils.ArrayUtil;
	import utils.Counter;
	import utils.WallTool;

	public class CollectionManager
	{
		static public var currentCollectionId:int = -1;
		static public var currentCollectionKind:int = -1;

		static public var regularItems:Vector.<Counter> = new Vector.<Counter>();
		static public var uniqueItems:Vector.<Counter> = new Vector.<Counter>();

		static private var currentExchangeItems:Array = null;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			for (var i:int = 0; i < CollectionsData.regularData.length; i++)
				regularItems.push(new Counter());

			for (i = 0; i < CollectionsData.uniqueData.length; i++)
				uniqueItems.push(new Counter());

			Connection.listen(onPacket, [PacketCollections.PACKET_ID, PacketCollectionPickup.PACKET_ID,
				PacketCollectionAssemble.PACKET_ID, PacketCollectionExchange.PACKET_ID,
				PacketBuy.PACKET_ID, PacketRoundElement.PACKET_ID, PacketRoundElements.PACKET_ID]);

			Game.self.addEventListener(PlayerInfoParser.COLLECTION_EXCHANGE, onPlayerLoaded);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function get haveCollection():Boolean
		{
			return currentCollectionId != -1;
		}

		static public function collectUniqueItem(id:int):void
		{
			Connection.sendData(PacketClient.COLLECTION_ASSEMBLE, CollectionsData.TYPE_UNIQUE, id);
		}

		static public function collectTrophy(id:int):void
		{
			Connection.sendData(PacketClient.COLLECTION_ASSEMBLE, CollectionsData.TYPE_TROPHY, id);
		}

		static public function decItem(type:int, elementId:int, count:int = 1):void
		{
			decPlayerItem(Game.selfId, type, elementId, count);
		}

		static public function incItem(type:int, elementId:int, value:int = 1):void
		{
			incPlayerItem(Game.selfId, type, elementId, value);
		}

		static public function addToExchange(id:int):void
		{
			if (currentExchangeItems.indexOf(id) != -1)
				return;

			var isAdded:Boolean = CollectionsView.addToExchange(id);
			if (!isAdded)
				return;
			CollectionsView.setExchangeItem(id, true);
			Connection.sendData(PacketClient.COLLECTION_EXCHANGE_ADD, [id]);
			Game.self['collection_exchange'] = currentExchangeItems;
		}

		static public function removeFromExchange(id:int, synchronized:Boolean = false):void
		{
			if (!currentExchangeItems)
				return;

			var index:int = currentExchangeItems.indexOf(id);
			if (index == -1)
				return;

			currentExchangeItems.splice(index, 1);

			if (synchronized)
			{
				index = exchangeItems.indexOf(id);
				if (index > -1)
					exchangeItems.splice(index, 1);
			}

			if (!CollectionsView.inited)
				return;

			CollectionsView.setExchangeItem(id, false);
			CollectionsView.removeFromExchange(id);
			Connection.sendData(PacketClient.COLLECTION_EXCHANGE_REMOVE, [id]);
			Game.self['collection_exchange'] = currentExchangeItems;
		}

		static public function saveExchange():void
		{
			var isEqualSearchSets:Boolean = ArrayUtil.compareArrays(currentExchangeItems, exchangeItems);

			if (isEqualSearchSets)
				return;

			var removedElements:Array = [];
			var addedElements:Array = [];

			for (var i:int = 0; i < exchangeItems.length; i++)
			{
				if (currentExchangeItems.indexOf(exchangeItems[i]) != -1)
					continue;
				removedElements.push(exchangeItems[i]);
				Game.self['collection_exchange'].splice(Game.self['collection_exchange'].indexOf(exchangeItems[i]), 1);
			}
			for (i = 0; i < currentExchangeItems.length; i++)
			{
				if (exchangeItems.indexOf(currentExchangeItems[i]) != -1)
					continue;
				addedElements.push(currentExchangeItems[i]);
				Game.self['collection_exchange'].push(currentExchangeItems[i]);
			}

			if (removedElements.length != 0)
				Connection.sendData(PacketClient.COLLECTION_EXCHANGE_REMOVE, removedElements);

			if (addedElements.length != 0)
				Connection.sendData(PacketClient.COLLECTION_EXCHANGE_ADD, addedElements);
		}

		static public function get isExchangeEmpty():Boolean
		{
			if (currentExchangeItems == null)
				return true;
			return currentExchangeItems.length == 0;
		}

		static public function get exchangeItems():Array
		{
			return currentExchangeItems;
		}

		static private function onPlayerLoaded(player:Player):void
		{
			if (player) {/*unused*/}

			Game.self.removeEventListener(onPlayerLoaded);

			currentExchangeItems = Game.self['collection_exchange'].slice();

			for (var i:int = 0; i < currentExchangeItems.length; i++)
			{
				if (!("icon" in CollectionsData.regularData[currentExchangeItems[i]]))
					continue;
				if (regularItems[currentExchangeItems[i]].count >= 2)
					continue;
				currentExchangeItems.splice(i, 1);
				i--;
			}

			if (checkAnyCollected())
				NotificationDispatcher.show(NotificationManager.COLLECTION);
		}

		static public function checkAnyCollected():Boolean
		{
			var check:Boolean;
			for (var collectionId:int = 0, len:int = uniqueItems.length; collectionId < len; collectionId++)
			{
				if (!('set' in CollectionsData.uniqueData[collectionId]))
					continue;

				check = true;
				for each(var id:int in CollectionsData.uniqueData[collectionId]['set'])
					check &&= regularItems[id].count > 0;

				if (check)
					return true;
			}

			return false;
		}

		static public function loadSelf():void
		{
			CollectionsView.setCollectionItems(regularItems, uniqueItems);

			for (var i:int = 0; i < currentExchangeItems.length; i++)
			{
				if (!("icon" in CollectionsData.regularData[currentExchangeItems[i]]))
					continue;

				CollectionsView.setExchangeItem(currentExchangeItems[i], true);
			}

			CollectionsView.setExchangeItems(currentExchangeItems);

			ScratsClothesView.setCollectionItems(uniqueItems);
			ScratsClothesView.updateTrophyClothes();
		}

		static private function onPacket(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketCollections.PACKET_ID:
					var collections:PacketCollections = packet as PacketCollections;
					for each (var collectionData:PacketCollectionsCollections in collections.collections)
					{
						switch (collectionData.type)
						{
							case CollectionsData.TYPE_REGULAR:
								regularItems[collectionData.unsignedElementId].count = collectionData.count;
								break;
							case CollectionsData.TYPE_UNIQUE:
								uniqueItems[collectionData.unsignedElementId].count = collectionData.count;
								break;
						}
					}
					break;
				case PacketCollectionPickup.PACKET_ID:
					var pickup:PacketCollectionPickup = packet as PacketCollectionPickup;
					regularItems[pickup.unsignedElementId].count += pickup.count;

					dispatcher.dispatchEvent(new GameEvent(GameEvent.COLLECTION_PICKUP, {'id': pickup.unsignedElementId, 'value': pickup.count}));
					break;
				case PacketCollectionAssemble.PACKET_ID:
					var collection: PacketCollectionAssemble = packet as PacketCollectionAssemble;

					if (collection.type == CollectionsData.TYPE_UNIQUE)
						CollectionsView.assembleComplete(collection.status == PacketServer.ASSEMBLE_SUCCESS, collection.unsignedElementId);
					else if (collection.type == CollectionsData.TYPE_TROPHY)
						ScratsClothesView.assembleComplete(collection.status == PacketServer.ASSEMBLE_SUCCESS, collection.unsignedElementId);

					if (collection.status == PacketServer.ASSEMBLE_FAIL)
						break;

					switch(collection.type)
					{
						case CollectionsData.TYPE_UNIQUE:
							if (uniqueItems == null || !(collection.unsignedElementId in uniqueItems))
								break;

							incPlayerItem(Game.selfId, CollectionsData.TYPE_UNIQUE, collection.unsignedElementId);

							new DialogRepost(WallTool.WALL_COLLECTION_UNIQUE, collection.unsignedElementId).show();
							break;
						case CollectionsData.TYPE_TROPHY:
							new DialogRepost(WallTool.WALL_COLLECTION_AWARD, collection.unsignedElementId).show();
							if (ScratsClothesView.inited)
								ScratsClothesView.updateTrophyClothes();
							break;
					}
					break;
				case PacketCollectionExchange.PACKET_ID:
					var exchange:PacketCollectionExchange = packet as PacketCollectionExchange;

					exchange.clientItem = int(exchange.clientItem & 0xFF);
					exchange.targetItem = int(exchange.targetItem & 0xFF);
					if (exchange.clientId == Game.selfId)
						RuntimeLoader.load(function():void
						{
							new DialogCollectionExchangeComplete(exchange.clientItem, exchange.targetItem, exchange.status == PacketServer.EXCHANGE_SUCCESS).show();
						}, true);

					if (exchange.status == PacketServer.EXCHANGE_FAIL)
						return;

					if (exchange.clientId == Game.selfId)
						removeFromExchange(exchange.clientItem, true);
					else
						removeFromExchange(exchange.clientItem, true);

					decPlayerItem(exchange.clientId, CollectionsData.TYPE_REGULAR, exchange.clientItem);
					decPlayerItem(exchange.targetId, CollectionsData.TYPE_REGULAR, exchange.targetItem);

					incPlayerItem(exchange.clientId, CollectionsData.TYPE_REGULAR, exchange.clientItem);
					incPlayerItem(exchange.targetId, CollectionsData.TYPE_REGULAR, exchange.targetItem);
					break;
				case PacketBuy.PACKET_ID:
					var buy:PacketBuy = packet as PacketBuy;
					if (buy.status != PacketServer.BUY_SUCCESS || buy.playerId != Game.selfId || buy.goodId != PacketClient.BUY_COLLECTION_ITEM)
						break;
					incPlayerItem(Game.selfId, CollectionsData.TYPE_REGULAR, buy.data);
					break;
				case PacketRoundElements.PACKET_ID:
					CollectionManager.currentCollectionId = -1;
					CollectionManager.currentCollectionKind = -1;
					break;
				case PacketRoundElement.PACKET_ID:
					var elem:PacketRoundElement = packet as PacketRoundElement;
					if (elem.playerId != Game.selfId)
						return;
					CollectionManager.currentCollectionId = int(elem.unsignedElementId & 0xFF);
					CollectionManager.currentCollectionKind = elem.kind & 0xFF;
					break;
			}
		}

		static private function decPlayerItem(playerId:int, type:int, itemId:int, count:int = 1):void
		{
			var player:Player = Game.getPlayer(playerId);

			if (("collection_exchange" in player) && (type == CollectionsData.TYPE_REGULAR))
			{
				var index:int = player['collection_exchange'].indexOf(itemId);
				if (index != -1)
					player['collection_exchange'].splice(index, 1);
			}

			if (playerId != Game.selfId)
				return;

			switch (type)
			{
				case CollectionsData.TYPE_REGULAR:
					regularItems[itemId].count = Math.max(regularItems[itemId].count - count, 0);
					break;
				case CollectionsData.TYPE_UNIQUE:
					uniqueItems[itemId].count = Math.max(uniqueItems[itemId].count - count, 0);
					break;
			}
		}

		static private function incPlayerItem(playerId:int, type:int, itemId:int, value:int = 1):void
		{
			if (playerId != Game.selfId)
				return;

			if (type == CollectionsData.TYPE_REGULAR)
				regularItems[itemId].count += value;

			if (type == CollectionsData.TYPE_UNIQUE)
				uniqueItems[itemId].count += value;
		}
	}
}