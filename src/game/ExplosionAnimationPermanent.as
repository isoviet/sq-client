package game
{
	import flash.events.TimerEvent;

	import game.ExplosionAnimation;

	public class ExplosionAnimationPermanent extends ExplosionAnimation
	{
		public function ExplosionAnimationPermanent():void
		{
			super();
		}

		override public function stop(e:TimerEvent = null):void
		{
			timer.removeEventListener(TimerEvent.TIMER, nextCast);
		}

		public function removeAnimation():void
		{
			timer.removeEventListener(TimerEvent.TIMER, nextCast);
			if (this.perkView == null)
				return;
			removeChild(this.perkView);
			this.perkView = null;
		}
	}
}