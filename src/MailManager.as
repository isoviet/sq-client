package
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	import dialogs.DialogMapApproved;
	import events.GameEvent;
	import game.gameData.NotificationManager;
	import screens.ScreenLocation;
	import screens.Screens;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketClanJoin;
	import protocol.packages.server.PacketEvents;
	import protocol.packages.server.PacketGifts;
	import protocol.packages.server.PacketGiftsTarget;
	import protocol.packages.server.structs.PacketEventsItems;
	import protocol.packages.server.structs.PacketGiftsItems;

	import utils.UInt64;

	public class MailManager
	{
		static public var dialogsArray:Array = [];
		static public var eventsArray:Vector.<PacketEventsItems> = new Vector.<PacketEventsItems>();
		static public var giftsArray: Vector.<PacketGiftsItems> = new Vector.<PacketGiftsItems>();
		static public var friendsArray:Vector.<int> = null;

		static private var dispatcher:EventDispatcher = new EventDispatcher();
		static private var timeToUpdate:int = 0;

		static public function init():void
		{
			Connection.listen(onPacket, [PacketGifts.PACKET_ID, PacketGiftsTarget.PACKET_ID, PacketEvents.PACKET_ID, PacketClanJoin.PACKET_ID]);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function addDemoMail():void
		{
			var bytes: ByteArray = new ByteArray();
			UInt64.to64(0,0).write(bytes);
			bytes.writeByte(PacketServer.MAIL_DEMO);
			bytes.writeInt(0);
			bytes.writeInt(0);
			bytes.writeInt(Game.unix_time);
			bytes.position = 0;
			eventsArray.push(new PacketEventsItems(bytes));

			dispatcher.dispatchEvent(new GameEvent(GameEvent.EVENT_CHANGE));
		}

		static private function onPacket(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketGifts.PACKET_ID:
					giftsArray = (packet as PacketGifts).items;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.GIFT_CHANGE));

					checkTime();
					break;
				case PacketEvents.PACKET_ID:
					var lastClanNewsEventId:int = -1;
					var clanClosedIdArray:Array = [];
					var clanMemberIdArray:Array = [];
					var clanInvites:Object = {};

					var data:Vector.<PacketEventsItems> = (packet as PacketEvents).items;

					for (var i:int = 0; i < data.length; i++)
					{
						switch (data[i].type)
						{
							case PacketServer.MAP_APPROVED:
								dialogsArray.push(new DialogMapApproved(data[i].actorId, data[i].data));
								break;
							case PacketServer.CLAN_NEWS_EVENT:
								lastClanNewsEventId = parseInt(data[i].id);
								break;
							case PacketServer.CLAN_CLOSE_EVENT:
								clanClosedIdArray.push(data[i].data);
								break;
							case PacketServer.CLAN_INVITE:
								clanInvites[data[i].data] = data;
							case PacketServer.CLAN_KICK:
								clanMemberIdArray.push(data[i].data);
								break;
						}
					}

					if (Screens.active is ScreenLocation)
					{
						for (i = 0; i < dialogsArray.length; i++)
							dialogsArray[i].show();
					}

					eventsArray = eventsArray.concat(data);
					if (lastClanNewsEventId != -1)
						clearOldNews(lastClanNewsEventId);
					if (clanClosedIdArray.length != 0)
						clearClanEvents(clanClosedIdArray);
					if (clanMemberIdArray.length != 0)
						clearClanInvites(clanMemberIdArray);
					for each (var clanInvite:Object in clanInvites)
						eventsArray = eventsArray.concat(clanInvite);

					//AMUR
					var isAmur:Function = function(element:PacketEventsItems, index:int, parent:Vector.<PacketEventsItems>):Boolean
					{
						return (element.type == PacketServer.AMUR_MAIL);
					};
					var notAmur:Function = function(element:PacketEventsItems, index:int, parent:Vector.<PacketEventsItems>):Boolean
					{
						return (element.type != PacketServer.AMUR_MAIL);
					};
					var amur:Vector.<PacketEventsItems> = eventsArray.filter(isAmur);
					if (amur.length > 10)
						eventsArray = eventsArray.filter(notAmur).concat(amur.slice(0, 10));
					//AMUR

					dispatcher.dispatchEvent(new GameEvent(GameEvent.EVENT_CHANGE));

					if (eventsArray.length > 0)
						NotificationDispatcher.show(NotificationManager.MAIL);
					break;
				case PacketClanJoin.PACKET_ID:
					var clanJoin: PacketClanJoin = packet as PacketClanJoin;
					if (clanJoin.playerId != Game.selfId)
						break;
					clearClanInvites([clanJoin.clanId]);
					dispatcher.dispatchEvent(new GameEvent(GameEvent.EVENT_CHANGE));

					if (eventsArray.length > 0)
						NotificationDispatcher.show(NotificationManager.MAIL);
					break;
				case PacketGiftsTarget.PACKET_ID:
					friendsArray = (packet as PacketGiftsTarget).ids;

					ScreenLocation.sortMenu();
					break;
			}
		}

		static private function clearOldNews(eventId:int):void
		{
			var toDelete:Array = [];
			for (var i:int = 0; i < eventsArray.length; i++)
			{
				if (eventsArray[i].type != PacketServer.CLAN_NEWS_EVENT || (parseInt(eventsArray[i].id) == eventId && Game.self['clan_id'] != 0))
					continue;
				toDelete.push(i);
			}

			for (i = toDelete.length - 1; i >= 0; i--)
				eventsArray.splice(toDelete[i], 1);
		}

		static private function clearClanEvents(clanIds:Array):void
		{
			var toDelete:Array = [];
			for (var i:int = 0; i < eventsArray.length; i++)
			{
				switch (eventsArray[i].type)
				{
					case PacketServer.CLAN_INVITE:
					case PacketServer.CLAN_KICK:
					case PacketServer.CLAN_ACCEPT:
					case PacketServer.CLAN_REJECT:
					case PacketServer.CLAN_BLOCK_EVENT:
					case PacketServer.CLAN_NEWS_EVENT:
						break;
					default:
						continue;
				}
				if (clanIds.indexOf(eventsArray[i].data) == -1)
					continue;
				toDelete.push(i);
			}

			for (i = toDelete.length - 1; i >= 0; i--)
				eventsArray.splice(toDelete[i], 1);
		}

		static private function clearClanInvites(clanIds:Array):void
		{
			var toDelete:Array = [];
			for (var i:int = 0; i < eventsArray.length; i++)
			{
				if (eventsArray[i].type != PacketServer.CLAN_INVITE || clanIds.indexOf(eventsArray[i].data) == -1)
					continue;
				toDelete.push(i);
			}

			for (i = toDelete.length - 1; i >= 0; i--)
				eventsArray.splice(toDelete[i], 1);
		}

		static private function checkTime():void
		{
			var time:int = Game.unix_time + int(getTimer() / 1000);
			for (var i:int = 0; i < giftsArray.length; i++)
			{
				if (giftsArray[i].time < time)
				{
					NotificationDispatcher.show(NotificationManager.MAIL);
					continue;
				}
				if (timeToUpdate != 0 && timeToUpdate < (giftsArray[i].time - time))
					continue;
				timeToUpdate = giftsArray[i].time - time;
			}
			if (timeToUpdate != 0)
				EnterFrameManager.addPerSecondTimer(onTime);
		}

		static private function onTime():void
		{
			timeToUpdate--;

			if (timeToUpdate != 0)
				return;
			EnterFrameManager.removePerSecondTimer(onTime);
			dispatcher.dispatchEvent(new GameEvent(GameEvent.ON_CHANGE));

			checkTime();
		}
	}
}