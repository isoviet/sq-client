package tape.list
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import menu.MenuProfile;
	import tape.list.events.ListElementEvent;

	import com.api.Player;

	import utils.TextFieldUtil;

	public class ListFragsElement extends ListElement implements INumbered
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 13px;
				color: #000000;
			}
			a {
				text-decoration: none;
				margin-right: 0px;
			}
			a:hover {
				text-decoration: underline;
			}
			.bold {
				font-weight: bold;
			}
		]]>).toString();

		static private const LOAD_MASK:uint = PlayerInfoParser.NAME;

		static private const FORMAT:TextFormat = new TextFormat(null, 13, 0x000000, true);
		static private const FORMAT_RED:TextFormat = new TextFormat(null, 13, 0xFA1D1D, true, null, null, null, null, "center");
		static private const FORMAT_BLUE:TextFormat = new TextFormat(null, 13, 0x2857C1, true, null, null, null, null, "center");

		static public const HEIGHT:int = 20;

		private var view:BattleListItem = null;

		private var fieldPlace:GameField = null;
		private var fieldName:GameField = null;
		private var fieldFrags:GameField = null;

		public var player:Player = null;

		public var team:int = Hero.TEAM_BLUE;
		public var frags:int = 0;

		public function ListFragsElement(player:Player, frags:int, team:int):void
		{
			this.team = team;
			this.frags = frags;

			init();

			this.fieldFrags.text = frags.toString();

			this.player = player;

			this.player.addEventListener(LOAD_MASK, onPlayerLoaded);
			Game.request(this.player.id, LOAD_MASK);
		}

		public function set number(value:int):void
		{
			this.fieldPlace.text = value.toString() + ".";
		}

		override public function get canAdd():Boolean
		{
			return (this.player.isLoaded(LOAD_MASK));
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.view = new BattleListItem();

			this.fieldPlace = new GameField("", 0, 0, FORMAT);
			this.view.addChild(this.fieldPlace);

			this.fieldName = new GameField("", 18, 0, style);
			this.fieldName.addEventListener(MouseEvent.MOUSE_DOWN, showMenu);
			this.view.addChild(this.fieldName);

			this.fieldFrags = new GameField("", 140, 0, this.team == Hero.TEAM_RED ? FORMAT_RED : FORMAT_BLUE, 24);
			this.view.addChild(this.fieldFrags);

			addChild(this.view);
		}

		private function showMenu(e:MouseEvent):void
		{
			MenuProfile.showMenu(this.player.id);
		}

		private function onPlayerLoaded(player:Player):void
		{
			if (player) {/*unused*/}

			TextFieldUtil.formatField(this.fieldName, this.player.name, 115, true, this.player.id != Game.selfId);
			if (this.player.id == Game.selfId)
				this.fieldName.htmlText = "<body><b>" + this.fieldName.text + "</b></body>";

			dispatchEvent(new ListElementEvent(ListElementEvent.CHANGED, this));
			this.player.removeEventListener(onPlayerLoaded);
		}
	}
}