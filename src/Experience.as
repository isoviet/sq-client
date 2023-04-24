package
{
	import flash.events.EventDispatcher;

	import dialogs.DialogNewLevel;
	import events.GameEvent;
	import game.gameData.EducationQuestManager;
	import game.gameData.GameConfig;
	import headers.HeaderExtended;
	import loaders.RuntimeLoader;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.ScreenLocation;
	import screens.Screens;
	import views.Settings;

	import com.api.Player;
	import com.api.Services;
	import com.api.SettingsExistsEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketExperience;

	public class Experience
	{
		static private var dialogsArray:Array = [];

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			Connection.listen(onPacket, PacketExperience.PACKET_ID);

			if ('exp' in Game.self)
				dispatcher.dispatchEvent(new GameEvent(GameEvent.EXPERIENCE_CHANGED, {'value': selfExp, 'delta': 0, 'reason': 0}));
			else
				Game.self.addEventListener(PlayerInfoParser.VIP_INFO, onPlayerLoad);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function get selfLevel():int
		{
			return Game.self['level'];
		}

		static public function get selfExp():int
		{
			return Game.self['exp'];
		}

		static public function getRegularLevel(exp:int):int
		{
			var level:int = getLevel(exp);

			return Math.max(Math.min(level, GameConfig.maxLevel - 1), 0);
		}

		static public function getTextLevel(exp:int):String
		{
			var level:int = Math.min(getLevel(exp), GameConfig.maxLevel - 1);

			return String(level > 0 ? level : "-");
		}

		static public function getLevel(exp:int):int
		{
			if (exp >= GameConfig.maxExperience)
				return GameConfig.maxLevel;

			for (var i:int = 0; i < GameConfig.maxLevel; i++)
			{
				if (exp < GameConfig.getExperienceValue(i))
					return i - 1;
			}
			return GameConfig.maxLevel;
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
			for (var i:int = 0; i < dialogsArray.length; i++)
				showDialog(dialogsArray[i]);

			for (i = 0; i < dialogsArray.length; ++i)
				dialogsArray.pop();
			dialogsArray.splice(0);
		}

		static public function getTitle(level:int, withNubmer:Boolean = false):String
		{
			var textLevel:int = Math.min(level, GameConfig.maxLevel - 1);

			if (withNubmer)
				return GameConfig.getExperienceTitle(level) + " [" + String(textLevel > 0 ? textLevel : "-") + "]";
			return GameConfig.getExperienceTitle(level);
		}

		static public function newLevel(exp:int):void
		{
			var levelNew:int = getLevel(exp);
			var levelOld:int = Game.self['level'];

			ScreenLocation.setLevel(levelNew);

			//TODO for Event
			if (levelNew == Game.LEVEL_TO_OPEN_CLANS)
				Settings.addClanInvitesButton();

			if (levelNew == Locations.getLocation(Locations.MOUNTAIN_ID).level && Screens.active is ScreenGame)
			{
				Connection.sendData(PacketClient.LEAVE);
				ScreenGame.stopChangeRoom();
			}

			if (levelNew >= Game.LEVEL_TO_LEAVE_SANDBOX)
			{
				if (EducationQuestManager.done(EducationQuestManager.LEVEL_UP) && Screens.active is ScreenGame)
				{
					Connection.sendData(PacketClient.LEAVE);
					ScreenGame.stopChangeRoom();
				}
			}

			if (PreLoader.isShowing || Screens.active is ScreenGame || Screens.active is ScreenLearning)
				dialogsArray.push(exp);
			else
				showDialog(exp);

			Game.self['level'] = levelNew;
			HeaderExtended.update();

			for (var i:int = levelOld; i < levelNew; i++)
				dispatcher.dispatchEvent(new GameEvent(GameEvent.LEVEL_CHANGED, {'value': i + 1}));
		}

		static public function get remainedExp():int
		{
			var level:int = getLevel(selfExp);
			if (level >= GameConfig.maxLevel)
				return 0;
			return GameConfig.getExperienceValue(level + 1) - selfExp;
		}

		static public function getMaxExp(exp:int):int
		{
			var level:int = getLevel(exp);
			if (level >= GameConfig.maxLevel)
				return exp;
			return GameConfig.getExperienceValue(level + 1) - GameConfig.getExperienceValue(level);
		}

		static private function showDialog(exp:int):void
		{
			var level:int = getLevel(exp);
			requestLeftMenu(level);

			RuntimeLoader.load(function():void
			{
				new DialogNewLevel(level).show();
			}, true);
		}

		static private function requestLeftMenu(level:int):void
		{
			if (level < Game.LEVEL_REQUEST_LEFT_MENU)
				return;

			if (level % 2 != 0)
				return;

			Services.addEventListener(SettingsExistsEvent.LEFT_MENU, onLeftMenu);
			Services.requestLeftMenu(true);
		}

		static private function onLeftMenu(e:SettingsExistsEvent):void
		{
			if (!e.isExists)
				return;
			Services.requestLeftMenu(false);
		}

		static private function onPlayerLoad(player:Player):void
		{
			player.removeEventListener(onPlayerLoad);

			dispatcher.dispatchEvent(new GameEvent(GameEvent.EXPERIENCE_CHANGED, {'value': selfExp, 'delta': 0, 'reason': 0}));
		}

		static private function onPacket(packet: PacketExperience):void
		{
			var lastValue:int = selfExp;
			Game.self['exp'] = packet.exp;

			if (checkNew(lastValue, selfExp))
				newLevel(selfExp);

			dispatcher.dispatchEvent(new GameEvent(GameEvent.EXPERIENCE_CHANGED, {'value': selfExp, 'delta': selfExp - lastValue, 'reason': packet.reason}));
		}
	}
}