package dialogs
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.GameConfig;
	import game.gameData.RatingManager;

	import utils.FiltersUtil;
	import utils.FlashUtil;
	import utils.StringUtil;

	public class DialogRatingSeason extends Dialog
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 18, 0x663300, true, null, null, null, null, "center");
		static private const FORMAT_VALUE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 24, 0x21BF15);
		static private const IMAGES:Array = [RatingIconNone, RatingIconBronze, RatingIconSilver, RatingIconGold, RatingIconMaster, RatingIconDiamond, RatingIconChampion];

		static private const FILTER_FINISH:GlowFilter = new GlowFilter(0xFFFFFF, 1.0, 4, 4, 8);
		static private const FILTER_NAME_SHADOW:DropShadowFilter = new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25);

		private var state:int = 0;
		private var value:int = 0;

		public function DialogRatingSeason(state:int = 0, value:int = -1):void
		{
			super(gls("Итоги сезона"));

			this.state = state;
			this.value = value != -1 ? value : RatingManager.getLastSeasonValue(Game.self['rating_history']);

			init();
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 24, 0xFFCC00, null, null, null, null, null, "center");
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 0;
			this.rightOffset = 0;
			this.topOffset = 0;
			this.bottomOffset = 0;
		}

		override protected function initClose():void
		{
			super.initClose();

			if (!this.buttonClose)
				return;
			this.buttonClose.x -= 20;
			this.buttonClose.y += 10;
		}

		private function init():void
		{
			var width:int = 400;
			var height:int = 370;

			var movie:MovieClip = new RatingChampionAnimation();
			movie.scaleX = movie.scaleY = 7.0;
			movie.x = int(width * 0.5);
			movie.y = 90;
			addChild(movie);

			movie.gotoAndStop(movie.totalFrames - 1);
			FlashUtil.stopAllAnimation(movie);
			movie.filters = FiltersUtil.GREY_FILTER;
			movie.alpha = 0.1;

			switch (this.state)
			{
				case RatingManager.CHANGE_SEASON:
					var field:GameField = new GameField(gls("Твой результат за прошлый сезон:"), 0, 10, FORMAT);
					field.x = int((width - field.textWidth) * 0.5);
					addChild(field);

					var bonusValue:int = int(this.value * RatingManager.BONUS_RATE);
					var league:int = RatingManager.getLeague(this.value, RatingManager.PLAYER_TYPE);

					var image:Sprite = new IMAGES[league]();
					image.scaleX = image.scaleY = 3.5;
					image.x = 105;
					image.y = 100;
					addChild(image);

					if (league == 0)
						addChild(new GameField(gls("Тебе не удалось\nпопасть в лигу"), 210, 80, FORMAT));
					else
					{
						addChild(new GameField(gls("Тебе удалось\nпопасть в лигу"), 210, 60, FORMAT));

						field = new GameField(GameConfig.getLeagueName(league, RatingManager.PLAYER_TYPE), 0, 105, FORMAT_VALUE);
						field.x = 75 + int((width - field.textWidth) * 0.5);
						field.filters = [FILTER_FINISH, FILTER_NAME_SHADOW];
						addChild(field);
					}

					var sprite:Sprite = new Sprite();
					sprite.graphics.beginFill(0x996633, 0.1);
					sprite.graphics.drawRoundRectComplex(0, 190, width, height - 230, 0, 0, 5, 5);
					addChild(sprite);

					field = new GameField(gls("В новом сезоне ты получаешь"), 0, 200, FORMAT);
					field.x = int((width - field.textWidth) * 0.5);
					addChild(field);

					field = new GameField(bonusValue.toString(), 0, 225, FORMAT_VALUE);
					field.x = int((width - field.textWidth) * 0.5) - 3;
					field.filters = [FILTER_FINISH, FILTER_NAME_SHADOW];
					addChild(field);

					field = new GameField(StringUtil.word("бонусное очко", bonusValue), 0, 255, FORMAT);
					field.x = int((width - field.textWidth) * 0.5);
					addChild(field);
					break;
				case RatingManager.MISS_SEASON:
					image = new IMAGES[0]();
					image.scaleX = image.scaleY = 3.5;
					image.x = 90;
					image.y = 65;
					addChild(image);

					sprite = new Sprite();
					sprite.graphics.lineStyle(2, 0xFFFFFF);
					sprite.graphics.moveTo(4, 4);
					sprite.graphics.lineTo(-4, -4);
					sprite.graphics.moveTo(-4, 4);
					sprite.graphics.lineTo(4, -4);
					image.addChild(sprite);

					field = new GameField(gls("Ты не участвовал\nв прошлом сезоне.\nВ новом сезоне ты\nне получаешь\nбонусных очков."), 180, 10, FORMAT);
					addChild(field);
					break;
			}

			var button:ButtonBase = new ButtonBase(gls("Ок"));
			button.x = int((width - button.width) * 0.5);
			button.y = this.state == RatingManager.CHANGE_SEASON ? 295 : 150;
			button.addEventListener(MouseEvent.CLICK, hide);
			addChild(button);

			place();

			this.width = width;
			this.height = this.state == RatingManager.CHANGE_SEASON ? height : (height - 145);
		}
	}
}