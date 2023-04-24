package tape
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import dialogs.DialogReturnFriends;
	import events.GameEvent;
	import game.gameData.NotificationManager;
	import loaders.RuntimeLoader;
	import statuses.Status;
	import views.NotificationView;

	public class TapeFriends extends Sprite
	{
		private var tapeFriends:TapeFriendsView = null;
		private var tapeSocialData:TapeAllFriendData;

		private var dialogReturn:Dialog;

		private var buttonReturn:ButtonBase;
		private var buttonInvite:ButtonBase;

		public function TapeFriends():void
		{
			this.tapeFriends = new TapeFriendsView();
			addChild(this.tapeFriends);

			this.tapeSocialData = new TapeAllFriendData();
			this.tapeSocialData.addEventListener(GameEvent.FRIENDS_UPDATE, updateSocial);

			this.tapeFriends.setData(this.tapeSocialData);

			this.buttonReturn = new ButtonBase(gls("Вернуть"), 100, 14, showReturnDialog);
			this.buttonReturn.scaleX = this.buttonReturn.scaleY = 0.75;
			this.buttonReturn.x = 5;
			this.buttonReturn.y = 10;
			addChild(this.buttonReturn);
			new Status(this.buttonReturn, gls("Вернуть друзей"));
			NotificationManager.instance.register(NotificationManager.RETURN, new NotificationView(this.buttonReturn, 60, 10));

			this.buttonInvite = new ButtonBase(gls("Пригласить"), 100, 12, Game.inviteFriendsByKey);
			this.buttonInvite.scaleX = this.buttonInvite.scaleY = 0.75;
			this.buttonInvite.x = 5;
			this.buttonInvite.y = 40;
			addChild(this.buttonInvite);
			new Status(this.buttonInvite, gls("Пригласить друзей"));
		}

		private function showReturnDialog(e:MouseEvent):void
		{
			RuntimeLoader.load(function():void
			{
				if (!dialogReturn)
					dialogReturn = new DialogReturnFriends();
				dialogReturn.show();
			});
		}

		private function updateSocial(e:GameEvent):void
		{
			this.tapeFriends.setData(this.tapeSocialData);
		}
	}
}