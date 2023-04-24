package game.gameData
{
	import flash.events.EventDispatcher;

	import dialogs.DialogGoldenCupRepostView;
	import events.GameEvent;
	import loaders.ScreensLoader;
	import screens.ScreenProfile;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBalance;
	import protocol.packages.server.PacketBonuses;
	import protocol.packages.server.PacketOffers;
	import protocol.packages.server.PacketProduceInfo;

	import utils.StringUtil;

	public class ProduceManager
	{
		static public var COUNT_GOLD: int = 510;
		static public var FOR_DAYS: int = 30;
		static public var COUNT_GOLD_IN_TIME: int = 17;
		static public var COUNT_HOLIDAY_IN_TIME: int = 10;

		static private const TIME:int = 0;
		static private const BONUS:int = 1;

		static public const GOLDEN_CUP:int = 0;
		static public const HOLIDAY:int = 1;
		static public const MAX_TYPE:int = 2;

		static private var timeLeft:Object = {};
		static private var timeBonus:Object = {};

		static private var inited:Object = {};
		static private var bonusRequested:Object = {};

		static private var timers:Array = [];

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			Connection.listen(onPacket, [PacketProduceInfo.PACKET_ID, PacketOffers.PACKET_ID, PacketBalance.PACKET_ID, PacketBonuses.PACKET_ID]);

			for (var i:int = 0; i < MAX_TYPE; i++)
			{
				timeLeft[i] = 0;
				timeBonus[i] = 0;
				inited[i] = false;
				bonusRequested[i] = false;
				Connection.sendData(PacketClient.PRODUCE_REQUEST, i, TIME);
			}
		}

		static public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		static public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		static public function haveBonus(type:int):Boolean
		{
			return timeLeft[type] > 0 && timeBonus[type] == 0;
		}

		static public function haveProducer(type:int):Boolean
		{
			return timeLeft[type] > 0;
		}

		static public function timeString(type:int):String
		{
			var answer:String = "";
			if (timeLeft[type] == 0)
				return answer;
			if (timeBonus[type] > 0)
				answer += gls("Следующий бонус:") + " <b>" + new Date(0, 0, 0, 0, 0, timeBonus[type]).toTimeString().slice(0, 8) + "</b>\n";
			answer += gls("До окончания:") + "<b> ";
			var days:int = timeLeft[type] / (24 * 60 * 60);
			if (days > 0)
				answer += days + " " + StringUtil.word("день", days) + "</b>";
			else
				answer += new Date(0, 0, 0, 0, 0, timeLeft[type]).toTimeString().slice(0, 8) + "</b>";

			return answer;
		}

		static public function requestTime(type:int):void
		{
			Connection.sendData(PacketClient.PRODUCE_REQUEST, type, TIME);
		}

		static public function getBonus(type:int):void
		{
			if (bonusRequested[type])
				return;
			bonusRequested[type] = true;
			Connection.sendData(PacketClient.PRODUCE_REQUEST, type, BONUS);
		}

		static private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketProduceInfo.PACKET_ID:
					var produce:PacketProduceInfo = packet as PacketProduceInfo;

					var active:Boolean = haveProducer(produce.type);
					var bonus:Boolean = haveBonus(produce.type);
					timeLeft[produce.type] = produce.timeLeft;
					timeBonus[produce.type] = produce.timeBonus;

					if (bonus && !haveBonus(produce.type))
						dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_BONUS_END, {'type': produce.type}));

					if (!inited[produce.type] && timeLeft[produce.type] > 0 && timeBonus[produce.type] == 0)
						dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_BONUS_START, {'type': produce.type}));
					if (timeLeft[produce.type] > 0)
					{
						if (!active)
							dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_START, {'type': produce.type}));
						if (timers.length == 0)
							EnterFrameManager.addPerSecondTimer(onTimer);
						if (timers.indexOf(produce.type) == -1)
							timers.push(produce.type);
					}
					inited[produce.type] = true;
					break;
				case PacketOffers.PACKET_ID:
					switch ((packet as PacketOffers).offer)
					{
						case PacketServer.OFFER_GOLDEN_CUP:
							ScreensLoader.load(ScreenProfile.instance, onShowRepostView);
							ScreenProfile.setPlayerId(Game.selfId);

							Connection.sendData(PacketClient.PRODUCE_REQUEST, GOLDEN_CUP, TIME);
							break;
						case BundleManager.HOLIDAY_BOOSTER_OFFER:
							new DialogGoldenCupRepostView().show();

							Connection.sendData(PacketClient.PRODUCE_REQUEST, HOLIDAY, TIME);
							break;
					}
					break;
				case PacketBalance.PACKET_ID:
					if ((packet as PacketBalance).reason != PacketServer.REASON_GOLDEN_CUP)
						return;
					bonusRequested[GOLDEN_CUP] = false;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_BONUS, {'type': GOLDEN_CUP}));
					break;
				case PacketBonuses.PACKET_ID:
					if ((packet as PacketBonuses).awardReason != PacketServer.REASON_HOLIDAY_BOOSTER)
						return;
					bonusRequested[HOLIDAY] = false;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_BONUS, {'type': HOLIDAY}));
					break;
			}
		}

		static private function onShowRepostView():void
		{
			new DialogGoldenCupRepostView().show();
		}

		static private function onTimer():void
		{
			for (var i:int = timers.length - 1; i >= 0 ; i--)
			{
				checkTime(timers[i]);
				checkBonus(timers[i]);
				dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_UPDATE, {'type': timers[i]}));

				if (timeLeft[timers[i]] == 0)
					timers.splice(i, 1);
			}
			if (timers.length == 0)
				EnterFrameManager.removePerSecondTimer(onTimer);
		}

		static private function checkTime(type:int):void
		{
			if (timeLeft[type] == 0)
				return;
			timeLeft[type]--;
			if (timeLeft[type] != 0)
				return;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_END, {'type': type}));
		}

		static private function checkBonus(type:int):void
		{
			if (timeBonus[type] == 0)
				return;
			timeBonus[type]--;
			if (timeBonus[type] != 0)
				return;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.PRODUCE_BONUS_START, {'type': type}));
		}
	}
}