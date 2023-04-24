package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.perks.ICounted;

	public class PerkShamanHoistman extends PerkShamanActive implements ICounted
	{
		private var delayTimer:Timer = new Timer(100, 100);
		private var timer:Timer = new Timer(10, 100);

		private var oldCastRadius:Number = 0;

		public function PerkShamanHoistman(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_HOISTMAN;

			this.timer.delay = countBonus() * 10;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function get available():Boolean
		{
			return super.available && !timer.running && !this.delayTimer.running;
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
			if (!this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			if (this.isMaxLevel)
			{
				if (!this.buff)
					this.buff = createBuff(0);

				this.hero.addBuff(this.buff);
			}
			else
			{
				if (!this.buff)
					this.buff = createBuff(0.5);

				this.hero.addBuff(this.buff, this.timer);

				this.timer.reset();
				this.timer.start();
			}

			if (!this.hero.isSelf)
				return;

			this.oldCastRadius = this.hero.game.cast.castRadius;

			if (this.hero.game.cast.castObject)
				this.hero.game.cast.castObject = null;

			this.hero.game.cast.castRadius = 0;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.isMaxLevel)
				this.hero.removeBuff(this.buff);
			else
				this.hero.removeBuff(this.buff, this.timer);

			if (!this.hero.game || !this.hero.game.cast || !this.hero.isSelf || this.oldCastRadius == 0)
				return;

			if (this.hero.game.cast.castObject)
				this.hero.game.cast.castObject = null;

			this.hero.game.cast.castRadius = this.oldCastRadius;
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;

			if (this.isMaxLevel || !this.hero.isSelf)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}

		override protected function onShaman(e:SquirrelEvent):void
		{
			super.onShaman(e);

			if (!e.player.shaman || this.active || !super.available || !this.isMaxLevel)
				return;

			this.active = true;
		}
	}
}