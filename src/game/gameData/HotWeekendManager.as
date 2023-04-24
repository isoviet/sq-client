package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import dialogs.DialogHotWeekend;
	import dialogs.DialogHotWeekendBonus;
	import events.GameEvent;
	import screens.Screens;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBonuses;

	public class HotWeekendManager
	{
		static public const WEEKEND_START:uint = 1459555200;

		static private var dispatcher:EventDispatcher = new EventDispatcher();
		static private var lastState:Boolean = false;

		static public function init():void
		{
			addEventListener(GameEvent.HOT_WEEKEND_CHANGED, onChange);
			ExpirationsManager.addEventListener(GameEvent.EXPIRATIONS_CHANGE, onExpiration);
			Connection.listen(onPacket, [PacketBonuses.PACKET_ID]);

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

		static public function get caption():String
		{
			return gls("Листопад знаний");
		}

		static public function get isWeekend():Boolean
		{
			return false;
			return int((Game.unix_time + int(getTimer() / 1000) - WEEKEND_START) / (24 * 60 * 60)) % 7 < 2;
		}

		static public function get isActive():Boolean
		{
			return ExpirationsManager.haveExpiration(ExpirationsManager.HOT_WEEKEND);
		}

		static public function get accessoriesIds():Array
		{
			return [OutfitData.SCHOOL_BACK,
				OutfitData.SCHOOL_GLASSES,
				OutfitData.SCHOOL_HANDS,
				OutfitData.SCHOOL_TAIL];
		}

		static private function onTime():void
		{
			if (lastState == isWeekend)
				return;
			lastState = isWeekend;

			dispatcher.dispatchEvent(new GameEvent(GameEvent.HOT_WEEKEND_CHANGED));
		}

		static private function onChange(e:GameEvent):void
		{
			if (isWeekend)
			{
				Screens.addCallback(function():void
				{
					DialogHotWeekend.show();
				});
			}
			else
				DialogHotWeekend.hide();
		}

		static private function onPacket(packet:AbstractServerPacket):void
		{
			var bonus:PacketBonuses = packet as PacketBonuses;
			if (bonus.status != 0 || bonus.awardReason != PacketServer.REASON_HOT_WEEKEND || !bonus.accessories || bonus.accessories.length == 0)
				return;
			Screens.addCallback(function():void
			{
				new DialogHotWeekendBonus(bonus.accessories[0].accessoryId).show();
			});
		}

		static private function onExpiration(e:GameEvent):void
		{
			if (e.data['type'] != ExpirationsManager.HOT_WEEKEND)
				return;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.HOT_WEEKEND_CHANGED));

			DialogHotWeekend.hide();
		}
	}
}