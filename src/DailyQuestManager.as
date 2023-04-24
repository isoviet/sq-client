package
{
	import flash.events.EventDispatcher;

	import events.GameEvent;
	import game.gameData.EducationQuestManager;
	import game.gameData.NotificationManager;
	import screens.ScreenGame;
	import screens.Screens;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketDailyQuests;
	import protocol.packages.server.structs.PacketDailyQuestsItems;

	public class DailyQuestManager
	{
		static public var currentQuest:int = -1;
		static public var currentDifficulty:int = -1;

		static public var quests:Vector.<DailyQuest> = new Vector.<DailyQuest>();
		static private var updateTime:int = -1;
		static private var sended:Boolean = false;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			Connection.listen(onPacket, [PacketDailyQuests.PACKET_ID]);

			if (EducationQuestManager.educationQuest)
				EducationQuestManager.addEventListener(GameEvent.EDUCATION_QUEST_FINISH, onEducation);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function onProgress(questType:int, count:int):void
		{
			if (quests[currentDifficulty].type != questType)
				return;
			quests[currentDifficulty].value += count;

			Connection.sendData(PacketClient.DAILY_QUEST_ADD, currentDifficulty, count);
			dispatcher.dispatchEvent(new GameEvent(GameEvent.DAILY_QUEST_PROGRESS));
			NotificationDispatcher.show(NotificationManager.DAILY_QUEST);

			if (!quests[currentDifficulty].isComplete)
				return;
			Connection.sendData(PacketClient.LEAVE);
			dispatcher.dispatchEvent(new GameEvent(GameEvent.DAILY_QUEST_COMPLETE));
		}

		static private function onTimer():void
		{
			updateTime--;

			if (updateTime > 0 || sended)
				return;
			sended = true;
			Connection.sendData(PacketClient.DAILY_QUEST_REQUEST);
		}

		static private function onPacket(packet:PacketDailyQuests):void
		{
			sended = false;

			EnterFrameManager.addPerSecondTimer(onTimer);

			var isRemoved:Boolean = currentQuest != -1;

			updateTime = int.MAX_VALUE;
			quests = new Vector.<DailyQuest>();
			var items: Vector.<PacketDailyQuestsItems> = packet.items;
			var item: PacketDailyQuestsItems;

			for (var i:int = 0; i < items.length; i++)
			{
				item = items[i];
				quests.push(new DailyQuest(item.type, item.location, item.value, item.time, i));
				updateTime = Math.min(updateTime, item.time);
				isRemoved = isRemoved && (item.type != currentQuest);
			}

			if (isRemoved && Screens.active is ScreenGame)
			{
				Connection.sendData(PacketClient.LEAVE);
				dispatcher.dispatchEvent(new GameEvent(GameEvent.DAILY_QUEST_FAIL));
			}

			dispatcher.dispatchEvent(new GameEvent(GameEvent.DAILY_QUEST_CHANGED));
			NotificationDispatcher.show(NotificationManager.DAILY_QUEST);
		}

		static private function onEducation(e:GameEvent):void
		{
			Connection.sendData(PacketClient.DAILY_QUEST_REQUEST);
		}
	}
}