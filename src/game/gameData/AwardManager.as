package game.gameData
{
	import flash.events.EventDispatcher;

	import dialogs.DialogRepost;
	import events.GameEvent;
	import loaders.RuntimeLoader;
	import screens.Screens;

	import protocol.Connection;
	import protocol.packages.server.PacketAwardCounters;

	import utils.WallTool;

	public class AwardManager
	{
		//TODO rename to AchieveManager when remove 'battle' achieve
		static public const GENERAL:int = 0;
		static public const GAME:int = 1;
		static public const SHAMAN:int = 2;
		static public const EPIC:int = 3;
		static public const MAX_TYPE:int = 4;

		static private var awardQueue:Array = [];

		static public var data:Object = null;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			Award.init();
			Connection.listen(onPacket, PacketAwardCounters.PACKET_ID);
			Screens.addCallback(showDialogs);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static private function showDialogs():void
		{
			RuntimeLoader.load(onLoad, true);
		}

		static private function onLoad():void
		{
			while (awardQueue.length > 0)
				new DialogRepost(WallTool.WALL_AWARD, awardQueue.shift()).show();
		}

		static private function onPacket(packet:PacketAwardCounters):void
		{
			var firstInfo:Boolean = data == null;
			if (data == null)
				data = {};
			for (var i:int = 0; i < packet.items.length; i++)
			{
				if (!firstInfo)
					checkChanged(packet.items[i].counterId, packet.items[i].value, data[packet.items[i].counterId]);
				data[packet.items[i].counterId] = packet.items[i].value;
			}
			dispatcher.dispatchEvent(new GameEvent(GameEvent.AWARD_UPDATE));
		}

		static private function checkChanged(counterId:int, newValue:int, oldValue:int):void
		{
			var answer:Object = Award.getProgress(counterId, newValue, oldValue);
			if (answer == null)
				return;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.AWARD_CHANGED, answer));
			if (answer['value'] != 100)
				return;
			Screens.addCallback(function():void
			{
				RuntimeLoader.load(function():void
				{
					new DialogRepost(WallTool.WALL_AWARD, answer['id']).show();
				}, true);
			});
		}
	}
}