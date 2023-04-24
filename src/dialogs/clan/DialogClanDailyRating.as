package dialogs.clan
{
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import fl.containers.ScrollPane;

	import clans.Clan;
	import clans.ClanManager;
	import dialogs.Dialog;
	import events.ClanEvent;
	import views.ClanDailyRatingElement;

	import com.api.Player;
	import com.api.PlayerEvent;

	public class DialogClanDailyRating extends Dialog
	{
		private var _clanId:int;
		private var clan:Clan;

		private var players:Object = {};
		private var playerViews:Object = {};

		private var list:Sprite = new Sprite();
		private var scrollPane:ScrollPane;

		private var totalExpField:GameField;
		private var totalSamplesField:GameField;

		public function DialogClanDailyRating(clanId:int):void
		{
			super(gls("Статистика за прошедшие сутки"));

			this.clanId = clanId;

			ClanManager.listen(onClanLoaded);

			init();
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 15, 0xFFCC00, null, null, null, null, null, "center");
		}

		public function get clanId():int
		{
			return this._clanId;
		}

		public function set clanId(value:int):void
		{
			if (value == this._clanId)
				return;
			this._clanId = value;

			this.players = {};
			this.playerViews = {};
			while (this.list.numChildren > 0)
				this.list.removeChildAt(0);
		}

		private function init():void
		{
			addChild(new GameField(gls("Игрок"), 15, 0, new TextFormat(null, 12, 0x000000, true)));
			addChild(new GameField(gls("Опыт\nигрока"), 140, 0, new TextFormat(null, 12, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER)));
			addChild(new GameField(gls("Опыт\nклана"), 230, 0, new TextFormat(null, 12, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER)));
			addChild(new GameField(gls("Всего"), 15, 305, new TextFormat(null, 14, 0x000000, true)));

			this.totalSamplesField = addChild(new GameField("", 160, 305, new TextFormat(null, 14, 0x000000, true))) as GameField;
			this.totalExpField = addChild(new GameField("", 250, 305, new TextFormat(null, 14, 0x000000, true))) as GameField;

			this.scrollPane = new ScrollPane();
			this.scrollPane.x = 0;
			this.scrollPane.y = 30;
			this.scrollPane.setSize(290, 280);
			this.scrollPane.source = this.list;
			addChild(this.scrollPane);

			place();

			this.width = 350;
			this.height = 380;
		}

		override public function show():void
		{
			ClanManager.request(this.clanId, true, ClanInfoParser.STATISICS);

			super.show();
		}

		private function onClanLoaded(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if (clan.id != this.clanId)
				return;
			this.clan = clan;

			update();
		}

		private function update():void
		{
			if (this.clan == null || this.clan.dailyRatings == null)
				return;

			var ids:Array = [];
			var newPlayers:Object = {};
			var newViews:Object = {};

			var totalExp:int = 0;
			var totalSamples:int = 0;
			for (var i:int = 0; i < this.clan.dailyRatings.length; i += 3)
			{
				if (!(this.clan.dailyRatings[i] in this.players))
					ids.push(this.clan.dailyRatings[i]);
				newPlayers[this.clan.dailyRatings[i]] = {'exp': this.clan.dailyRatings[i + 1], 'samples': this.clan.dailyRatings[i + 2]};
				newViews[this.clan.dailyRatings[i]] = this.playerViews[this.clan.dailyRatings[i]];

				totalExp += this.clan.dailyRatings[i + 1];
				totalSamples += this.clan.dailyRatings[i + 2];
			}

			Game.listen(onPlayerLoaded);
			Game.request(ids, PlayerInfoParser.NAME, true);

			this.players = newPlayers;
			this.playerViews = newViews;
			sort();

			this.totalSamplesField.text = totalSamples.toString();
			this.totalSamplesField.x = 160 - int(this.totalSamplesField.textWidth * 0.5);
			this.totalExpField.text = totalExp.toString();
			this.totalExpField.x = 250 - int(this.totalExpField.textWidth * 0.5);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (!(player.id in this.players))
				return;

			if (!player.isLoaded(PlayerInfoParser.NAME))
				return;

			if (!(player.id in this.playerViews) || !this.playerViews[player.id])
				this.playerViews[player.id] = new ClanDailyRatingElement(player.id);
			(this.playerViews[player.id] as ClanDailyRatingElement).playerName = player.name;

			sort();
		}

		private function sort():void
		{
			while (this.list.numChildren > 0)
				this.list.removeChildAt(0);

			var array:Array = [];
			for (var id:String in this.playerViews)
			{
				if (!this.playerViews[id])
					continue;

				(this.playerViews[id] as ClanDailyRatingElement).setData(this.players[id]);
				array.push(this.playerViews[id]);
			}
			array.sort(sortByExp);

			for (var i:int = 0; i < array.length; i++)
			{
				array[i].y = 20 * i;
				(array[i] as ClanDailyRatingElement).number = i + 1;
				this.list.addChild(array[i]);
			}
			this.scrollPane.source = this.list;
			this.scrollPane.update();
		}

		private function sortByExp(a:ClanDailyRatingElement, b:ClanDailyRatingElement):int
		{
			return int(a.expirience) < int(b.expirience) ? 1 : -1;
		}
	}
}