package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import events.GameEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBonuses;
	import protocol.packages.server.PacketDailyBonusData;

	public class DailyBonusManager
	{
		static private const TIME:int = 24 * 60 * 60 - 1;

		static public const VIP:int = 4;
		static public const PACKAGE:int = 6;
		static private const LAST_DAY:int = 6;

		static public var packageIds:Array = null;
		static public var timeleft:int = 0;

		static public var haveBonus:Boolean = false;
		static public var currentDay:int = 0;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			packageIds = [];
			Connection.listen(onPacket, [PacketDailyBonusData.PACKET_ID, PacketBonuses.PACKET_ID]);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketBonuses.PACKET_ID:
					var bonus: PacketBonuses = packet as PacketBonuses;
					if (bonus.status != 0 || bonus.data != currentDay || bonus.awardReason != PacketServer.REASON_DAILY)
						return;

					GameSounds.play(SoundConstants.REWARD, true);

					packageIds = [];
					if (currentDay == PACKAGE && bonus.temporaryPackages != null)
					{
						for(var i:int = 0; i < bonus.temporaryPackages.length; i++)
							packageIds.push(bonus.temporaryPackages[i].packageId);

						timeleft = int(getTimer() / 1000) + TIME;
					}

					haveBonus = false;

					dispatcher.dispatchEvent(new GameEvent(GameEvent.DAILY_BONUS_GET));
					dispatcher.dispatchEvent(new GameEvent(GameEvent.DAILY_BONUS_UPDATE));
					break;
				case PacketDailyBonusData.PACKET_ID:
					var data: PacketDailyBonusData = packet as PacketDailyBonusData;
					currentDay = data.day;
					haveBonus = data.haveBonus != 0;

					dispatcher.dispatchEvent(new GameEvent(GameEvent.DAILY_BONUS_UPDATE));
					break;
			}
		}
	}
}