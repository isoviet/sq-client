package clans
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	import dialogs.DialogInfo;
	import dialogs.clan.DialogClanNews;
	import events.ClanEvent;
	import events.ClanNoticeEvent;
	import footers.FooterTop;
	import headers.HeaderExtended;
	import loaders.ScreensLoader;
	import screens.ScreenClan;
	import screens.ScreenProfile;
	import screens.Screens;
	import views.dialogEvents.PostClanInviteView;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketClanBalance;
	import protocol.packages.server.PacketClanInfo;
	import protocol.packages.server.PacketClanJoin;
	import protocol.packages.server.PacketClanLeave;
	import protocol.packages.server.PacketClanState;
	import protocol.packages.server.PacketClanSubstitute;
	import protocol.packages.server.PacketEvents;

	import utils.ArrayUtil;

	public class ClanManager extends EventDispatcher
	{
		static public const MAX_SUBLEADERS_COUNT:int = 10;

		static private var clansCollection:Object = {};
		static private var loadedClanMembers:Object = {};

		static private var clanApplicationClosed:DialogInfo;
		static private var clanApplicationBlocked:DialogInfo;

		static private var lowLevelClan:int = -1;
		static private var isNewClan:Boolean = false;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public var subLeaderIds:Vector.<int> = new Vector.<int>();

		static public var selfClanDonations:Array = null;
		static public var selfClanNews:String = null;

		static public function init():void
		{
			Connection.listen(onPacket, [PacketEvents.PACKET_ID, PacketClanState.PACKET_ID, PacketClanJoin.PACKET_ID,
				PacketClanLeave.PACKET_ID, PacketClanInfo.PACKET_ID, PacketClanBalance.PACKET_ID,
				PacketClanSubstitute.PACKET_ID]);
			Game.listen(onLoadPlayer);
			listen(onLoadClan);
		}

		static public function listen(listener:Function, type:String = ClanEvent.NAME):void
		{
			dispatcher.addEventListener(type, listener, false, 0, true);
		}

		static public function forget(listener:Function, type:String = ClanEvent.NAME):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function notify(clan:Clan, fromCache:Boolean = false, type:uint = uint.MAX_VALUE):void
		{
			dispatcher.dispatchEvent(new ClanEvent(clan, fromCache));
			clan.dispatchEvent(type);
		}

		static public function getClan(id:int):Clan
		{
			if (!(id in clansCollection))
				clansCollection[id] = new Clan(id);
			return clansCollection[id];
		}

		//TODO ГОВноКОД какого нельзя сделать как в Game?!
		static public function request(ids:*, nocache:Boolean = false, type:uint = uint.MAX_VALUE):void
		{
			if (type == uint.MAX_VALUE)
				type = ClanInfoParser.ALL;

			Logger.add("[Request clan info] ids:" + ((ids is Array) ? "[" + ids.join() + "]" : ids + " nocache:" + nocache));

			if (!(ids is Array))
				ids = [ids];

			var uids:Array = [];

			ids = ArrayUtil.valuesToUnic(ids);

			for each (var id:int in ids)
			{
				if (id == 0)
					continue;

				var clan:Clan = getClan(id);

				clan.checkExpired(nocache);

				if (clan.isLoaded(type))
				{
					notify(clan, true, type);
					continue;
				}

				if (!clan.isLoading(type))
					uids.push(id);

				clan.setLoading(type);
			}

			if (uids.length == 0)
				return;

			Connection.sendData(PacketClient.CLAN_REQUEST, uids, type);
		}

		static private function onNewsChanged(news:String):void
		{
			if (selfClanNews == news)
				return;

			if (selfClanNews == null || (news == ""))
			{
				selfClanNews = news;
				return;
			}

			selfClanNews = news;

			dispatcher.dispatchEvent(new ClanNoticeEvent(ClanNoticeEvent.CLAN_NEWS_CHANGED));

			if (Screens.active is ScreenProfile)
				return;

			new DialogClanNews(news).show();
		}

		static private function onClanClosed(clanId:int):void
		{
			var clan:Clan = getClan(clanId);
			clan.state = PacketServer.CLAN_STATE_CLOSED;
			clan.size = 0;
			clan.ratingPlace = 0;

			if (!(clanId in loadedClanMembers))
				return;

			for each (var player:Player in loadedClanMembers[clanId])
			{
				if (player['clan_id'] != clanId)
					continue;

				player['clan_id'] = 0;
				Game.request(player['id'], PlayerInfoParser.ALL);
			}

			delete loadedClanMembers[clanId];

			if (clan.isComplete())
				notify(clan, true);
		}

		static private function onClanSubstitute(ids: Vector.<int>, action:int, clearOld:Boolean = false):void
		{
			if (clearOld)
			{
				for (var i:int = 0; i < subLeaderIds.length; i++)
				{
					var player:Player = Game.getPlayer(subLeaderIds[i]);
					player['clan_duty'] = Clan.DUTY_NONE;

					if (player.id == Game.selfId)
						FooterTop.haveClan = false;
				}

				Game.request(subLeaderIds, PlayerInfoParser.ALL);

				subLeaderIds = new Vector.<int>();
			}

			switch (action)
			{
				case PacketServer.CLAN_SUBSTITUTE_ADDED:
					if (clearOld)
					{
						subLeaderIds = ids;

						for (i = 0; i < subLeaderIds.length; i++)
						{
							player = Game.getPlayer(subLeaderIds[i]);
							player['clan_duty'] = Clan.DUTY_SUBLEADER;
						}

						Game.request(subLeaderIds, PlayerInfoParser.ALL);
						break;
					}

					for (i = 0; i < ids.length; i++)
					{
						if (subLeaderIds.indexOf(ids[i]) != -1)
							continue;

						subLeaderIds.push(ids[i]);

						player = Game.getPlayer(ids[i]);
						player['clan_duty'] = Clan.DUTY_SUBLEADER;
					}

					Game.request(ids, PlayerInfoParser.ALL);
					break;
				case PacketServer.CLAN_SUBSTITUTE_FIRE:
					if (clearOld)
						break;

					for (i = 0; i < ids.length; i++)
					{
						var index:int = subLeaderIds.indexOf(ids[i]);

						if (index == -1)
							continue;

						subLeaderIds.splice(index, 1);

						player = Game.getPlayer(ids[i]);
						player['clan_duty'] = Clan.DUTY_NONE;
					}

					Game.request(ids, PlayerInfoParser.ALL);
					break;
			}

			dispatcher.dispatchEvent(new ClanNoticeEvent(ClanNoticeEvent.CLAN_SUBLEADERS_CHANGED));
		}

		static public function dataLoaded(data:Object, type:uint = uint.MAX_VALUE):void
		{
			var clan:Clan = getClan(data['id']);

			clan.loadData(data);
			clan.setLoaded(type);

			if (clan.isComplete())
				notify(clan, false, type);
		}

		static private function onLoadClan(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if (lowLevelClan == clan.id)
			{
				new DialogInfo(gls("Низкий уровень"), gls("Вы не можете вступить в данный\nклан, так как ваш уровень ниже {0}", getClan(lowLevelClan).levelLimiter)).show();
				lowLevelClan = -1;
				return;
			}

			if (Game.self['clan_id'] != clan.id)
				return;

			onNewsChanged(clan.news);
			if (isNewClan)
			{
				isNewClan = false;
				//new DialogRepost(WallTool.WALL_CLAN_CREATE).show();
			}
		}

		static private function onLoadPlayer(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player['clan_id'] == 0)
				return;

			if (!(player['clan_id'] in loadedClanMembers))
				loadedClanMembers[player['clan_id']] = {};

			loadedClanMembers[player['clan_id']][player['id']] = player;
		}

		static private function parseClansData(data:ByteArray, mask:int):Array
		{
			var clansArray:Array = ClanInfoParser.parse(data, mask);

			var ids:Array = [];

			for each (var dataP:Object in clansArray)
			{
				ids.push(dataP['id']);
				dataLoaded(dataP, mask);
			}
			return ids;
		}

		static private function onPacket(packet: AbstractServerPacket):void
		{
			var clan:Clan;
			switch (packet.packetId)
			{
				case PacketEvents.PACKET_ID:
					//TODO МАКСУ! Разобраться с этим овном
					/*var events: PacketEvents = packet as PacketEvents;
					var eventsData:Array = events.items;

					if (eventsData.length != 5)
						break;

					switch (eventsData[1])
					{
						case PacketServer.CLAN_CLOSE_EVENT:
							onClanClosed(eventsData[3]);
							break;
						case PacketServer.CLAN_REJECT:
							if (eventsData[3] != Game.clanApplication)
								break;
							Game.clanApplication = 0;
							break;
						case PacketServer.CLAN_BLOCK_EVENT:
							if (eventsData[3] != Game.self['clan_id'])
								break;

							clan = getClan(Game.self['clan_id']);
							clan.state = PacketServer.CLAN_STATE_BLOCKED;
							request(Game.self['clan_id']);
							break;
					}*/
					break;
				case PacketClanState.PACKET_ID:
					var clanState: PacketClanState = packet as PacketClanState;

					switch (clanState.status)
					{
						case PacketServer.CLAN_STATE_SUCCESS:
							if ((Game.self['clan_id'] != 0) || (clanState.clanId == 0))
								break;

							Game.self['clan_duty'] = Clan.DUTY_LEADER;
							Game.self['clan_id'] = clanState.clanId;

							ScreenProfile.setPlayerId(Game.selfId);
							ScreensLoader.load(ScreenClan.instance);

							ScreenProfile.onClanCreate();
							ScreenClan.onClanCreate();

							isNewClan = true;

							FooterTop.haveClan = true;

							clan = getClan(clanState.clanId);
							clan.size = 1;

							Game.request(Game.selfId, PlayerInfoParser.ALL);
							request(Game.self['clan_id'], true);
							break;
						case PacketServer.CLAN_STATE_CLOSED:
							if (Game.clanApplication == clanState.clanId)
							{
								Game.clanApplication = 0;
								if (clanApplicationClosed == null)
									clanApplicationClosed = new DialogInfo(gls("Клан закрыт"), gls("Клан, в который ты подал заявку, закрыт."), false);
								clanApplicationClosed.show();
							}

							onClanClosed(clanState.clanId);
							break;
						case PacketServer.CLAN_STATE_BLOCKED:
							if (Game.clanApplication == clanState.clanId || PostClanInviteView.inviteClanId == clanState.clanId)
							{
								if (clanApplicationBlocked == null)
									clanApplicationBlocked = new DialogInfo(gls("Клан заблокирован"), gls("Клан, в который ты подал заявку, заблокирован."), false);
								clanApplicationBlocked.show();

								Game.clanApplication = 0;
								PostClanInviteView.inviteClanId = 0;
							}

							clan = getClan(clanState.clanId);
							clan.state = PacketServer.CLAN_STATE_BLOCKED;

							request(clan.id);
							break;
						case PacketServer.CLAN_STATE_BANNED:
							if (Game.clanApplication != clanState.clanId)
								break;

							clan = getClan(clanState.clanId);
							clan.state = PacketServer.CLAN_STATE_BANNED;

							Game.clanApplication = 0;
							if (clanApplicationBlocked == null)
								clanApplicationBlocked = new DialogInfo(gls("Клан заблокирован"), gls("Клан, в который ты подал заявку, заблокирован."), false);
							clanApplicationBlocked.show();
							request(clan.id);
							break;
						case PacketServer.CLAN_BLACKLIST:
							new DialogInfo(gls("Вы в черном списке"), gls("Вы не можете вступить в данный клан,\nтак как вы в черном списке этого клана")).show();
							break;
						case PacketServer.CLAN_LOW_LEVEL:
							if (Experience.selfLevel >= getClan(clanState.clanId).levelLimiter)
							{
								lowLevelClan = clanState.clanId;
								request(clanState.clanId, true);
								return;
							}
							new DialogInfo(gls("Низкий уровень"), gls("Вы не можете вступить в данный\nклан, так как ваш уровень ниже {0}", getClan(clanState.clanId).levelLimiter)).show();
							break;
					}
					break;
				case PacketClanJoin.PACKET_ID:
				{
					var clanJoin: PacketClanJoin = packet as PacketClanJoin;

					switch (clanJoin.playerId)
					{
						case Game.selfId:
							Game.self['clan_duty'] = Clan.DUTY_NONE;
							Game.self['clan_id'] = clanJoin.clanId;
							Game.clanApplication = 0;

							if (Screens.active is ScreenProfile && ScreenProfile.playerId == Game.selfId)
							{
								Screens.show("Clan");
								ScreenProfile.onClanCreate();
								ScreenClan.onClanCreate();
							}

							FooterTop.haveClan = true;

							Game.request(Game.selfId, PlayerInfoParser.ALL);
							request(Game.self['clan_id'], true);
							break;
						default:
							clan = getClan(Game.self['clan_id']);
							clan.size++;

							var player:Player = Game.getPlayer(clanJoin.playerId);
							player['clan_id'] = Game.self['clan_id'];

							Game.request(clanJoin.playerId, PlayerInfoParser.ALL);
							request(Game.self['clan_id']);
							break;
					}
					break;
				}
				case PacketClanLeave.PACKET_ID:
				{
					var clanLeave: PacketClanLeave = packet as PacketClanLeave;

					switch (clanLeave.playerId)
					{
						case Game.selfId:
							clan = getClan(Game.self['clan_id']);
							clan.size--;

							if (Game.self['clan_duty'] == Clan.DUTY_LEADER)
								onClanClosed(clan.id);

							Game.self['clan_duty'] = Clan.DUTY_NONE;
							Game.self['clan_id'] = 0;

							onClanSubstitute(new Vector.<int>(), PacketServer.CLAN_SUBSTITUTE_FIRE, true);

							if (Screens.active is ScreenClan)
							{
								ScreenProfile.setPlayerId(Game.selfId);
								Screens.show("Profile");
							}
							else if (Screens.active is ScreenProfile)
								HeaderExtended.toggleButtons(true);

							ScreenProfile.onClanDispose();
							ScreenClan.onClanDispose();

							selfClanNews = null;

							Game.request(clanLeave.playerId, PlayerInfoParser.ALL);
							request(clan.id);

							FooterTop.haveClan = false;
							break;
						default:
							player = Game.getPlayer(clanLeave.playerId);
							clan = getClan(player['clan_id']);

							clan.size--;
							player['clan_id'] = 0;

							Game.request(clanLeave.playerId, PlayerInfoParser.ALL);

							request(clan.id);
							break;
					}
					break;
				}
				case PacketClanInfo.PACKET_ID:
					var clanInfo: PacketClanInfo = packet as PacketClanInfo;

					trace(clanInfo.data.length, clanInfo.data.bytesAvailable);
					parseClansData(clanInfo.data, clanInfo.mask);
					break;
				case PacketClanBalance.PACKET_ID:
					var balance: PacketClanBalance = packet as PacketClanBalance;

					clan = getClan(Game.self['clan_id']);

					clan.coins = balance.coins;
					clan.acorns = balance.nuts;

					if ((clan.coins - balance.coins < 0 && clan.coins >= 0) || (clan.acorns - balance.nuts < 0 && clan.acorns >= 0))
					{
						request(clan.id, true);
						break;
					}

					request(clan.id);
					break;
				case PacketClanSubstitute.PACKET_ID:
					var clanSubstitute: PacketClanSubstitute = packet as PacketClanSubstitute;

					if (clanSubstitute.status == -1)
					{
						onClanSubstitute(clanSubstitute.playerIds, PacketServer.CLAN_SUBSTITUTE_ADDED, true);
						break;
					}

					onClanSubstitute(clanSubstitute.playerIds, clanSubstitute.status, false);

					if (!ClanRoom.inited)
						break;

					if (clanSubstitute.playerIds.length == 1 && clanSubstitute.playerIds[0] == Game.selfId)
					{
						dispatcher.dispatchEvent(new ClanNoticeEvent(ClanNoticeEvent.CLAN_TRANSACTIONS_UPDATE));

						if (clanSubstitute.status > -1 && ClanRoom.requestApplications)
							Connection.sendData(PacketClient.CLAN_GET_APPLICATION);
						else
							ClanRoom.applicationCount = 0;
					}
					break;
			}
		}
	}
}