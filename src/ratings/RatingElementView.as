package ratings
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	import clans.Clan;
	import clans.ClanManager;
	import dialogs.clan.DialogClanInfo;
	import events.GameEvent;
	import game.gameData.RatingManager;
	import menu.MenuProfile;
	import statuses.Status;
	import views.ClanIconLoader;

	import com.api.Player;

	import protocol.PacketServer;

	public class RatingElementView extends Sprite
	{
		static protected const TIME_UPDATE:int = 2 * 60;
		static public const HEIGHT:int = 50;

		static protected const FORMAT_PLACE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFFFFF);
		static protected const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF);
		static protected const FORMAT_VALUE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFF2BF);
		static protected const FORMAT_VALUE_OLD:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 11, 0x857653);

		static protected const FORMAT_CLAN:TextFormat = new TextFormat(null, 12, 0x663300, true);
		static protected const FORMAT_DELTA:TextFormat = new TextFormat(null, 12, 0x9C5428, true);

		static protected const FORMAT_TITLE:TextFormat = new TextFormat(null, 11, 0x867754, true);
		static protected const FORMAT_WINS:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0x996633);

		static protected const FILTER_PLACE:GlowFilter = new GlowFilter(0x955432, 1.0, 4, 4, 16);

		static public const VALUE_CHANGE:String = "VALUE_CHANGE";

		protected var _id:int = -1;
		protected var _value:int = -1;

		protected var type:int = -1;
		protected var lastUpdate:int = 0;

		protected var fieldPlace:GameField = null;
		protected var fieldLevel:GameField = null;
		protected var fieldName:GameField = null;
		protected var fieldValue:GameField = null;
		protected var fieldValueOld:GameField = null;
		protected var fieldDelta:GameField = null;
		protected var fieldClan:GameField = null;
		protected var fieldWins:GameField = null;
		protected var fieldShamanWins:GameField = null;

		protected var clanIcon:ClanIconLoader = null;

		protected var deltaView:DisplayObject = null;
		protected var buttonProfile:SimpleButton = null;

		public function RatingElementView(type:int, id:int):void
		{
			this.type = type;
			this._id = id;

			initListener();
			init();
		}

		public function get value():int
		{
			return this._value;
		}

		public function get id():int
		{
			return this._id;
		}

		public function get expired():Boolean
		{
			return (this.lastUpdate + this.timeUpdate < getTimer() / 1000) && !this.isSelf;
		}

		public function set delta(value:int):void
		{
			if (value == 0)
				return;

			eventDelta(value);

			this.fieldDelta.text = Math.abs(value).toString();
			this.fieldDelta.x = 57 - int(this.fieldDelta.textWidth * 0.5);

			if (this.deltaView)
				removeChild(this.deltaView);
			this.deltaView = value > 0 ? new RatingUpIcon : new RatingDownIcon;
			this.deltaView.x = 60 - int(this.deltaView.width * 0.5);
			this.deltaView.y = 8;
			addChild(this.deltaView);
		}

		public function set place(value:int):void
		{
			this.y = value * HEIGHT;

			this.fieldPlace.text = (value + 1).toString();
			this.fieldPlace.x = 25 - int(this.fieldPlace.textWidth * 0.5);
		}

		public function get isSelf():Boolean
		{
			switch (type)
			{
				case RatingManager.PLAYER_TYPE:
					return this.id == Game.selfId;
				case RatingManager.CLAN_TYPE:
					return this.id == Game.self['clan_id'];
			}
			return false;
		}

		public function get loaded():Boolean
		{
			return this.lastUpdate != 0;
		}

		protected function initListener():void
		{
			if (this.isSelf)
			{
				RatingManager.addEventListener(GameEvent.RATING_CHANGED, onChanged);
				Experience.addEventListener(GameEvent.LEVEL_CHANGED, onChanged);
			}

			switch (type)
			{
				case RatingManager.PLAYER_TYPE:
					Game.getPlayer(this.id).addEventListener(RatingView.LOAD_MASK[type], onPlayerLoaded);
					break;
				case RatingManager.CLAN_TYPE:
					ClanManager.getClan(this.id).addEventListener(RatingView.LOAD_MASK[type], onClanLoaded);
					break;
			}
		}

		protected function eventDelta(value:int):void
		{
			if (this.isSelf)
				RatingManager.setSelfDelta(this.type, value);
		}

		protected function get timeUpdate():int
		{
			return TIME_UPDATE;
		}

		protected function init():void
		{
			var back:MovieClip = addChild(this.isSelf ? new RatingElementSelfBackground : new RatingElementBackground) as MovieClip;
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xFFFFFF, 0);
			sprite.graphics.drawRect(back['imageCup'].x, back['imageCup'].y, back['imageCup'].width, back['imageCup'].height);
			back.addChild(sprite);

			var status:Status = new Status(sprite, "", false, true);
			status.maxWidth = 240;
			status.setStatus("<body><b>" + this.ratingCaption + "</b>\n" + this.ratingText + "</body>");

			new Status(back.imageLevelBack, gls("Уровень игрока"));

			this.fieldPlace = new GameField("", 25, 9, FORMAT_PLACE);
			this.fieldPlace.filters = [FILTER_PLACE];
			addChild(this.fieldPlace);

			this.fieldDelta = new GameField("", 60, 25, FORMAT_DELTA);
			addChild(this.fieldDelta);

			this.fieldLevel = new GameField("", 105, 12, FORMAT);
			this.fieldLevel.mouseEnabled = false;
			addChild(this.fieldLevel);

			this.fieldName = new GameField("", 140, 5, FORMAT);
			this.fieldName.filters = [FILTER_PLACE];
			addChild(this.fieldName);

			this.fieldValue = new GameField("", 792, 5, FORMAT_VALUE);
			this.fieldValue.filters = [FILTER_PLACE];
			addChild(this.fieldValue);
			new Status(this.fieldValue, this.currentRatingCaption);

			this.fieldValueOld = new GameField("", 792, 25, FORMAT_VALUE_OLD);
			addChild(this.fieldValueOld);
			new Status(this.fieldValueOld, gls("Очки прошлого сезона"));

			this.buttonProfile = new ButtonRatingShowProfile();
			this.buttonProfile.x = this.fieldName.x;
			this.buttonProfile.y = 13;
			this.buttonProfile.visible = false;
			this.buttonProfile.addEventListener(MouseEvent.MOUSE_UP, showProfile);
			if (!this.isSelf)
				addChild(this.buttonProfile);

			this.clanIcon = new ClanIconLoader("", 140, 28);
			this.clanIcon.visible = false;
			this.clanIcon.addEventListener(MouseEvent.CLICK, showClan);
			addChild(this.clanIcon);

			this.fieldClan = new GameField("", 155, 25, FORMAT_CLAN);
			this.fieldClan.visible = false;
			this.fieldClan.addEventListener(MouseEvent.CLICK, showClan);
			addChild(this.fieldClan);

			this.fieldWins = new GameField("", 640, 3, FORMAT_WINS);
			addChild(this.fieldWins);

			this.fieldShamanWins = new GameField("", 640, 23, FORMAT_WINS);
			addChild(this.fieldShamanWins);

			var field:GameField = new GameField(this.winsText, 0, 5, FORMAT_TITLE);
			field.x = 635 - field.textWidth;
			addChild(field);

			field = new GameField(this.shamanWinsText, 0, 25, FORMAT_TITLE);
			field.x = 635 - field.textWidth;
			addChild(field);
		}

		protected function get currentRatingCaption():String
		{
			return gls("Очки текущего сезона");
		}

		protected function get ratingCaption():String
		{
			return gls("Очки рейтинга");
		}

		protected function get ratingText():String
		{
			return gls("Чтобы заработать очки рейтинга, нужно играть на локации и спасать белок шаманом.\nУспешная игра на сложных локациях приносит больше очков - заходи в дупло раньше других и собирай коллекции, чтобы стать лучшим.");
		}

		protected function get winsText():String
		{
			return gls("Количество побед:");
		}

		protected function get shamanWinsText():String
		{
			return gls("Спасено белок:");
		}

		protected function update(name:String, value:int, level:int, wins:int = 0, shamans:int = 0, history:Array = null):void
		{
			this._value = value;

			this.fieldName.text = name;
			this.buttonProfile.x = this.fieldName.x + this.fieldName.textWidth + 20;
			this.buttonProfile.visible = true;

			this.fieldValue.text = this.value.toString();
			this.fieldValue.x = 792 - this.fieldValue.textWidth;

			this.fieldValueOld.text = RatingManager.getLastSeasonValue(history).toString();
			this.fieldValueOld.x = 792 - this.fieldValueOld.textWidth;

			this.fieldLevel.text = level.toString();
			this.fieldLevel.x = 105 - int(this.fieldLevel.textWidth * 0.5);

			this.fieldWins.text = wins.toString();
			this.fieldShamanWins.text = shamans.toString();

			this.lastUpdate = getTimer() / 1000;

			dispatchEvent(new Event(VALUE_CHANGE));
		}

		protected function onPlayerLoaded(player:Player):void
		{
			setPlayer(player);

			if (player['clan_id'] == 0)
				return;
			var clan:Clan = ClanManager.getClan(player['clan_id']);
			if (clan != null && clan.isLoaded() && clan.state != PacketServer.CLAN_STATE_SUCCESS)
				return;
			clan.addEventListener(ClanInfoParser.INFO, onPlayerClan);
			if (!clan.isLoaded())
				ClanManager.request(player['clan_id']);
			else
				onPlayerClan(clan);
		}

		protected function setPlayer(player:Player):void
		{
			update(player.name, player['rating_score'], player['level'], player['rating_player'], player['rating_shaman'], player['rating_history']);
		}

		protected function onPlayerClan(clan:Clan, type:uint = 0):void
		{
			this.fieldClan.text = clan.name;
			this.fieldClan.name = clan.id.toString();
			this.fieldClan.visible = true;

			this.clanIcon.load(clan.emblemLink);
			this.clanIcon.name = clan.id.toString();
			this.clanIcon.visible = clan.state == PacketServer.CLAN_STATE_SUCCESS;
		}

		protected function onClanLoaded(clan:Clan, type:uint):void
		{
			update(clan.name, clan['rating_score'], clan['level']);
		}

		protected function onChanged(e:GameEvent):void
		{
			update(Game.self.name, Game.self['rating_score'], Experience.selfLevel, Game.self['rating_player'], Game.self['rating_shaman'], Game.self['rating_history']);
		}

		protected function showProfile(e:MouseEvent):void
		{
			MenuProfile.showMenu(this.id);
		}

		protected function showClan(e:MouseEvent):void
		{
			DialogClanInfo.show(e.target.name);
		}
	}
}