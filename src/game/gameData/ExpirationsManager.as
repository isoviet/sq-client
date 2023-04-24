package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import events.GameEvent;

	import protocol.Connection;
	import protocol.packages.server.PacketExpirations;

	import utils.DateUtil;

	public class ExpirationsManager
	{
		static public const MANA:int = 0;
		static public const SUBSCRIBE:int = 1;
		static public const VIP:int = 2;
		static public const CHEST:int = 4;
		static public const RETURN_BONUS:int = 5;
		static public const FRIEND_BONUS:int = 6;
		static public const GOLDEN_CUP:int = 7;
		static public const MANA_FOR_OBJECT:int = 8;
		static public const UNLIMITED_MANA:int = 9;
		static public const FREE_FIRST_PERK:int = 10;
		static public const UNLIMITED_ENERGY:int = 11;
		static public const SHAMAN_FREEPLAY:int = 12;
		static public const MANA_REGENERATION:int = 13;
		static public const BUNDLE_NEWBIE_RICH:int = 14;
		static public const BUNDLE_NEWBIE_POOR:int = 15;
		static public const BUNDLE_LEGENDARY:int = 16;
		static public const HOLIDAY_BOOSTER:int = 17;
		static public const BIRTHDAY_2015:int = 18;

		static public const HOT_WEEKEND:int = 19;

		static private const MANA_REGENERATION_PERIOD:int = 60;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var expirationsData:Object = {};
		static private var expirationsExists:Object = {};

		static private var manaRegenDelay:int = -1;

		static public function init():void
		{
			Connection.listen(onPacket, [PacketExpirations.PACKET_ID]);

			EnterFrameManager.addPerSecondTimer(onTime);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function haveExpiration(type:int):Boolean
		{
			var time:int = int(getTimer() / 1000);
			return (type in expirationsData) && (expirationsData[type] > time);
		}

		static public function isNone(type:int):Boolean
		{
			return !(type in expirationsExists) || !(expirationsExists[type]);
		}

		static public function getDurationString(type:int):String
		{
			if (!(type in expirationsData))
				return "";
			return DateUtil.durationDayTime(expirationsData[type] - int(getTimer() / 1000));
		}

		static public function get timeToManaRegeneration():String
		{
			if (manaRegenDelay == -1)
				return "";
			return DateUtil.formatTime(MANA_REGENERATION_PERIOD - (int(getTimer() / 1000) - manaRegenDelay) % MANA_REGENERATION_PERIOD);
		}

		static private function onPacket(packet:PacketExpirations):void
		{
			for (var i:int = 0; i < packet.items.length; i++)
			{
				expirationsExists[packet.items[i].type] = (packet.items[i].exists != 0);
				expirationsData[packet.items[i].type] = packet.items[i].duration + ((packet.items[i].exists != 0) ? int(getTimer() / 1000) : 0);
				dispatcher.dispatchEvent(new GameEvent(GameEvent.EXPIRATIONS_CHANGE, {'type': packet.items[i].type}));
			}

			if (manaRegenDelay == -1 && (MANA_REGENERATION in expirationsData))
				manaRegenDelay = int(getTimer() / 1000);
		}

		static private function onTime():void
		{
			var time:int = int(getTimer() / 1000);
			for (var id:String in expirationsData)
			{
				if (expirationsData[id] > time)
					dispatcher.dispatchEvent(new GameEvent(GameEvent.ON_CHANGE, {'type': int(id)}));
				else
				{
					delete expirationsData[id];
					dispatcher.dispatchEvent(new GameEvent(GameEvent.EXPIRATIONS_CHANGE, {'type': id}));

					if (int(id) == MANA_REGENERATION)
						manaRegenDelay = -1;
				}
			}
		}
	}
}