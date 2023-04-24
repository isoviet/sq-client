package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import views.ProfilePhoto;

	import com.api.Player;

	public class PlayerPlaceSmall extends Sprite
	{
		private var fieldPlace:GameField;
		private var photo:ProfilePhoto;

		public function PlayerPlaceSmall(background:DisplayObject):void
		{
			super();

			init(background);
		}

		public function setPlayer(player:Player):void
		{
			this.fieldPlace.text = Experience.getTextLevel(player['exp']);
			this.fieldPlace.x = 57 - int(this.fieldPlace.textWidth * 0.5);

			this.photo.setPlayer(player);
		}

		private function init(background:DisplayObject):void
		{
			this.photo = new ProfilePhoto(70, false);
			this.photo.x = 5;
			this.photo.y = 15;
			addChild(this.photo);

			addChild(background);

			this.fieldPlace = new GameField("", 60, 60, new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF));
			addChild(this.fieldPlace);
		}
	}
}