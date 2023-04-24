package
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import dialogs.DialogFacebookFavorites;
	import dialogs.DialogInviteFriends;
	import dialogs.DialogViralityQuest;
	import events.GameEvent;
	import game.gameData.FlagsManager;
	import loaders.RuntimeLoader;

	import com.api.QuestEvent;
	import com.api.Services;
	import com.api.SettingsExistsEvent;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;

	public class ViralityQuestManager
	{
		static public const LEVEL_FOR_COMPLETE:int = 7;

		static private var questType:uint = 0;

		static public const COINS:uint = 20;

		static public const QUEST_INSTALL:uint = (1 << questType);
		static public const QUEST_GROUP:uint = (1 << ++questType);
		static public const QUEST_MENU:uint = (1 << ++questType);
		static public const QUEST_INVITE:uint = (1 << ++questType);
		static public const QUEST_SHARE:uint = (1 << ++questType);
		static public const QUEST_FINISH:uint = (1 << ++questType);
		static public const QUEST_LEVEL:uint = (1 << ++questType);
		static public const QUEST_FAVORITES:uint = (1 << ++questType);

		static public const QUESTS:Object = {
			'vk':		[QUEST_INSTALL, QUEST_GROUP, QUEST_MENU, QUEST_LEVEL, QUEST_SHARE],
			'fb':		[QUEST_INSTALL, QUEST_LEVEL, QUEST_FAVORITES],
			'sa':		[QUEST_INSTALL, QUEST_GROUP, QUEST_LEVEL],
			'default':	[QUEST_INSTALL, QUEST_GROUP, QUEST_LEVEL]
		};

		static private const COMPLETE_QUESTS:Object = {
			'vk':		[QUEST_INSTALL, QUEST_INVITE, QUEST_FAVORITES],
			'fb':		[QUEST_INSTALL, QUEST_GROUP, QUEST_MENU, QUEST_SHARE, QUEST_INVITE],
			'sa':		[QUEST_INSTALL, QUEST_MENU, QUEST_SHARE, QUEST_INVITE, QUEST_FAVORITES],
			'default':	[QUEST_INSTALL, QUEST_MENU, QUEST_SHARE, QUEST_INVITE, QUEST_FAVORITES]
		};

		static public const ALL_FLAG:Array = [QUEST_INSTALL, QUEST_GROUP, QUEST_MENU, QUEST_INVITE, QUEST_SHARE, QUEST_FINISH, QUEST_LEVEL, QUEST_FAVORITES];

		static private var _instance:ViralityQuestManager = null;

		static private var isRequestShare:Boolean = false;

		private var socialType:String;

		public function ViralityQuestManager():void
		{
			_instance = this;

			var session:Object = PreLoader.loaderInfo.parameters as Object;

			if ("useApiType" in session)
				this.socialType = session['useApiType'];
			else if ("useapitype" in session)
				this.socialType = session['useapitype'];
			else
				this.socialType = Config.DEFAULT_API;

			if (!(this.socialType in QUESTS) || ("OAuth" in session))
				return;

			if (this.socialType == "vk")
			{
				try
				{
					ExternalInterface.call("eval", "function ShowShareDialog(){VK.Share.click(0,this);}");
				}
				catch (e:Error)
				{}
			}
		}

		static public function get questAvailable():Boolean
		{
			return _instance.socialType == "fb" || _instance.socialType == "vk" || _instance.socialType == "mm" || _instance.socialType == "ok";
		}

		static public function requestApiData():void
		{
			Services.addEventListener(SettingsExistsEvent.LEFT_MENU, _instance.onLeftMenu);
			Services.listenGroup(_instance.onGroup);
			Services.addEventListener(QuestEvent.SHARED, _instance.onShared);

			if (Referrers.get() == 30005 && _instance.socialType == "fb")
				_instance.onFavorites();

			Experience.addEventListener(GameEvent.EXPERIENCE_CHANGED, _instance.onLevel);

			FlagsManager.find(Flag.VIRALITY_BONUS).listen(_instance.onChangeFlag);

			_instance.setCompleteQuests();

			Services.requestLeftMenu(true);
			Services.requestShared();

			_instance.onLevel();
		}

		static public function checkQuestCompleted(id:int):Boolean
		{
			return (FlagsManager.find(Flag.VIRALITY_BONUS).value & id) == id;
		}

		static public function get questCompleted():Boolean
		{
			return (FlagsManager.find(Flag.VIRALITY_BONUS).value & QUEST_FINISH) == QUEST_FINISH;
		}

		static public function get questCompletedAllStep():Boolean
		{
			var quests:Array = ViralityQuestManager.QUESTS[ _instance.socialType] || ViralityQuestManager.QUESTS["default"];
			for (var i:int = 0; i < quests.length; i++)
				if(!checkQuestCompleted(quests[i]))
					return false;
			return true;
		}

		static public function requestQuestCompleted(id:int):void
		{
			if (checkQuestCompleted(id))
				return;

			switch (id)
			{
				case QUEST_MENU:
					Services.requestLeftMenu(true);
					break;
				case QUEST_GROUP:
					Services.requestGroup();
					break;
				case QUEST_SHARE:
					Services.requestShared();
					break;
			}
		}

		static public function showQuest(id:int):void
		{
			switch (id)
			{
				case QUEST_MENU:
					if (_instance.socialType == "vk")
						Services.requestLeftMenu();
					break;
				case QUEST_GROUP:
					if (_instance.socialType == "vk")
						navigateToURL(new URLRequest(Services.config.vk_groupAddress), "_blank");
					if (_instance.socialType == "fb")
						navigateToURL(new URLRequest(Services.config.fb_groupAddress), "_blank");
					if (_instance.socialType == "mm")
						navigateToURL(new URLRequest(Services.config.mm_groupAddress), "_blank");
					if (_instance.socialType == "ok")
						navigateToURL(new URLRequest(Services.config.ok_groupAddress), "_blank");
					if (_instance.socialType == "fs")
						navigateToURL(new URLRequest(Services.config.fs_groupAdress), "_blank");
					break;
				case QUEST_FAVORITES:
					RuntimeLoader.load(function():void
					{
						DialogFacebookFavorites.show();
					});
					break;
				case QUEST_SHARE:
					if (_instance.socialType == "vk")
					{
						try
						{
							ExternalInterface.call("ShowShareDialog");
						}
						catch (e:Error)
						{}
					}
					if (_instance.socialType == "fb")
					{
						navigateToURL(new URLRequest(gls("https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fapps.facebook.com%2Fsquirrelstragedy&display=popup")), "_blank");
					}
					break;
				case QUEST_INVITE:
					RuntimeLoader.load(function():void
					{
						DialogInviteFriends.show();
					});
					break;
			}
		}

		private function setCompleteQuests():void
		{
			var quests:Array = ViralityQuestManager.COMPLETE_QUESTS[socialType] || ViralityQuestManager.COMPLETE_QUESTS["default"];

			for each(var id:uint in quests)
			{
				switch(id)
				{
					case QUEST_MENU:
						onLeftMenu(new SettingsExistsEvent("", true));
						break;
					case QUEST_GROUP:
						onGroup(new QuestEvent("", true));
						break;
					case QUEST_FAVORITES:
						onFavorites();
						break;
					case QUEST_SHARE:
						Logger.add("onShared");
						onShared(new QuestEvent("", true));
						break;
					case QUEST_INVITE:
						var flag:Flag = FlagsManager.find(Flag.VIRALITY_BONUS);
						flag.setValue(flag.value | QUEST_INVITE);
						break;
					case QUEST_INSTALL:
						onInstall();
						break;
				}
			}
		}

		private function onChangeFlag(flag:Flag):void
		{
			if (checkQuestCompleted(QUEST_INVITE))
				return;

			if ((flag.value & QUEST_INVITE) != QUEST_INVITE)
				return;

			FlagsManager.find(Flag.VIRALITY_BONUS).forget(_instance.onChangeFlag);

			completeStep(QUEST_INVITE);
		}

		private function onInstall():void
		{
			if (checkQuestCompleted(QUEST_INSTALL))
				return;

			completeStep(QUEST_INSTALL);
		}

		private function onGroup(e:QuestEvent = null):void
		{
			if (e == null || !e.value || checkQuestCompleted(QUEST_GROUP))
				return;

			completeStep(QUEST_GROUP);
		}

		private function onFavorites():void
		{
			if (checkQuestCompleted(QUEST_FAVORITES))
				return;

			completeStep(QUEST_FAVORITES);
		}

		private function onLevel(e:GameEvent = null):void
		{
			if (checkQuestCompleted(QUEST_LEVEL) || Experience.selfLevel < LEVEL_FOR_COMPLETE)
				return;

			completeStep(QUEST_LEVEL);
		}

		private function onLeftMenu(e:SettingsExistsEvent = null):void
		{
			if (e == null || !e.isExists || checkQuestCompleted(QUEST_MENU))
				return;

			completeStep(QUEST_MENU);
		}

		private function onShared(e:QuestEvent = null):void
		{
			if (e == null || !e.value || checkQuestCompleted(QUEST_SHARE))
				return;

			completeStep(QUEST_SHARE);
		}

		private function completeStep(id:int):void
		{
			if (checkQuestCompleted(id))
				return;

			if (id == QUEST_SHARE)
			{
				if (isRequestShare)
					Connection.sendData(PacketClient.COUNT, PacketClient.VIRALITY_REPOST);
				isRequestShare = false;
			}

			var flag:Flag = FlagsManager.find(Flag.VIRALITY_BONUS);
			flag.setValue(flag.value | id);

			if (DialogViralityQuest.inited)
				DialogViralityQuest.updateStep(id);
		}
	}
}