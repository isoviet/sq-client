package tape
{
	public class TapeViralityQuestData extends TapeData
	{
		static public const QUEST_INSTALL:String = gls("Установить приложение");
		static public const QUEST_GROUP:String = gls("Вступить в сообщество Трагедия Белок");
		static public const QUEST_MENU:String = gls("Добавить приложение в «левое меню»");
		static public const QUEST_INVITE:String = gls("Пригласить друга");
		static public const QUEST_SHARE:String = gls("Рассказать друзьям");
		static public const QUEST_LEVEL:String = gls("Достигни {0} уровня", ViralityQuestManager.LEVEL_FOR_COMPLETE);
		static public const QUEST_FAVORITES:String = gls("Установи приложение в избранные");

		static private const DATA:Object = {
			"vk":		[QUEST_INSTALL, QUEST_GROUP, QUEST_MENU, QUEST_LEVEL, QUEST_SHARE],
			"fb":		[QUEST_INSTALL, QUEST_LEVEL, QUEST_FAVORITES],
			"sa":		[QUEST_INSTALL, QUEST_GROUP, QUEST_LEVEL],
			"default":	[QUEST_INSTALL, QUEST_GROUP, QUEST_LEVEL]
		};

		public function TapeViralityQuestData(socialType:String)
		{
			super();

			var data:Array = DATA[socialType] || DATA['default'];
			var quests:Array = ViralityQuestManager.QUESTS[socialType] || ViralityQuestManager.QUESTS["default"];

			var object:TapeViralityQuestObject;
			var len:int = data.length;
			while(len--)
			{
				object = new TapeViralityQuestObject(data[len], quests[len], len);
				object.selected = false;
				addObject(object);
			}
		}

		public function updateStep(id:uint, complete:Boolean):void
		{
			for each(var object:TapeViralityQuestObject in this.objects)
			{
				if (object.typeQuest != id)
					continue;

				object.selected = complete;
				break;
			}
		}
	}
}