package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.perks.ICounted;

	public class PerkShamanImmortal extends PerkShamanActive implements ICounted
	{
		private var useCount:int = 0;

		private var timer:Timer = new Timer(100, 100);
		private var delayTimer:Timer = new Timer(600, 100);

		public function PerkShamanImmortal(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_IMMORTAL;

			this.useCount = countExtraBonus();

			this.timer.delay = countBonus() * 10;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function get available():Boolean
		{
			return super.available && this.activationCount < this.useCount && !this.active && !this.delayTimer.running;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable || this.delayTimer.running)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override public function dispose():void
		{
			this.delayTimer.stop();

			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			super.dispose();
		}

		override public function reset():void
		{
			this.timer.reset();

			super.reset();
		}

		override public function resetRound():void
		{
			this.delayTimer.reset();

			super.resetRound();
		}

		public function get charge():int
		{
			return this.delayTimer.currentCount;
		}

		public function get count():int
		{
			return this.delayTimer.repeatCount;
		}

		public function resetTimer():void
		{}

		override protected function activate():void
		{
			super.activate();

			this.hero.immortal = true;

			if (!this.buff)
				this.buff = createBuff(0.5);

			this.hero.addBuff(this.buff, this.timer);

			this.timer.reset();
			this.timer.start();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.immortal = false;
			this.hero.removeBuff(this.buff, this.timer);
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;

			if (!this.hero.isSelf)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}
	}
}