package views.dialogEvents
{
	import flash.events.MouseEvent;
	import flash.events.TextEvent;

	import menu.MenuProfile;
	import views.ProfilePhoto;

	import com.api.Player;

	import protocol.PacketServer;

	import utils.HtmlTool;

	public class PostFriendsLevelReachedView extends PostElementView
	{
		private var playerId:int = -1;

		private var caption:GameField = null;
		private var photo:ProfilePhoto = null;

		public function PostFriendsLevelReachedView(id:int, playerId:int, time:int):void
		{
			super(id, PacketServer.FRIEND_QUEST_EVENT, time);

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

			addChild(new GameField("<body>" + gls("Твой друг") + "</body>", 85, 10, style));

			this.caption = new GameField("", 148, 10, style);
			this.caption.addEventListener(TextEvent.LINK, onLink);
			addChild(this.caption);

			var description:GameField = new GameField("<body>" + gls("пришедший в «Трагедию белок» по твоему\nприглашению, достиг {0} уровня!", Game.LEVEL_TO_FRIEND_INVITE) + "</body>", 85, 25, style);
			addChild(description);

			var player:Player = Game.getPlayer(this.playerId);
			player.addEventListener(PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE, onPlayerLoad);

			Game.request(this.playerId, PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE);
		}

		private function onLink(e:TextEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function showMenu(e:MouseEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function onPlayerLoad(player:Player):void
		{
			player.removeEventListener(onPlayerLoad);

			this.photo.setPlayer(player);

			this.caption.htmlText = "<body><b>" + HtmlTool.anchor(player.name, "event:" + player.id) + "</b>,</body>";
		}
	}
}