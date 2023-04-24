package views
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import clans.Clan;
	import menu.MenuProfile;
	import tape.ITapePlayerPlace;
	import views.ProfilePhoto;

	import com.api.Player;

	import utils.PlayerUtil;

	public class PlayerPlaceClan extends Sprite implements ITapePlayerPlace
	{
		static private const CSS:String = (<![CDATA[
		body {
			font-family: "Droid Sans";
			font-size: 10px;
		}
		a {
			color: #FFFFFF;
			text-decoration: none;
			margin-right: 0px;
			font-weight: bold;
		}
		a:hover {
			text-decoration: underline;
		}
		]]>).toString();

		static private const FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 9, 0xFFCC00, true);
		static private const FORMAT_LEVEL:TextFormat = new TextFormat(null, 10, 0xFFFFFF);

		private var levelField:GameField;
		private var nameField:GameField;
		private var photo:ProfilePhoto;
		private var onlineIcon:OnlineIcon;
		private var button:SimpleButton;
		private var subLeaderField:GameField;

		private var playerId:int = -1;
		private var exp:int = -1;
		private var online:Boolean = false;
		private var clanDuty:int = -1;

		public function PlayerPlaceClan():void
		{
			super();
			init();
		}

		public function isPlayerChanged(player:Player):Boolean
		{
			if (this.playerId != player.id)
				return true;

			if (this.exp != player.exp)
				return true;

			if (this.online != player.online)
				return true;

			if (!('clan_duty' in player))
				player.clan_duty = Clan.DUTY_NONE;

			if (this.clanDuty != player.clan_duty)
				return true;

			return (('name' in player) && (this.nameField.htmlText == ""));
		}

		public function setPhoto(player:Player):void
		{
			this.photo.setPlayer(player);
		}

		public function setPlayer(player:Player):void
		{
			this.clanDuty = player.clan_duty;
			this.exp = player.exp;
			this.online = Boolean(player.online);
			this.playerId = player.id;

			this.onlineIcon.setPlayer(player);

			var isSelf:Boolean = (player.id == Game.selfId);

			this.button.mouseEnabled = !isSelf;

			this.levelField.text = player['clan_duty'] == Clan.DUTY_SUBLEADER ? gls("({0} ур.)", Experience.getTextLevel(player['exp'])) : gls("{0} уровень", Experience.getTextLevel(player['exp']));
			this.levelField.x = player['clan_duty'] == Clan.DUTY_SUBLEADER ? 97 : 32;

			if (player['clan_duty'] == Clan.DUTY_SUBLEADER && !(this.button is SubLeaderPlaceClan))
			{
				removeChild(this.button);
				this.button.removeEventListener(MouseEvent.MOUSE_UP, onClick);

				this.button = new SubLeaderPlaceClan();
				this.button['name'] = -1;
				this.button.addEventListener(MouseEvent.MOUSE_UP, onClick);
				addChild(this.button);

				this.subLeaderField = new GameField(gls("Опора клана").toUpperCase(), 32, 15, FORMAT);
				addChild(this.subLeaderField);
			}

			if (player['clan_duty'] != Clan.DUTY_SUBLEADER && (this.button is SubLeaderPlaceClan))
			{
				removeChild(this.button);
				this.button.removeEventListener(MouseEvent.MOUSE_UP, onClick);

				this.button = new TopPlaceClan();
				this.button['name'] = -1;
				this.button.addEventListener(MouseEvent.MOUSE_UP, onClick);
				addChild(this.button);

				removeChild(this.subLeaderField);
			}

			this.button.name = player.id.toString();
			this.nameField.name = player.id.toString();

			PlayerUtil.formatName(this.nameField, player, 88, true, !isSelf, true);
		}

		public function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.target.name);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.photo = new ProfilePhoto(25);
			this.photo.x = 2;
			this.photo.y = 2;
			addChild(this.photo);

			this.button = new TopPlaceClan();
			this.button['name'] = -1;
			addChild(this.button);

			this.button.addEventListener(MouseEvent.MOUSE_UP, onClick);

			this.onlineIcon = new OnlineIcon();
			this.onlineIcon.x = 32;
			this.onlineIcon.y = 4;
			addChild(this.onlineIcon);

			this.nameField = new GameField("", 42, 1, style);
			this.nameField.addEventListener(MouseEvent.MOUSE_UP, onClick);
			addChild(this.nameField);

			this.levelField = new GameField("", 32, 13, FORMAT_LEVEL);
			this.levelField.mouseEnabled = false;
			addChild(this.levelField);
		}
	}
}