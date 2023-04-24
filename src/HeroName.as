package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.RatingManager;
	import screens.ScreenGame;

	import com.api.Player;
	import com.api.PlayerEvent;

	import utils.starling.StarlingAdapterSprite;

	public class HeroName extends StarlingAdapterSprite
	{
		static private const LOAD_MASK:int = PlayerInfoParser.NAME | PlayerInfoParser.SHAMAN_EXP | PlayerInfoParser.VIP_INFO | PlayerInfoParser.RATING_INFO | PlayerInfoParser.RATING_HISTORY;

		static private const LEAGUES:Array = [Sprite, RatingIconBronze, RatingIconSilver, RatingIconGold, RatingIconMaster, RatingIconDiamond, RatingIconChampion];

		static private const FORMAT_WHITE:TextFormat = new TextFormat(null, 12, 0xDDE7EE, false);
		static private const FORMAT_BLUE:TextFormat = new TextFormat(null, 12, 0x96DCFC, true);
		static private const FORMAT_BLUE_BOLD:TextFormat = new TextFormat(null, 12, 0x96DCFC, true);
		static private const FORMAT_YELLOW:TextFormat = new TextFormat(null, 12, 0xFBFFBD, true);
		static private const FORMAT_RED:TextFormat = new TextFormat(null, 12, 0xFF4D73, true);
		static private const FORMAT_RED_BOLD:TextFormat = new TextFormat(null, 12, 0xFF4D73, true);

		static private const FORMAT_CLAN:TextFormat = new TextFormat(null, 9, 0xFFDD70, false);

		static private const SHADOW_BLACK:DropShadowFilter = new DropShadowFilter(0, 45, 0x2C4167, 1, 4, 4, 4);
		static private const SHADOW_BLACK_LOW:DropShadowFilter = new DropShadowFilter(0, 45, 0x2C4167, 1, 3, 3, 1);

		static private const GLOW_FILTER:GlowFilter = new GlowFilter(0xFF0000, 1, 3, 3, 16);

		private var playerId:int;

		private var squirrelFormat:TextFormat = null;
		private var squirrelFilters:Array = [];

		private var shamanFormat:TextFormat = null;
		private var shamanFilters:Array = [];

		private var _shaman:Boolean = false;

		private var shamanExpSprite:Sprite = null;
		private var isRed:Boolean = false;

		private var imageVip:DisplayObject = null;
		private var imageLeague:Sprite = null;

		private var fieldLevel:GameField = null;
		public var fieldName:GameField = null;
		public var fieldClan:GameField = null;

		private var _starlingSpriteName:StarlingAdapterSprite = null;

		public function HeroName(playerId:int):void
		{
			super();

			this.playerId = playerId;

			init();

			if (this.playerId == Game.selfId)
				RatingManager.addEventListener(GameEvent.LEAGUE_CHANGED, onLeagueChanged);

			Game.listen(onPlayerLoaded);
			Game.request(this.playerId, LOAD_MASK);
		}

		override public function scaleXY(x:Number, y:Number = 0):void
		{}

		override public function set scaleX(value:Number):void
		{}

		override public function set scaleY(value:Number):void
		{}

		public function set team(value:int):void
		{
			this.isRed = (value == Hero.TEAM_RED);

			redraw();

			if (this.playerId == Game.selfId)
				return;

			switch (value)
			{
				case Hero.TEAM_BLUE:
					this.squirrelFormat = FORMAT_BLUE;
					this.shamanFormat = FORMAT_BLUE_BOLD;
					this.squirrelFilters = [SHADOW_BLACK];
					break;
				case Hero.TEAM_RED:
					this.squirrelFormat = FORMAT_RED;
					this.shamanFormat = FORMAT_RED_BOLD;
					this.squirrelFilters = [SHADOW_BLACK];
					break;
				default:
					this.squirrelFormat = FORMAT_WHITE;
					this.shamanFormat = FORMAT_BLUE_BOLD;
					this.squirrelFilters = [];
					break;
			}

			updateStyle(this._shaman);
		}

		public function dispose(): void
		{
			if (_starlingSpriteName)
				_starlingSpriteName.removeFromParent(true);
			_starlingSpriteName = null;
		}

		public function set shaman(value:Boolean):void
		{
			updateStyle(value);
			this._shaman = value;

			redraw();
		}

		public function set shamanLevel(value:int):void
		{
			this.fieldLevel.text = value.toString();
			redraw();
		}

		private function init():void
		{
			if (this.playerId == Game.selfId)
			{
				this.squirrelFormat = FORMAT_YELLOW;
				this.squirrelFilters = [SHADOW_BLACK];

				this.shamanFormat = FORMAT_YELLOW;
				this.shamanFilters = [SHADOW_BLACK];
			}
			else
			{
				this.squirrelFormat = FORMAT_WHITE;
				this.squirrelFilters = [SHADOW_BLACK_LOW];

				this.shamanFormat = FORMAT_BLUE_BOLD;
				this.shamanFilters = [SHADOW_BLACK];
			}

			this.fieldName = new GameField("", 0, 0, this.squirrelFormat);
			this.fieldName.filters = this.squirrelFilters;
			addChild(this.fieldName);

			this.fieldClan = new GameField("", 0, 15, FORMAT_CLAN);
			this.fieldClan.filters = this.squirrelFilters;
			addChild(this.fieldClan);

			this.fieldLevel = new GameField("", 0, 0, new TextFormat(GameField.PLAKAT_FONT, 15, 0x012A54));

			this.imageLeague = new Sprite();
			addChild(this.imageLeague);

			this.imageVip = new ImageNameVIP();
			this.imageVip.y = -5;
			this.imageVip.visible = false;
			addChild(this.imageVip);

			redraw();
		}

		private function onLeagueChanged(e:GameEvent):void
		{
			if (e.data['type'] != RatingManager.PLAYER_TYPE)
				return;
			this.league = e.data['value'];
		}

		private function set isVIP(value:Boolean):void
		{
			this.imageVip.visible = value;
		}

		private function set league(value:int):void
		{
			if (this.imageLeague)
				removeChild(this.imageLeague);
			this.imageLeague = (this.playerId == Game.selfId || value >= LEAGUES.length - 2) ? new LEAGUES[value]() : new Sprite();
			this.imageLeague.scaleX = this.imageLeague.scaleY = 0.6;
			this.imageLeague.y = 5;
			addChild(this.imageLeague);

			var place:int = RatingManager.getPlayerTopPlace(this.playerId);
			if (place != -1)
				this.imageLeague.addChild(new GameField(place.toString(), 0, 0, new TextFormat(null, 10, 0xFFFFFF))).filters = [GLOW_FILTER];
		}

		public function set playerName(value:String):void
		{
			this.fieldName.text = value;
		}

		private function updateStyle(value:Boolean):void
		{
			this.fieldName.defaultTextFormat = value ? this.shamanFormat : this.squirrelFormat;
			this.fieldName.setTextFormat(value ? this.shamanFormat : this.squirrelFormat);
			this.fieldName.filters = value ? this.shamanFilters : this.squirrelFilters;
			redraw();
		}

		public function redraw():void
		{
			this.graphics.clear();

			if (this.fieldName.text == "")
				return;

			var width:int = Math.max(this.fieldName.textWidth, this.fieldClan.textWidth) + ((this.imageLeague.width > 0) || this.imageVip.visible ? 30 : 20);
			var height:int = this.fieldClan.text == "" ? 20 : 30;

			this.fieldName.x = int((width - this.fieldName.textWidth) * 0.5) - 2;
			this.fieldClan.x = int((width - this.fieldClan.textWidth) * 0.5) - 1;

			this.graphics.beginFill(0x000000, 0.0);
			if (this._shaman)
				this.graphics.beginFill(0xFFFFFF, 0.45);
			if (this.playerId == Game.selfId)
				this.graphics.beginFill(0x000000, 0.45);
			this.graphics.drawRoundRect(0, 0, width, height, 10);
			this.graphics.endFill();

			this.imageVip.x = width - 5;

			if(_starlingSpriteName)
				_starlingSpriteName.removeFromParent(true);

			_starlingSpriteName = null;

			updateShamanLevel();

			if (this.shamanExpSprite)
				this.shamanExpSprite.x = int(width * 0.5);

			_starlingSpriteName = new StarlingAdapterSprite(this, true);
			_starlingSpriteName.pivotX = 0;
			_starlingSpriteName.pivotY = (this._shaman ? -70 : -80) + height;
			_starlingSpriteName.x = -int(width * 0.5);
			addChildStarling(_starlingSpriteName);
		}

		private function updateShamanLevel():void
		{
			if (this._shaman && (ScreenGame.mode != Locations.BLACK_SHAMAN_MODE) && this.fieldLevel.text != "")
			{
				if (!this.shamanExpSprite)
				{
					this.shamanExpSprite = new Sprite();
					this.shamanExpSprite.addChild(this.isRed ? new ImageNameShamanRed() : new ImageNameShaman());
					this.shamanExpSprite.addChild(this.fieldLevel);
					this.addChild(this.shamanExpSprite);

					this.fieldLevel.x = -int(this.fieldLevel.textWidth * 0.5) - 3;
					this.fieldLevel.y = -this.fieldLevel.textHeight - 1;
				}

				this.shamanExpSprite.visible = true;
			}
			else
			{
				if (!this.shamanExpSprite)
					return;
				this.shamanExpSprite.visible = false;
			}
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player.id != playerId)
				return;
			this.playerName = player.name;
			this.isVIP = player['vip_exist'] > 0;
			if (this.playerId == Game.selfId)
				this.league = RatingManager.getSelfLeague(RatingManager.PLAYER_TYPE);
			else
				this.league = RatingManager.getLeague(player['rating_score'], RatingManager.PLAYER_TYPE);
			this.shamanLevel = player['shaman_level'];

			redraw();
		}
	}
}