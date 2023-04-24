package footers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import buttons.ButtonFooterTab;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import buttons.ButtonToggle;
	import chat.ChatCommon;
	import events.ButtonTabEvent;
	import events.GameEvent;
	import game.gameData.SettingsStorage;
	import screens.ScreenProfile;
	import statuses.Status;
	import tape.TapeClanView;
	import tape.TapeDecorations;
	import tape.TapeFriends;

	import com.greensock.TweenNano;

	import protocol.Connection;
	import protocol.PacketClient;

	public class FooterTop extends Sprite
	{
		static private var _instance:FooterTop;

		private var buttonsRadio:ButtonTabGroup;
		private var buttonFriends:ButtonTab;
		private var buttonClan:ButtonTab;
		private var buttonDecorations:ButtonTab;
		private var buttonChat:ButtonToggle;

		private var tapeFriends:TapeFriends = null;
		private var tapeClan:TapeClanView = null;
		private var tapeInterior:TapeDecorations = null;

		private var clanRequested:Boolean = false;
		private var state:Boolean = true;

		public function FooterTop():void
		{
			_instance = this;

			super();

			this.visible = false;

			init();
		}

		static public function set haveClan(value:Boolean):void
		{
			_instance.haveClan = value;
		}

		static public function show(withDecorations:Boolean):void
		{
			if (ScreenProfile.playerId != Game.selfId)
				withDecorations = false;

			_instance.visible = true;

			_instance.buttonDecorations.visible = withDecorations;

			if (!withDecorations)
				_instance.buttonsRadio.setSelected(_instance.buttonFriends);

			if (("clan_id" in Game.self) && (Game.self['clan_id'] != 0))
				FooterTop.haveClan = true;
		}

		static public function showDecorations():void
		{
			_instance.buttonsRadio.setSelected(_instance.buttonDecorations);
		}

		static public function loadTapeInterior():void
		{
			_instance.loadTapeInterior();
		}

		static public function hide():void
		{
			_instance.visible = false;

			_instance.buttonDecorations.visible = false;
			_instance.buttonsRadio.setSelected(_instance.buttonFriends);
		}

		static public function addListenerToChange():void
		{
			ScreenProfile.addListener(GameEvent.PROFILE_PLAYER_CHANGED, _instance.onDecorationsShow);
		}

		static public function toggleChatButton(value:Boolean = false):void
		{
			value ? _instance.buttonChat.on() : _instance.buttonChat.off();
			ChatCommon.toggleChat(_instance.buttonChat.buttonOn.visible);
		}

		static public function addChat(chat:ChatCommon):void
		{
			_instance.addChildAt(chat, 0);
		}

		private function init():void
		{
			var backgroundTop:ImageFooterTop = new ImageFooterTop();
			backgroundTop.y = Config.GAME_HEIGHT - Footers.FOOTER_OFFSET - backgroundTop.height;
			addChild(backgroundTop);

			this.buttonFriends = new ButtonTab(new ButtonFooterTab(gls("Друзья")));
			this.buttonFriends.y = backgroundTop.y - this.buttonFriends.height + 2;
			this.buttonFriends.addEventListener(ButtonTabEvent.SELECT, changeState, false, 1);

			addChild(this.buttonFriends);

			this.tapeFriends = new TapeFriends();
			this.tapeFriends.y = 40;
			addChild(this.tapeFriends);

			this.buttonClan = new ButtonTab(new ButtonFooterTab(gls("Клан")));
			this.buttonClan.x = this.buttonFriends.x + this.buttonFriends.width + 5;
			this.buttonClan.y = this.buttonFriends.y;
			this.buttonClan.visible = false;
			this.buttonClan.addEventListener(ButtonTabEvent.SELECT, requestClan);
			this.buttonClan.addEventListener(ButtonTabEvent.SELECT, changeState, false, 1);
			addChild(this.buttonClan);

			if (Config.isRus)
				this.buttonDecorations = new ButtonTab(new ButtonFooterTab(gls("Мебель")));
			else
				this.buttonDecorations = new ButtonTab(new ButtonFooterTab(gls("Мебель"), ButtonFooterTab.FORMATS_14, null, -2, -2));
			this.buttonDecorations.x = this.buttonClan.x;
			this.buttonDecorations.y = this.buttonFriends.y;
			this.buttonDecorations.visible = false;
			this.buttonDecorations.addEventListener(ButtonTabEvent.SELECT, changeState, false, 1);
			addChild(this.buttonDecorations);

			this.tapeClan = new TapeClanView();
			this.tapeClan.visible = false;
			this.tapeClan.y = 49;
			addChild(this.tapeClan);

			this.buttonChat = new ButtonToggle(new ButtonFooterChatOn, new ButtonFooterChatOff, false);
			this.buttonChat.x = 20;
			this.buttonChat.y = 37;
			this.buttonChat.addEventListener(MouseEvent.CLICK, toggleChat);
			addChild(this.buttonChat);
			new Status(this.buttonChat, gls("Чат"));

			this.buttonsRadio = new ButtonTabGroup();
			this.buttonsRadio.insert(this.buttonFriends, this.tapeFriends);
			this.buttonsRadio.insert(this.buttonClan, this.tapeClan);
			this.buttonsRadio.setSelected(this.buttonFriends);
			this.buttonsRadio.x = 40;
			addChild(this.buttonsRadio);

			if ('chatState' in SettingsStorage.load(SettingsStorage.CHAT_SETTINGS))
				FooterTop.toggleChatButton(SettingsStorage.load(SettingsStorage.CHAT_SETTINGS)['chatState'] != 0);
			else
				SettingsStorage.addCallback(SettingsStorage.CHAT_SETTINGS, onLoad);

			this.y = 78;
		}

		private function onLoad():void
		{
			if ('chatState' in SettingsStorage.load(SettingsStorage.CHAT_SETTINGS))
				FooterTop.toggleChatButton(SettingsStorage.load(SettingsStorage.CHAT_SETTINGS)['chatState'] != 0);
			else if (Experience.selfLevel >= Game.LEVEL_TO_SHOW_CHAT_ALL)
				FooterTop.toggleChatButton(true);
		}

		private function changeState(e:ButtonTabEvent):void
		{

			if (e.button != this.buttonsRadio.selected && !this.state)
				return;
			TweenNano.to(this, 0.5, {'y': this.state ? 0 : 78});
			this.state = !this.state;
		}

		private function onDecorationsShow(e:GameEvent):void
		{
			this.buttonDecorations.visible = (ScreenProfile.playerId == Game.selfId);
		}

		private function loadTapeInterior():void
		{
			this.tapeInterior = new TapeDecorations();
			this.tapeInterior.y = 45;
			addChild(this.tapeInterior);

			this.buttonsRadio.insert(this.buttonDecorations, this.tapeInterior);
		}

		private function set haveClan(value:Boolean):void
		{
			this.buttonClan.visible = value;
			this.buttonDecorations.x = this.buttonClan.x + (this.buttonClan.visible ? this.buttonClan.width + 5 : 0);

			if (!value && (this.buttonsRadio.selected == this.buttonClan))
				this.buttonsRadio.setSelected(this.buttonFriends);

			if (value)
				return;

			this.tapeClan.clear();
			this.clanRequested = false;
		}

		private function requestClan(e:ButtonTabEvent):void
		{
			if (this.clanRequested)
				return;

			Connection.sendData(PacketClient.CLAN_GET_MEMBERS, Game.self['clan_id']);
			this.tapeClan.clear();
			this.clanRequested = true;
		}

		private function toggleChat(e:MouseEvent = null):void
		{
			Connection.sendData(PacketClient.COUNT, PacketClient.CLICK_CHAT_BUTTON);
			ChatCommon.toggleChat(this.buttonChat.buttonOn.visible);
		}
	}
}