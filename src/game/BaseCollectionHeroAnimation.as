package game
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterSprite;

	public class BaseCollectionHeroAnimation extends StarlingAdapterSprite
	{
		static public const DURATION:int = 6 * 1000;

		private var timer:Timer;
		protected var iconImage:StarlingAdapterSprite = null;

		public function BaseCollectionHeroAnimation():void
		{
			super();

			this.timer = new Timer(1000, 1);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, stop);
		}

		override public function set scaleX(value: Number): void
		{}

		override public function set scaleY(value: Number): void
		{}

		public function play(itemId:int, kind:int, duration:int = 0):void
		{
			if (this.iconImage != null)
			{
				if (this.containsStarling(this.iconImage))
					removeChildStarling(this.iconImage);
				this.iconImage = null;
			}

			setIcon(itemId, kind);
			if (!this.iconImage)
				return;

				addChildStarling(this.iconImage);

			TweenMax.to(this.iconImage, 0.5, {'y': this.posY, 'alpha': 1});

			if (duration == 0)
			{
				this.timer.stop();
				return;
			}

			this.timer.delay = duration;
			this.timer.reset();
			this.timer.start();
		}

		public function dispose():void
		{
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, stop);
			stop(null);
		}

		protected function get posY():int
		{
			return -45;
		}

		protected function setIcon(itemId:int, kind:int):void
		{}

		protected function stop(e:TimerEvent):void
		{
			if (this.iconImage != null && containsStarling(this.iconImage))
				removeChildStarling(this.iconImage);

			this.iconImage = null;
		}
	}
}