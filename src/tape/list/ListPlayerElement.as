package tape.list
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;

	import clans.Clan;
	import clans.ClanManager;
	import events.ClanEvent;
	import menu.MenuProfile;
	import tape.list.events.ListElementEvent;
	import views.ClanIconLoader;

	import com.api.Player;

	public class ListPlayerElement extends ListElement implements INumbered
	{
		static private const CSS:String = (<![CDATA[
			.default {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
			}
			.shaman {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #0078EA;
				font-weight: bold;
			}
			.redShaman {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #ff3a33;
				font-weight: bold;
			}
			a {
				font-size: 11px;
				text-decoration: underline;
			}
			.bold {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
				font-weight: bold;
			}
		]]>).toString();

		static private const LOAD_MASK:uint = PlayerInfoParser.CLAN | PlayerInfoParser.NAME | PlayerInfoParser.EXPERIENCE;

		private var playerField:GameField = null;
		private var numberField:GameField = null;

		private var clanEmblem:ClanIconLoader = null;
		private var _shaman:Boolean = false;

		public var player:Player = null;

		public var team:int = Hero.TEAM_BLUE;

		public function ListPlayerElement(id:int, team:int):void
		{
			init();

			this.team = team;
			this.player = Game.getPlayer(id);

			this.player.addEventListener(LOAD_MASK, onPlayerLoaded);
			Game.request(id, LOAD_MASK);
		}

		public function set number(value:int):void
		{
			this.numberField.htmlText = "<body><span class=\"" + (this.shaman ? (this.team == Hero.TEAM_RED ? "redShaman" : "shaman") : "default") + "\"><b>" + value.toString() + ".</b></span></body>";
		}

		override public function get canAdd():Boolean
		{
			return (this.player.isLoaded(LOAD_MASK));
		}

		public function get shaman():Boolean
		{
			return this._shaman;
		}

		public function set shaman(value:Boolean):void
		{
			if (this.shaman == value)
				return;

			this._shaman = value;
			this.playerField.htmlText = "<body><span class=\"" + (this.shaman ? (this.team == Hero.TEAM_RED ? "redShaman" : "shaman") : "default") + "\">" + checkLink(this.player['id'], this.playerField.text) + "</span></body>";
			this.numberField.htmlText = "<body><span class=\"" + (this.shaman ? (this.team == Hero.TEAM_RED ? "redShaman" : "shaman") : "default") + "\"><b>" + this.numberField.text + "</b></span></body>";
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.playerField = new GameField("", 17, 0, style);
			this.playerField.addEventListener(MouseEvent.MOUSE_DOWN, showMenu);
			addChild(this.playerField);

			this.numberField = new GameField("<body><span class='defaultNumber'><b>13.</b></span></body>", 0, 0, style, 20);
			addChild(this.numberField);
		}

		private function showMenu(e: MouseEvent):void
		{
			var field:GameField = e.currentTarget as GameField;

			if (!field.visible)
				return;

			MenuProfile.showMenu(this.player.id);
		}

		private function formatField(field:TextField, name:String, level:String, width:int):void
		{
			do
			{
				field.htmlText = "<body><span class='default'>" + name + level + "</span></body>";

				name = name.substr(0, name.length - 1);
			}
			while (field.textWidth > width);
		}

		private function checkLink(id:int, name:String):String
		{
			if (id == Game.selfId)
				return name;

			return "<a href='event:#'>" + name + "</a>";
		}

		private function onPlayerLoaded(player:Player):void
		{
			formatField(this.playerField, player.name, " [" + (Experience.getRegularLevel(player['exp']) + 1) + "]", (this.player['clan_id'] != 0 ? 95 : 107));
			var name:String = this.playerField.text.split('\r')[0];

			this.playerField.htmlText = "<body><span class=\"" + (this.shaman ? (this.team == Hero.TEAM_RED ? "redShaman" : "shaman") : "default") + "\">" + checkLink(this.player['id'], name) + "</span></body>";

			dispatchEvent(new ListElementEvent(ListElementEvent.CHANGED, this));
			this.player.removeEventListener(onPlayerLoaded);

			if (this.player['clan_id'] == 0)
				return;

			this.playerField.x = 30;

			var clan:Clan = ClanManager.getClan(player['clan_id']);

			if (clan != null && clan.isLoaded())
			{
				this.clanEmblem = new ClanIconLoader(clan.emblemLink, 20, 2);
				addChild(this.clanEmblem);
				return;
			}

			this.clanEmblem = new ClanIconLoader("", 20, 2);
			addChild(this.clanEmblem);

			ClanManager.listen(onClanLoaded);
			ClanManager.request(this.player['clan_id']);
		}

		private function onClanLoaded(e:ClanEvent):void
		{
			if (e.clan.id != this.player['clan_id'])
				return;

			ClanManager.forget(onClanLoaded);
			this.clanEmblem.load(e.clan.emblemLink);
		}
	}
}