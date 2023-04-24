package views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import fl.containers.ScrollPane;

	import clans.Clan;
	import clans.ClanManager;
	import menu.MenuProfile;

	import com.api.Player;
	import com.api.PlayerEvent;

	import utils.HtmlTool;

	public class BlackListView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
				font-weight: bold;
				text-decoration: underline;
			}
			a {
				font-family: "Droid Sans";
			}
			a:hover {
				text-decoration: underline;
			}
		]]>).toString();

		static private var _instance:BlackListView;

		private var playersViews:Object = {};
		private var clan:Clan;

		private var list:Sprite = new Sprite();
		private var scrollPane:ScrollPane;

		private var style:StyleSheet;

		public function BlackListView():void
		{
			_instance = this;

			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.clan = ClanManager.getClan(Game.self['clan_id']);

			this.scrollPane = new ScrollPane();
			this.scrollPane.setSize(300, 180);
			this.scrollPane.source = this.list;
			addChild(this.scrollPane);

			Game.listen(onPlayerLoaded);
			update();
		}

		static public function update():void
		{
			if (!_instance)
				return;
			_instance.update();
		}

		private function update():void
		{
			var players:Object = {};
			var ids:Array = [];
			for (var i:int = 0; i < this.clan.blacklist.length; i++)
				if (this.clan.blacklist[i] in this.playersViews)
					players[this.clan.blacklist[i]] = this.playersViews[this.clan.blacklist[i]];
				else
					ids.push(this.clan.blacklist[i]);

			this.playersViews = players;

			sort();

			Game.request(ids, PlayerInfoParser.NAME, true);
		}

		private function sort():void
		{
			while (this.list.numChildren > 0)
				this.list.removeChildAt(0);

			var ids:Array = [];
			for (var id:String in this.playersViews)
				ids.push(id);
			ids.sort();

			for (var i:int = 0; i < ids.length; i++)
			{
				this.playersViews[ids[i]].y = 20 * this.list.numChildren;
				this.list.addChild(this.playersViews[ids[i]]);
			}

			this.scrollPane.source = this.list;
			this.scrollPane.update();
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (this.clan.blacklist.indexOf(player.id) == -1)
				return;

			if (!player.isLoaded(PlayerInfoParser.NAME))
				return;

			if (!(player.id in this.playersViews))
			{
				var level: String = player.hasOwnProperty('level') ? String(player.level) : "";
				this.playersViews[player.id] = new GameField("<body><span class='self'>" + HtmlTool.anchor(player.name, "event:" + player.id) + " [" + level + "]</span></body>", 0, 20 * this.list.numChildren, this.style);
				GameField(this.playersViews[player.id]).userData = player.id;
				(this.playersViews[player.id] as GameField).addEventListener(MouseEvent.MOUSE_DOWN, showMenu);
				this.list.addChild(this.playersViews[player.id]);

				sort();
			}
		}

		private function showMenu(e:MouseEvent):void
		{
			MenuProfile.showMenu(int(GameField(e.target).userData));
		}
	}
}