package views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import clans.Clan;
	import menu.MenuProfile;

	import com.api.Player;

	import utils.PlayerUtil;

	public class PlayerPlaceClanLeader extends Sprite
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

		static private const FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 11, 0xFFCC00, true);
		static private const FORMAT_LEVEL:TextFormat = new TextFormat(null, 10, 0xFFFFFF);

		private var levelField:GameField;
		private var nameField:GameField;

		private var place:PlayerPlace;

		public var playerId:int = -1;

		public function PlayerPlaceClanLeader():void
		{
			super();
			init();
		}

		public function setPlayer(player:Player):void
		{
			this.place.setPhoto(player);
			this.place.setPlayer(player);

			this.place.mouseChildren = (Game.self['clan_duty'] != Clan.DUTY_LEADER);
			this.place.mouseEnabled = (Game.self['clan_duty'] != Clan.DUTY_LEADER);
			this.nameField.mouseEnabled = (Game.self['clan_duty'] != Clan.DUTY_LEADER);

			this.nameField.name = player.id.toString();
			PlayerUtil.formatName(this.nameField, player, 88, true, (Game.self['clan_duty'] != Clan.DUTY_LEADER), true);

			this.levelField.text = gls("{0} уровень", Experience.getTextLevel(player['exp']));
		}

		public function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.target.name);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.place = new PlayerPlace(new TopFrame);
			addChild(this.place);

			addChild(new GameField(gls("Вождь клана").toUpperCase(), 62, 8, FORMAT));

			this.nameField = new GameField("", 64, 21, style);
			this.nameField.addEventListener(MouseEvent.MOUSE_UP, onClick);
			addChild(this.nameField);

			this.levelField = new GameField("", 64, 33, FORMAT_LEVEL);
			this.levelField.mouseEnabled = false;
			addChild(this.levelField);
		}
	}
}