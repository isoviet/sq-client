package views
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.GameConfig;
	import game.gameData.RatingManager;
	import loaders.ScreensLoader;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.ScreenRating;
	import screens.ScreenSchool;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;

	import com.greensock.TweenMax;

	import utils.DateUtil;
	import utils.FlashUtil;
	import utils.StringUtil;

	public class RatingScoreView extends Sprite
	{
		static private const MOVIES:Array = [RatingIconNone, RatingBronzeAnimation, RatingSilverAnimation, RatingGoldAnimation, RatingMasterAnimation, RatingDiamondAnimation, RatingChampionAnimation];
		static private const FILTER:GlowFilter = new GlowFilter(0xFFFFFF, 1, 4, 4);

		static private const MAX_STEPS:int = 15;

		private var movieLeague:MovieClip = null;
		private var movieStep:int = 0;
		private var playing:Boolean = false;

		private var fieldScore:GameField = null;
		private var deltaView:DisplayObject = null;

		private var value:int = 0;
		private var lastValue:int = -1;
		private var step:int = 1;

		private var leagues:Array = [];
		private var league:int = -1;

		private var status:Status = null;
		private var tween:TweenMax = null;

		public function RatingScoreView():void
		{
			init();

			RatingManager.addEventListener(GameEvent.LEAGUE_CHANGED, onLeague);
			RatingManager.addEventListener(GameEvent.RATING_CHANGED, onScore);
			RatingManager.addEventListener(GameEvent.PLACE_CHANGED, onPlace);

			EnterFrameManager.addListener(onTimer);
			EnterFrameManager.addPerSecondTimer(updateStatus);

			addEventListener(MouseEvent.CLICK, showRating);

			onLeague();
			onScore();
		}

		private function init():void
		{
			this.graphics.beginFill(0xA8CCFF, 0.35);
			this.graphics.lineStyle(1, 0x777777, 0.15);
			this.graphics.drawRoundRect(0, 0, 82, 20, 5);

			this.fieldScore = new GameField("", 20, 2, new TextFormat(null, 12, 0xFFFFFF, true, null, null, null, null, "center"));
			this.fieldScore.wordWrap = true;
			this.fieldScore.width = 50;
			addChild(this.fieldScore);

			this.status = new Status(this, "", false, true);
		}

		private function showRating(event:MouseEvent):void
		{

			GameSounds.play(SoundConstants.BUTTON_CLICK, true);

			if (Screens.active is ScreenGame || Screens.active is ScreenLearning || Screens.active is ScreenSchool)
				return;
			ScreensLoader.load(ScreenRating.instance);
		}

		private function onScore(e:GameEvent = null):void
		{
			if (e && e.data['type'] != RatingManager.PLAYER_TYPE)
				return;
			this.value = e ? e.data['value'] : RatingManager.getScore(RatingManager.PLAYER_TYPE);
			this.step = Math.max(1, (this.value - this.lastValue) / 30);
		}

		private function onPlace(e:GameEvent):void
		{
			if (e.data['type'] != RatingManager.PLAYER_TYPE)
				return;
			if (this.tween)
				this.tween.kill();
			if (this.deltaView)
				removeChild(this.deltaView);
			this.deltaView = null;

			if (e.data['value'] == 0)
				return;
			this.deltaView = e.data['value'] > 0 ? new RatingUpIcon : new RatingDownIcon;
			this.deltaView.x = 69;
			this.deltaView.y = 2;
			addChild(this.deltaView);

			this.tween = TweenMax.to(this.deltaView, 0.4, {'y': e.data['value'] > 0 ? 1 : 3, 'repeat': 3,
				'onRepeat': function():void
				{
					deltaView.y = 2;
				},
				'onComplete': function():void
				{
					deltaView.y = 2;
				}
			});
		}

		private function onLeague(e:GameEvent = null):void
		{
			if (e && e.data['type'] != RatingManager.PLAYER_TYPE)
				return;

			if (!this.movieLeague)
			{
				this.league = RatingManager.getSelfLeague(RatingManager.PLAYER_TYPE);

				this.movieLeague = new MOVIES[this.league]();
				this.movieLeague.gotoAndStop(this.movieLeague.totalFrames - 1);
				this.movieLeague.y = 10;
				this.movieLeague.filters = [FILTER];
				addChild(this.movieLeague);
			}
			else
			{
				this.leagues.push(RatingManager.getSelfLeague(RatingManager.PLAYER_TYPE));

				if (!this.playing)
					showAnimation();
			}
		}

		private function showAnimation():void
		{
			this.movieStep = 0;
			this.playing = true;
		}

		private function onTimer():void
		{
			updateScore();
			updateImage();
		}

		private function updateStatus():void
		{
			var text:String = "<b>" + gls("Рейтинг") + "\n</b>";
			if (this.league < GameConfig.getLeagueCount(RatingManager.PLAYER_TYPE) - 1)
			{
				var remainedScore:int = RatingManager.getRemainedScore(RatingManager.PLAYER_TYPE);
				if (remainedScore > 0)
				{
					text += gls("Лига:") + " <b>" + GameConfig.getLeagueName(Math.max(0, this.league), RatingManager.PLAYER_TYPE) + "</b><br>";
					text += gls("До след. лиги:") + " <b> " + remainedScore + " </b>" + StringUtil.word("очко", remainedScore) + "<br>";
				}
				else
					text += gls("Для попадания в лигу сыграй") + "<b> " + gls("один раунд") + "</b><br>";
			}
			else
				text += gls("Лига:") + " <b>" + GameConfig.getLeagueName(Math.max(0, this.league), RatingManager.PLAYER_TYPE) + "</b><br>";
			text += gls("До конца сезона:") + " <b>" + DateUtil.durationDayTime(RatingManager.seasonTime) + "</b>";
			this.status.setStatus("<body>" + text + "</body>");
		}

		private function updateScore():void
		{
			if (this.value == this.lastValue)
				return;
			if (this.lastValue == -1)
				this.lastValue = this.value;
			this.lastValue += Math.min(this.step, this.value - this.lastValue);
			this.fieldScore.text = this.lastValue.toString();
		}

		private function updateImage():void
		{
			if (!this.playing || this.movieStep >= MAX_STEPS)
				return;
			this.movieStep++;

			var value:int = 255 * (this.movieStep / MAX_STEPS);
			this.movieLeague.filters = [new ColorMatrixFilter([1, 0, 0, 0, value,
									0, 1, 0, 0, value,
									0, 0, 1, 0, value,
									0, 0, 0, 1, 0])];

			if (this.movieStep < MAX_STEPS)
				return;
			removeChild(this.movieLeague);

			this.league = this.leagues.shift();

			this.movieLeague = new MOVIES[this.league]();
			this.movieLeague.addFrameScript(this.movieLeague.totalFrames - 1, onAnimationStop);
			this.movieLeague.gotoAndPlay(0);
			this.movieLeague.y = 10;
			addChild(this.movieLeague);
		}

		private function onAnimationStop():void
		{
			this.movieLeague.stop();
			FlashUtil.stopAllAnimation(this.movieLeague);
			this.movieLeague.filters = [FILTER];

			if (this.leagues.length > 0)
				showAnimation();
			else
				this.playing = false;
		}
	}
}