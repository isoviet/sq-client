package game
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import views.ExplosionView;

	import com.greensock.TweenMax;

	public class ExplosionAnimation extends Sprite
	{
		static private const EXPLOSIONS_COUNT:int = 5;

		protected var timer:Timer = new Timer(150);

		protected var perkView:DisplayObject = null;

		private var explosionSprite:Sprite = new Sprite();

		public function ExplosionAnimation():void
		{
			super();

			addChild(this.explosionSprite);
		}

		public function play(button:SimpleButton, delay:int, showExplosion:Boolean = true):void
		{
			if (this.perkView != null)
			{
				removeChild(this.perkView);
				this.perkView = null;
			}

			if (button != null)
			{
				this.perkView = button.upState;
				this.perkView.x = 17;
				this.perkView.y = -10;
				this.perkView.width = this.perkView.height = 30;
				this.perkView.alpha = 0.5;
				addChild(this.perkView);

				TweenMax.to(this.perkView, 0.5, {'y': -50, 'alpha': 1});
			}

			if (!showExplosion)
				return;

			this.timer.reset();
			this.timer.repeatCount = EXPLOSIONS_COUNT + int(delay / this.timer.delay);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, stop);
			this.timer.addEventListener(TimerEvent.TIMER, nextCast);
			this.timer.start();
		}

		public function stop(e:TimerEvent = null):void
		{
			if (this.perkView != null)
				removeChild(this.perkView);
			this.perkView = null;

			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, stop);
		}

		protected function nextCast(e:TimerEvent):void
		{
			var boom:ExplosionView = new ExplosionView(partGo2);
			boom.x = Math.random() * 40;
			boom.y = Math.random() * 35;
			boom.scaleX = 0.5;
			boom.scaleY = 0.5;
			this.explosionSprite.addChild(boom);

			if (this.timer.currentCount == EXPLOSIONS_COUNT)
				this.timer.removeEventListener(TimerEvent.TIMER, nextCast);
		}
	}
}