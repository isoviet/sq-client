package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.HolidayManager;
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

	public class RatingScoreHolidayView extends Sprite
	{
		private var fieldScore:GameField = null;
		private var deltaView:DisplayObject = null;

		private var value:int = 0;
		private var lastValue:int = -1;
		private var step:int = 1;

		private var status:Status = null;
		private var tween:TweenMax = null;

		public function RatingScoreHolidayView()
		{
			init();

			HolidayManager.addEventListener(GameEvent.HOLIDAY_RATINGS, onScore);
			HolidayManager.addEventListener(GameEvent.PLACE_CHANGED, onPlace);

			EnterFrameManager.addListener(onTimer);

			addEventListener(MouseEvent.CLICK, showRating);

			onScore();
		}

		private function init():void
		{
			this.graphics.beginFill(0xA8CCFF, 0.35);
			this.graphics.lineStyle(1, 0x777777, 0.15);
			this.graphics.drawRoundRect(0, 0, 82, 20, 5);

			var image:ImageIconHolidayRating = new ImageIconHolidayRating();
			image.scaleX = image.scaleY = 1.2;
			image.x = -20;
			image.y = -5;
			addChild(image);

			this.fieldScore = new GameField("", 20, 2, new TextFormat(null, 12, 0xFFFFFF, true, null, null, null, null, "center"));
			this.fieldScore.wordWrap = true;
			this.fieldScore.width = 50;
			addChild(this.fieldScore);

			this.status = new Status(this, gls("Рейтинг Хэллоуина"), true);
		}

		private function showRating(event:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);

			if (Screens.active is ScreenGame || Screens.active is ScreenLearning || Screens.active is ScreenSchool)
				return;
			ScreenRating.selected = 5;
			ScreensLoader.load(ScreenRating.instance);
		}

		private function onScore(e:GameEvent = null):void
		{
			this.value = e ? e.data['value'] : HolidayManager.rating;
			Logger.add("onScore", this.value);
			this.step = Math.max(1, (this.value - this.lastValue) / 30);
		}

		private function onPlace(e:GameEvent):void
		{
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

		private function onTimer():void
		{
			if (this.value == this.lastValue)
				return;
			if (this.lastValue == -1)
				this.lastValue = this.value;
			this.lastValue += Math.min(this.step, this.value - this.lastValue);
			this.fieldScore.text = this.lastValue.toString();
		}
	}
}