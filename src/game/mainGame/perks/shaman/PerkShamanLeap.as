package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class PerkShamanLeap extends PerkShamanActive
	{
		static private const TIME_BONUS:int = 5 * 1000;

		private var timer:Timer = new Timer(100, 100);
		private var leapBonus:Number;

		public function PerkShamanLeap(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_LEAP;

			if (this.isMaxLevel)
				this.timer.delay += TIME_BONUS / 100;

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function get available():Boolean
		{
			return super.available && !this.active;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override public function dispose():void
		{
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			super.dispose();
		}

		override public function reset():void
		{
			this.timer.reset();

			super.reset();
		}

		override protected function activate():void
		{
			super.activate();

			this.leapBonus = this.hero.accelerateFactor * (1 + countBonus() / 100);

			this.hero.accelerateFactor *= this.leapBonus;

			if (!this.buff)
				this.buff = createBuff(0.5);

			this.hero.addBuff(this.buff, this.timer);

			this.timer.reset();
			this.timer.start();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.accelerateFactor /= this.leapBonus;

			this.hero.removeBuff(this.buff, this.timer);
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;
		}
	}
}