package dialogs
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.DialogOfferManager;
	import screens.ScreenDisconnected;
	import screens.Screens;
	import tape.TapeInviteFriendsView;

	import com.api.Services;

	public class DialogInviteTimeout extends Dialog
	{
		static private const TIME:int = 180;

		static private var _instance:DialogInviteTimeout = null;

		static private var time:int = 0;
		static private var showed:Boolean = false;

		private	var tapeFriendsView:TapeInviteFriendsView;
		private var tmpIds:Array = [];

		static public function init():void
		{
			if (Experience.selfLevel <= Game.LEVEL_TO_INVITE || Game.self.type == Config.API_SA_ID)
				return;

			if (Game.allFriendsIds.length == 0 || (Game.allFriendsIds.length == Game.friendsSocialIds.length))
				return;

			EnterFrameManager.addPerSecondTimer(onTimer);

			Game.stage.addEventListener(MouseEvent.CLICK, onAction);
			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onAction);
		}

		static private function onTimer():void
		{
			if ((_instance && _instance.visible) || showed)
				return;

			time++;

			if (time < TIME)
				return;
			if (Screens.active is ScreenDisconnected)
			{
				EnterFrameManager.removePerSecondTimer(onTimer);
				return;
			}
			if (!_instance)
				_instance = new DialogInviteTimeout();
			if (!_instance.visible)
				_instance.show();

			DialogOfferManager.showed(DialogOfferManager.INVITE_TIMEOUT);

			showed = true;
		}

		static private function onAction(e:Event = null):void
		{
			time = 0;
		}

		public function DialogInviteTimeout():void
		{
			super(gls("Заскучали?"));

			init();
		}

		override public function show():void
		{
			super.show();

			this.tapeFriendsView.selectAll();
		}

		private function init():void
		{
			addChild(new GameField(gls("Пригласи нас в игру, будем играть вместе!"), 5, 0, new TextFormat(null, 14, 0x000000)));

			addChild(new GameField(gls("За каждого приглашенного друга, который\nдостигнет {0} уровня, ты получишь", Game.LEVEL_TO_FRIEND_INVITE), Config.isRus ? 35 : 72, 90, new TextFormat(null, 11, 0x000000, null, null, null, null, null, "center")));
			addChild(new GameField(gls("+15      в подарок"), Config.isRus ? 52 : 68, 120, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFF7E3F))).filters = DialogBank.FILTERS_BONUS;

			var image:ImageIconCoins = new ImageIconCoins();
			image.x = Config.isRus ? 95 : 111;
			image.y = 120;
			addChild(image);

			this.tapeFriendsView = new TapeInviteFriendsView(true);
			this.tapeFriendsView.y = 25;
			addChild(this.tapeFriendsView);

			var button:ButtonBase = new ButtonBase(gls("Пригласить"));
			button.x = Config.isRus ? 80 : 110;
			button.y = 150;
			button.addEventListener(MouseEvent.CLICK, onClick);
			addChild(button);

			place();

			this.width = 330;
			this.height = 235;
		}

		private function onClick(e:MouseEvent):void
		{
			this.tmpIds = this.tapeFriendsView.getInviteIds().slice();

			onComplete();

			DialogOfferManager.used(DialogOfferManager.INVITE_TIMEOUT);

			hide();
		}

		private function onComplete(answer:Object = null):void
		{
			if (answer) {/*unused*/}

			if (this.tmpIds.length == 0)
				return;

			Services.inviteFriendsById(this.tmpIds.shift());
		}
	}
}