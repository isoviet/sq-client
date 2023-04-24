package
{
	import dialogs.DialogRepost;
	import dialogs.shaman.DialogShamanLevelPopUp;
	import game.gameData.GameConfig;
	import screens.ScreenGame;
	import screens.Screens;

	import utils.WallTool;

	public class ShamanExperience
	{
		static private var dialogsArray:Array = [];

		static public function getLevel(exp:int):int
		{
			var data:Array = GameConfig.shamanLevels;
			for (var i:int = 0; i < data.length; i++)
			{
				if (exp < data[i])
					return i + 1;
			}
			return (GameConfig.shamanMaxLevel + 1);
		}

		static public function get(level:int):int
		{
			return GameConfig.shamanLevels[level - 1];
		}

		static public function getRemindExp(exp:int):int
		{
			var rank:int = getLevel(exp);
			if (rank > GameConfig.shamanMaxLevel)
				return 0;
			return GameConfig.shamanLevels[rank - 1] - exp;
		}

		static public function checkNew(oldValue:int, newValue:int):Boolean
		{
			if (oldValue == newValue)
				return false;

			var oldLevel:int = getLevel(oldValue);
			var newLevel:int = getLevel(newValue);

			return oldLevel < newLevel;
		}

		static public function showDialogs():void
		{
			while(dialogsArray.length > 0)
				showDialog(dialogsArray.pop());
		}

		static public function newLevel(exp:int):void
		{
			if (PreLoader.isShowing || Screens.active is ScreenGame)
				dialogsArray.push(exp);
			else
				showDialog(exp);

			var levelNew:int = getLevel(exp);

			NotifyQueue.show(new DialogShamanLevelPopUp(levelNew));

			Game.self['shaman_level'] = levelNew;
		}

		static private function showDialog(exp:int):void
		{
			var level:int = getLevel(exp);

			(new DialogRepost(WallTool.WALL_SHAMAN_EXP, level)).show();
		}
	}
}