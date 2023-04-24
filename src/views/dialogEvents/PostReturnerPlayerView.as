package views.dialogEvents
{
	import flash.events.MouseEvent;
	import flash.events.TextEvent;

	import menu.MenuProfile;
	import views.OnlineIcon;
	import views.ProfilePhoto;
	import views.dialogEvents.PostElementView;

	import com.api.Player;

	public class PostReturnerPlayerView extends PostElementView
	{
		private var playerId:int = -1;
		private var description:GameField = null;
		private var onlineIcon:OnlineIcon = null;
		private var photo:ProfilePhoto = null;

		public function PostReturnerPlayerView(id:int, type:int, playerId:int, time:uint)
		{
			super(id, type, time);

			this.playerId = playerId;
		}

		override public function onShow():void
		{
			if (this.photo != null)
				return;

			super.onShow();

			this.photo = new ProfilePhoto(80);
			addChild(this.photo);

			var ratingPlaceButton:RatingPlaceButton = new RatingPlaceButton();
			ratingPlaceButton.width = this.photo.width;
			ratingPlaceButton.height = this.photo.height;
			ratingPlaceButton.addEventListener(MouseEvent.MOUSE_UP, showMenu);
			addChild(ratingPlaceButton);

			this.onlineIcon = new OnlineIcon(8);
			this.onlineIcon.x = 55;
			this.onlineIcon.y = 13;
			addChild(this.onlineIcon);

			var player:Player = Game.getPlayer(this.playerId);
			player.addEventListener(PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE | PlayerInfoParser.TYPE, onPlayerLoad);

			this.description = new GameField("", 85, 25, style);
			this.description.addEventListener(TextEvent.LINK, onLink);
			addChild(this.description);

			Game.request(this.playerId, PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE | PlayerInfoParser.TYPE);
		}

		private function onLink(e:TextEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function onPlayerLoad(player:Player):void
		{
			player.removeEventListener(onPlayerLoad);

			this.photo.setPlayer(player);
			this.onlineIcon.setPlayer(player);

			this.description.text = "<body>" + gls("Поздравляем. Игрок") + " <b>" + player.name + "</b>\n" + gls("вернулся в игру по твоему приглашению.") + "</body>";
		}

		private function showMenu(e:MouseEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}
	}
}