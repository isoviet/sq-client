package screens
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import buttons.ButtonScreenshot;
	import clans.ClanManager;
	import clans.ClanRoom;
	import dialogs.clan.DialogClanNews;
	import events.GameEvent;
	import loaders.ScreensLoader;
	import views.InteriorView;

	import protocol.Connection;
	import protocol.PacketClient;

	public class ScreenClan extends Screen
	{
		static private var _instance:ScreenClan;

		private var _inChat:Boolean = false;
		private var chatTimer:Timer = new Timer(15000, 1);

		private var clanRoom:Sprite;

		private var inited:Boolean = false;

		private var interiorView:InteriorView;

		public function ScreenClan():void
		{
			_instance = this;

			super();
		}

		static public function get instance():ScreenClan
		{
			return _instance;
		}

		static public function onClanCreate():void
		{
			if (!_instance.inited)
				return;

			(_instance.clanRoom as ClanRoom).clanId = Game.self['clan_id'];
			(_instance.clanRoom as ClanRoom).clearChats();
		}

		static public function onClanDispose():void
		{
			if (!_instance.inited)
				return;

			(_instance.clanRoom as ClanRoom).onClanDispose();
		}

		override public function firstShow():void
		{
			show();
		}

		override public function show():void
		{
			super.show();

			if (!ScreensLoader.loaded)
				return;

			if (!this.inited)
			{
				init();

				(this.clanRoom as ClanRoom).clanId = Game.self['clan_id'];
				ClanManager.request(Game.self['clan_id']);

				this.inited = true;

				if (ClanManager.selfClanNews != null && ClanManager.selfClanNews != "")
					new DialogClanNews(ClanManager.selfClanNews).show();
			}
			else
				ClanManager.request(Game.self['clan_id'], true, ClanInfoParser.TOTEMS | ClanInfoParser.TOTEMS_RANGS);

			if (!ClanRoom.requestApplications)
			{
				Connection.sendData(PacketClient.CLAN_GET_APPLICATION);
				ClanRoom.requestApplications = true;
			}

			this.inChat = this.clanRoom.visible;
		}

		override public function hide():void
		{
			super.hide();

			this.inChat = false;
		}

		public function get inChat():Boolean
		{
			return _inChat;
		}

		public function set inChat(value:Boolean):void
		{
			if (_inChat == value)
				return;

			_inChat = value;
			if (value)
			{
				Connection.sendData(PacketClient.CHAT_ENTER);
				this.chatTimer.stop();
				this.chatTimer.reset();
				this.chatTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, exitChat);
			}
			else
			{
				this.chatTimer.start();
				this.chatTimer.addEventListener(TimerEvent.TIMER_COMPLETE, exitChat);
			}
		}

		private function init():void
		{
			this.interiorView = new InteriorView(Game.self['interior'], true);
			addChild(this.interiorView);
			InteriorManager.addEventListener(GameEvent.INTERIOR_CHANGE, changeInterior);

			this.clanRoom = new ClanRoom();
			this.clanRoom.x = -50;
			addChild(this.clanRoom);

			var screenshotButton:ButtonScreenshot = new ButtonScreenshot();
			screenshotButton.x = 400;
			screenshotButton.y = 150;
			addChild(screenshotButton);
		}

		private function changeInterior(e:GameEvent):void
		{
			this.interiorView.load(Game.self['interior']);
		}

		private function exitChat(e:TimerEvent):void
		{
			Connection.sendData(PacketClient.CHAT_LEAVE);
			this.chatTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, exitChat);
		}
	}
}