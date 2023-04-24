package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import menu.MenuProfile;
	import tape.ITapePlayerPlace;
	import views.ProfilePhoto;

	import com.api.Player;

	public class PlayerPlace extends Sprite implements ITapePlayerPlace
	{
		protected var levelField:GameField;
		protected var photo:ProfilePhoto;
		protected var onlineIcon:OnlineIcon;

		protected var exp:int = -1;
		protected var online:Boolean = false;

		protected var button:DisplayObject;
		protected var playerId:int = -1;

		public function PlayerPlace(placeButton:DisplayObject):void
		{
			super();
			init(placeButton);
		}

		public function isPlayerChanged(player:Player):Boolean
		{
			if (this.playerId != player.id)
				return true;

			if (this.exp != player.exp)
				return true;

			return (this.online != player.online);
		}

		public function setPhoto(player:Player):void
		{
			this.photo.setPlayer(player);
		}

		public function setPlayer(player:Player):void
		{
			this.exp = player.exp;
			this.online = Boolean(player.online);
			this.playerId = player.id;

			this.onlineIcon.setPlayer(player);

			this.button['name'] = player['id'];

			this.levelField.text = Experience.getTextLevel(player['exp']);
			this.levelField.x = 44 - int(this.levelField.textWidth / 2);
		}

		public function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.target.name);
		}

		protected function init(placeButton:DisplayObject):void
		{
			this.photo = new ProfilePhoto(53);
			this.photo.x = 2;
			this.photo.y = 2;
			addChild(this.photo);

			this.button = placeButton;
			this.button['name'] = -1;
			addChild(this.button);

			this.button.addEventListener(MouseEvent.MOUSE_UP, onClick);

			this.onlineIcon = new OnlineIcon();
			this.onlineIcon.x = 45;
			this.onlineIcon.y = 3;
			addChild(this.onlineIcon);

			this.levelField = new GameField("", 39, 39, new TextFormat(GameField.DEFAULT_FONT, 11, 0xFFE046, true));
			this.levelField.mouseEnabled = false;
			addChild(this.levelField);
		}
	}
}