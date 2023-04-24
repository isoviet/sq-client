package game.mainGame.perks.shaman
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.entity.IMotor;

	public class PerkShamanTimeSlowdown extends PerkShamanActive
	{
		private var heroId:int;
		private var timer:Timer = new Timer(1000, 100);

		private var motors:Array = null;
		private var slowBonuses:Object = {};

		public function PerkShamanTimeSlowdown(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_TIME_SLOWDOWN;

			this.heroId = this.hero.id;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function get available():Boolean
		{
			return super.available && !this.active;
		}

		override public function dispose():void
		{
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			this.motors = null;

			super.dispose();
		}

		override public function reset():void
		{
			this.timer.reset();

			super.reset();

			this.motors = null;
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			deactivateOtherPerks();

			setMotors();

			if (!this.buff)
				this.buff = createBuff(0.5);

			this.hero.addBuff(this.buff, this.timer);

			this.timer.delay = countBonus() * 10;
			this.timer.reset();
			this.timer.start();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.motors)
				return;

			resetMotors();

			this.hero.removeBuff(this.buff, this.timer);
		}

		private function setMotors():void
		{
			if (countExtraBonus() == 0)
				return;

			this.motors = this.hero.game.map.get(IMotor, true);

			for each (var motor:IMotor in this.motors)
			{
				if (!motor)
					continue;

				var slowBonus:Number = motor.motorSpeed * countExtraBonus() / 100;
				this.slowBonuses[motor] = slowBonus;
				motor.motorSpeed -= slowBonus;
			}
		}

		private function resetMotors():void
		{
			for each (var motor:IMotor in this.motors)
			{
				if (!motor || !(motor in this.slowBonuses))
					continue;

				motor.motorSpeed += this.slowBonuses[motor];
			}

			this.slowBonuses = {};
			this.motors = null;
		}

		private function deactivateOtherPerks():void
		{
			if (!this.hero || !this.hero.game)
				return;

			var squirrels:Object = this.hero.game.squirrels.players;
			for each (var hero:Hero in squirrels)
			{
				if (!hero || hero.isDead || hero.inHollow || !hero.shaman)
					continue;

				for (var i:int = 0; i < hero.perksShaman.length; i++)
				{
					if ((hero.perksShaman[i] is PerkShamanTimeSlowdown) && (hero.perksShaman[i] != this) && hero.perksShaman[i].active)
						hero.perksShaman[i].active = false;
				}
			}
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;
		}
	}
}