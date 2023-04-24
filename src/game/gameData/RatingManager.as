package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import dialogs.DialogRatingLeague;
	import dialogs.DialogRatingSeason;
	import events.GameEvent;
	import screens.Screens;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRatingDivision;
	import protocol.packages.server.PacketRatingScores;
	import protocol.packages.server.PacketRatingTop;
	import protocol.packages.server.PacketRatingTransition;

	import utils.ArrayUtil;

	public class RatingManager
	{
		static private const RATING_START:int = 1438549200;
		static private const RATING_TIME:int = 7 * 24 * 60 * 60;

		static public const BONUS_RATE:Number = 0.1;

		static public const FIRST_SEASON:int = 0;
		static public const CURRENT_SEASON:int = 1;
		static public const CHANGE_SEASON:int = 2;
		static public const MISS_SEASON:int = 3;

		static public const JOIN:int = 0;
		static public const LEAVE:int = 1;

		static public const PLAYER_TYPE:int = 0;
		static public const CLAN_TYPE:int = 1;
		static public const MAX_TYPE:int = 2;

		static private var time:int = -1;
		static private var ratingIds:Object = {};
		static private var ratingValue:Object = {};
		static private var division_id:Object = {};

		static private var topIds:Object = {};
		static private var topPlaces:Object = {};

		static private var inited:Boolean = false;
		static private var sendedTop:Object = {};

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			Connection.listen(onPacket, [PacketRatingDivision.PACKET_ID, PacketRatingTransition.PACKET_ID,
				PacketRatingScores.PACKET_ID, PacketRatingTop.PACKET_ID]);

			request();

			requestTop(PLAYER_TYPE);
			requestTop(CLAN_TYPE);

			addEventListener(GameEvent.LEAGUE_CHANGED, onLeague);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function get currentSeason():int
		{
			return (Game.unix_time + int(getTimer() / 1000) - RATING_START) / RATING_TIME;
		}

		static public function getLastSeasonValue(history:Array):int
		{
			if (!history)
				return 0;
			var lastSeason:int = currentSeason - 1;
			for (var i:int = 0; i < history.length; i += 2)
			{
				if (history[i] != lastSeason)
					continue;
				return history[i + 1];
			}
			return 0;
		}

		static public function get seasonTime():int
		{
			return time;
		}

		static public function setSelfDelta(type:int, delta:int):void
		{
			dispatcher.dispatchEvent(new GameEvent(GameEvent.PLACE_CHANGED, {'type': type, 'value': delta}));
		}

		static public function setPlayerTopPlace(player:int, place:int):void
		{
			topPlaces[player] = place;
		}

		static public function getPlayerTopPlace(player:int):int
		{
			if (player in topPlaces)
				return topPlaces[player];
			return -1;
		}

		static public function getTopIds(type:int):Vector.<int>
		{
			if (type in topIds)
				return ArrayUtil.arrayIntToVector(topIds[type]);
			return new Vector.<int>();
		}

		static public function getIds(type:int):Vector.<int>
		{
			if (type in ratingIds)
				return ArrayUtil.arrayIntToVector(ratingIds[type]);
			return new Vector.<int>();
		}

		static public function getLeague(value:int, type:int):int
		{
			for (var i:int = 0; i < GameConfig.getLeagueCount(type); i++)
			{
				if (GameConfig.getLeagueValue(i, type) <= value)
					continue;
				break;
			}
			return i - 1;
		}

		static public function getScore(type:int):int
		{
			switch (type)
			{
				case PLAYER_TYPE:
					return Game.self['rating_score'];
			}
			return 0;
		}

		static public function getRemainedScore(type:int):int
		{
			if (getSelfLeague(type) == GameConfig.getLeagueCount(type) - 1)
				return 0;
			if (getSelfLeague(type) != getLeague(getScore(type), type))
				return 0;
			return GameConfig.getLeagueValue(getSelfLeague(type) + 1, type) - getScore(type);
		}

		static public function getSelfLeague(type:int):int
		{
			return getIds(type).length == 0 ? 0 : getLeague(getScore(type), type);
		}

		static public function request():void
		{
			Connection.sendData(PacketClient.RATING_REQUEST);
		}

		static public function requestTop(type:int):void
		{
			if (type in sendedTop && sendedTop[type])
				return;
			sendedTop[type] = true;
			Connection.sendData(PacketClient.RATING_REQUEST_TOP, type);
		}

		static private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRatingDivision.PACKET_ID:
					var division: PacketRatingDivision = packet as PacketRatingDivision;

					if (division.newSeason != CURRENT_SEASON && division.newSeason != FIRST_SEASON)
						clearSeason(division.newSeason);

					time = Math.max(1, division.time);

					var updateLeague:Boolean = (getIds(division.ratingType).length == 0) == (division.elementsId != null);

					division_id[division.ratingType] = division.divisionId;
					ratingIds[division.ratingType] = division.elementsId == null ? new Vector.<int>() : division.elementsId;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.DIVISION_CHANGED, {'type': division.ratingType}));

					if (updateLeague)
					{
						dispatcher.dispatchEvent(new GameEvent(GameEvent.LEAGUE_CHANGED, {'value': getSelfLeague(division.ratingType), 'type': division.ratingType}));
						if (getSelfLeague(division.ratingType) > 0 && inited && division.newSeason == CURRENT_SEASON)
							showDialog(getSelfLeague(division.ratingType));
					}

					if (!inited && time > 0)
					{
						EnterFrameManager.addPerSecondTimer(onTimer);
						inited = true;
					}
					break;
				case PacketRatingTransition.PACKET_ID:
					var transition: PacketRatingTransition = packet as PacketRatingTransition;

					if (!(transition.ratingType in ratingIds))
						return;

					switch (transition.transitionType)
					{
						case JOIN:
							(ratingIds[transition.ratingType] as Vector.<int>).push(transition.elementId);
							break;
						case LEAVE:
							var index:int = (ratingIds[transition.ratingType] as Vector.<int>).indexOf(transition.elementId);
							if (index != -1)
								(ratingIds[transition.ratingType] as Vector.<int>).splice(index, 1);
							break;
					}
					dispatcher.dispatchEvent(new GameEvent(GameEvent.DIVISION_CHANGED,
						{'type': transition.ratingType, 'reason': transition.transitionType,
							'delta': [transition.elementId]}));
					break;
				case PacketRatingScores.PACKET_ID:
					var scores: PacketRatingScores = packet as PacketRatingScores;

					var firstInfo:Boolean = !(scores.ratingType in ratingValue);
					var lastValue:int = firstInfo ? 0 : ratingValue[scores.ratingType];
					ratingValue[scores.ratingType] = scores.value;

					if (scores.ratingType == PLAYER_TYPE)
						Game.self['rating_score'] = scores.value;

					checkNewLeague(lastValue, ratingValue[scores.ratingType], scores.ratingType, firstInfo);

					dispatcher.dispatchEvent(new GameEvent(GameEvent.RATING_CHANGED,
						{'type': scores.ratingType, 'value': ratingValue[scores.ratingType],
							'delta': ratingValue[scores.ratingType] - lastValue}));
					break;
				case PacketRatingTop.PACKET_ID:
					var top: PacketRatingTop = packet as PacketRatingTop;

					sendedTop[top.ratingType] = false;

					var lastIds:Vector.<int> = getTopIds(top.ratingType);
					topIds[top.ratingType] = top.elements;

					if (lastIds.length == 0)
						dispatcher.dispatchEvent(new GameEvent(GameEvent.TOP_CHANGED, {'type': top.ratingType}));
					else
					{
						var a:Array = ArrayUtil.parseIntVector(getTopIds(top.ratingType));
						var b:Array = ArrayUtil.parseIntVector(lastIds);
						var toAdd:Array = ArrayUtil.getDifference(a, b);
						var toRemove:Array = ArrayUtil.getDifference(b, a);
						if (toAdd.length != 0)
							dispatcher.dispatchEvent(new GameEvent(GameEvent.TOP_CHANGED, {'type': top.ratingType, 'reason': JOIN, 'delta': toAdd}));
						if (toRemove.length != 0)
							dispatcher.dispatchEvent(new GameEvent(GameEvent.TOP_CHANGED, {'type': top.ratingType, 'reason': LEAVE, 'delta': toRemove}));
					}
					break;
			}
		}

		static private function checkNewLeague(lastValue:int, value:int, type:int, firstInfo:Boolean):void
		{
			if (getLeague(lastValue, type) == getLeague(value, type) && !firstInfo)
				return;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.LEAGUE_CHANGED, {'value': getLeague(value, type), 'type': type}));

			if (type != PLAYER_TYPE || getSelfLeague(type) == 0 || firstInfo)
				return;
			showDialog(getLeague(value, type));
		}

		static private function onLeague(e:GameEvent):void
		{
			if (e.data['value'] < GameConfig.getLeagueCount(e.data['type']) - 1)
				return;
			requestTop(e.data['type']);
		}

		static private function showDialog(league:int):void
		{
			Screens.addCallback(function():void
			{
				new DialogRatingLeague(league).show();
			});
		}

		static private function clearSeason(state:int):void
		{
			dispatcher.dispatchEvent(new GameEvent(GameEvent.SEASON_CHANGED));

			Game.request(Game.selfId, PlayerInfoParser.RATING_INFO | PlayerInfoParser.RATING_HISTORY, true);

			var value:int = PLAYER_TYPE in ratingValue ? ratingValue[PLAYER_TYPE] : -1;
			Screens.addCallback(function():void
			{
				new DialogRatingSeason(state, value).show();
			});

			ratingIds = {};
			ratingValue = {};
			topIds = {};
			topPlaces = {};

			for (var i:int = 0; i < MAX_TYPE; i++)
				requestTop(i);
		}

		static private function onTimer():void
		{
			if (time <= 0)
				return;
			time--;
			if (time <= 0)
				request();
		}
	}
}