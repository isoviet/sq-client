package game.gameData
{
	import flash.events.EventDispatcher;

	import events.GameEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketDeferredBonus;
	import protocol.packages.server.PacketDeferredBonusAccept;
	import protocol.packages.server.structs.PacketDeferredBonusItems;

	public class DeferredBonusManager
	{
		static public const EMPTY:int = 0;
		static public const COINS:int = 1;
		static public const NUTS:int = 2;
		static public const MANA:int = 3;
		static public const ENERGY:int = 4;
		static public const EXPERIENCE:int = 5;
		static public const ITEMS:int = 6;
		static public const COLLECTIONS:int = 7;
		static public const GOLD_COLLECTIONS:int = 8;
		static public const VIP:int = 9;
		static public const MIGTHY_POTION:int = 10;
		static public const TEMPORARY_CLOTHES:int = 11;
		static public const TEMPORARY_PACKAGES:int = 12;
		static public const HOLIDAY_RATING:int = 13;
		static public const HOLIDAY_TICKET:int = 14;
		static public const PACKAGE_FOREVER:int = 15;
		static public const SKIN:int = 16;
		static public const ACCESSORY:int = 17;

		static public const PACKAGE_LEVEL_UP:int = 18;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var bonuses:Vector.<PacketDeferredBonusItems> = new <PacketDeferredBonusItems>[];

		static public function init():void
		{
			addEventListener(GameEvent.DEFERRED_BONUS_UPDATE, onUpdate);

			Connection.listen(onPacket, [PacketDeferredBonus.PACKET_ID, PacketDeferredBonusAccept.PACKET_ID]);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function receiveBonus(id:int):void
		{
			Connection.sendData(PacketClient.DEFERRED_BONUS_ACCEPT, id);
		}

		static public function getById(id:int):PacketDeferredBonusItems
		{
			for (var i:int = 0; i < bonuses.length; i++)
			{
				if (bonuses[i].id != id)
					continue;
				return bonuses[i];
			}
			return null;
		}

		static public function getByReason(reason:int):Vector.<PacketDeferredBonusItems>
		{
			var answer:Vector.<PacketDeferredBonusItems> = new <PacketDeferredBonusItems>[];
			for (var i:int = 0; i < bonuses.length; i++)
			{
				if (bonuses[i].awardReason != reason)
					continue;
				answer.push(bonuses[i]);
			}
			return answer;
		}

		static private function onUpdate(e:GameEvent):void
		{
			var bonuses:Vector.<PacketDeferredBonusItems> = getByReason(PacketServer.REASON_AMUR);
			if (bonuses.length == 0)
				return;
			bonuses.sort(function(a:PacketDeferredBonusItems, b:PacketDeferredBonusItems):int
			{
				return a.bonusId > b.bonusId ? 1 : -1;
			});
			for (var i:int = 0; i < bonuses.length; i++)
				receiveBonus(bonuses[i].id);
		}

		static private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketDeferredBonus.PACKET_ID:
					bonuses = bonuses.concat((packet as PacketDeferredBonus).items);
					dispatcher.dispatchEvent(new GameEvent(GameEvent.DEFERRED_BONUS_UPDATE));
					break;
				case PacketDeferredBonusAccept.PACKET_ID:
					var packetAccept:PacketDeferredBonusAccept = packet as PacketDeferredBonusAccept;
					if (packetAccept.status == 0)
						dispatcher.dispatchEvent(new GameEvent(GameEvent.DEFERRED_BONUS_ACCEPT, {'id': packetAccept.id, 'type': packetAccept.type, 'count': packetAccept.bonusCount}));
					else
						dispatcher.dispatchEvent(new GameEvent(GameEvent.DEFERRED_BONUS_REJECT, {'id': packetAccept.id, 'type': packetAccept.type, 'count': packetAccept.bonusCount}));

					if (packetAccept.status != 0)
						return;
					switch (packetAccept.type)
					{
						case COLLECTIONS:
							CollectionManager.incItem(CollectionsData.TYPE_REGULAR, (packetAccept.bonusId + 256) % 256, packetAccept.bonusCount);
							break;
					}
					break;
			}
		}
	}
}