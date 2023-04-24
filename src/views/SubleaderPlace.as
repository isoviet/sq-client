package views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import menu.MenuProfile;

	import com.api.Player;
	import com.api.PlayerEvent;

	import utils.HtmlTool;
	import utils.TextFieldUtil;

	public class SubleaderPlace extends Sprite
	{
		static private const CSS:String = (<![CDATA[
		body {
			font-family: "Droid Sans";
			font-size: 10px;
			color: #104BA5;
			font-weight: bold;
		}
		a {
			margin-right: 0px;
		}
		a:hover {
			text-decoration: underline;
		}
		.level {
			color: #432406;
			font-size: 10px;
			font-weight: normal;
		}
		]]>).toString();

		private var onlineIcon:OnlineIcon;

		private var nameField:GameField;
		private var levelField:GameField;

		public var player:Player = null;
		public var playerId:int;

		public function SubleaderPlace(playerId:int):void
		{
			init();

			this.playerId = playerId;

			Game.listen(onPlayerLoaded);

			Game.request(this.playerId, PlayerInfoParser.NAME | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.PHOTO | PlayerInfoParser.ONLINE | PlayerInfoParser.CLAN);
		}

		public function get loaded():Boolean
		{
			return (this.player != null);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.onlineIcon = new OnlineIcon();
			this.onlineIcon.y = 2;
			this.onlineIcon.width = this.onlineIcon.height = 8;
			addChild(this.onlineIcon);

			this.nameField = new GameField("", 9, -1, style);
			this.nameField.addEventListener(MouseEvent.MOUSE_UP, onClick);
			addChild(this.nameField);

			this.levelField = new GameField("", 13, 11, style);
			addChild(this.levelField);
		}

		private function setPlayer(player:Player):void
		{
			this.player = player;

			this.onlineIcon.setPlayer(player);

			this.nameField['name'] = player['id'];

			TextFieldUtil.formatField(this.nameField, player.name, 76, true, (player.id != Game.selfId));
			this.levelField.htmlText = HtmlTool.tag("body") + HtmlTool.span(gls("{0} уровень", Experience.getTextLevel(player['exp'])), "level") + HtmlTool.closeTag("body");
		}

		private function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.currentTarget.name);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			if (e.player.id != this.playerId)
				return;

			setPlayer(e.player);
		}
	}
}