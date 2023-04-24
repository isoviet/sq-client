package dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.GameConfig;
	import game.gameData.RatingManager;
	import sounds.SoundConstants;

	import utils.FlashUtil;
	import utils.WallTool;

	public class DialogRatingLeague extends Dialog
	{
		static private const MOVIES:Array = [RatingIconNone, RatingBronzeAnimation, RatingSilverAnimation, RatingGoldAnimation, RatingMasterAnimation, RatingDiamondAnimation, RatingChampionAnimation];
		static private const IMAGES:Array = [null, RepostImageBronze, RepostImageSilver, RepostImageGold, RepostImageMaster, RepostImageDiamond, RepostImageChampion];

		static private const FILTER_FINISH:GlowFilter = new GlowFilter(0xFFFFFF, 1.0, 4, 4, 8);
		static private const FILTER_POST:GlowFilter = new GlowFilter(0x19545E, 1.0, 4, 4, 16);
		static private const FILTER_NAME_SHADOW:DropShadowFilter = new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25);

		static private const FORMAT_POST_TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 17, 0xFFFFFF);
		static private const FORMAT_POST_NAME:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 17, 0xFFF5B8);

		private var league:int = -1;
		private var movie:MovieClip = null;

		public function DialogRatingLeague(league:int):void
		{
			super(gls("Поздравляем!"));

			this.league = league;

			init();
			this.sound = SoundConstants.REWARD;
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
			this.movie = new MOVIES[this.league]();
			this.movie.scaleX = this.movie.scaleY = 6.0;
			this.movie.x = 160;
			this.movie.y = 80;
			this.movie.addFrameScript(this.movie.totalFrames - 1, stopAnimation);
			addChild(this.movie);

			var field:GameField = new GameField(gls("Ты перешёл в лигу:"), 0, 180, new TextFormat(GameField.PLAKAT_FONT, 16, 0x8D663E));
			field.x = 160 - int(field.textWidth * 0.5);
			addChild(field);

			field = new GameField(GameConfig.getLeagueName(this.league, RatingManager.PLAYER_TYPE), 0, 200, new TextFormat(GameField.PLAKAT_FONT, 22, 0x21BF15));
			field.x = 160 - int(field.textWidth * 0.5) - 3;
			field.filters = [FILTER_FINISH, FILTER_NAME_SHADOW];
			addChild(field);

			var button:ButtonBase = new ButtonBase(gls("Поделиться"));
			button.x = 160 - int(button.width * 0.5);
			button.y = 250;
			button.addEventListener(MouseEvent.CLICK, repost);
			addChild(button);

			place();

			this.width = 320;
			this.height = 330;
		}

		private function repost(e:MouseEvent):void
		{
			var sprite:Sprite = new Sprite();
			sprite.addChild(new IMAGES[this.league]());

			var logo:DisplayObject = PreLoader.getLogo();
			logo.scaleX = logo.scaleY = 0.5;
			logo.x = int((sprite.width - logo.width) * 0.5);
			logo.y = int((sprite.height - logo.height) - 5);
			sprite.addChild(logo);

			var fieldText:GameField = new GameField(gls("Я достиг лиги:"), 0, 15, FORMAT_POST_TEXT);
			var fieldName:GameField = new GameField(GameConfig.getLeagueName(this.league, RatingManager.PLAYER_TYPE), 0, 15, FORMAT_POST_NAME);
			fieldText.x = int((sprite.width - (fieldText.textWidth + fieldName.textWidth + 3)) * 0.5);
			fieldName.x = fieldText.x + fieldText.textWidth + 3;
			fieldText.filters = [FILTER_POST];
			fieldName.filters = [FILTER_POST];
			sprite.addChild(fieldText);
			sprite.addChild(fieldName);

			var bitmapData:BitmapData = new BitmapData(280, 280);
			bitmapData.draw(sprite);

			NewsImageGenerator.save(bitmapData, "new_league_" + this.league, false);
			WallTool.place(Game.self, WallTool.WALL_RATING_LEAGUE, this.league, new Bitmap(bitmapData), gls("Я достиг новой лиги!"));
		}

		private function stopAnimation():void
		{
			this.movie.stop();
			FlashUtil.stopAllAnimation(this.movie);
		}
	}
}