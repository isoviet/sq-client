package ratings
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	import game.gameData.GameConfig;
	import game.gameData.RatingManager;
	import statuses.Status;
	import views.ProfilePhoto;

	import com.api.Player;

	public class RatingElementViewFriend extends RatingElementView
	{
		static private const IMAGES:Array = [RatingIconNone, RatingIconBronze, RatingIconSilver, RatingIconGold, RatingIconMaster, RatingIconDiamond, RatingIconChampion];
		static protected const TIME_UPDATE:int = 30;

		private var imageLeague:DisplayObject = null;
		private var photo:ProfilePhoto = null;

		private var _league:int = -1;

		public function RatingElementViewFriend(type:int, id:int)
		{
			super(type, id);
		}

		override protected function get timeUpdate():int
		{
			return TIME_UPDATE;
		}

		override protected function init():void
		{
			super.init();

			this.photo = new ProfilePhoto(36);
			this.photo.x = 185;
			this.photo.y = 5;
			addChild(this.photo);

			var ratingPlaceButton:RatingPlaceButton = new RatingPlaceButton();
			ratingPlaceButton.x = this.photo.x;
			ratingPlaceButton.y = this.photo.y;
			ratingPlaceButton.width = this.photo.width;
			ratingPlaceButton.height = this.photo.height;
			if (!this.isSelf)
				ratingPlaceButton.addEventListener(MouseEvent.MOUSE_UP, showProfile);
			addChild(ratingPlaceButton);

			this.fieldName.x = 225;
			this.clanIcon.x = 225;
			this.fieldClan.x = 240;
		}

		override protected function eventDelta(value:int):void
		{}

		override protected function update(name:String, value:int, level:int, wins:int = 0, shamans:int = 0, history:Array = null):void
		{
			super.update(name, value, level, wins, shamans, history);

			this.league = this.isSelf ? RatingManager.getSelfLeague(this.type) : RatingManager.getLeague(value, this.type);
		}

		override protected function onPlayerLoaded(player:Player):void
		{
			super.onPlayerLoaded(player);

			this.photo.setPlayer(player);
		}

		protected function get league():int
		{
			return this._league;
		}

		protected function set league(value:int):void
		{
			if (this.league == value)
				return;
			this._league = value;

			if (this.imageLeague)
				removeChild(this.imageLeague);
			var imageClass:Class = IMAGES[this.league];
			this.imageLeague = new imageClass();
			this.imageLeague.x = 160;
			this.imageLeague.y = 25;
			addChild(this.imageLeague);

			new Status(this.imageLeague, gls("Лига: {0}", GameConfig.getLeagueName(this.league, RatingManager.PLAYER_TYPE)));
		}
	}
}