package game.mainGame.behaviours
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class StateSpeed extends HeroState
	{
		protected var speedBonus:Number = 0;

		protected var bonus:Number = 0;
		protected var buff:BuffRadialView = null;

		public function StateSpeed(time:Number, bonus:Number)
		{
			super(time);

			this.bonus = bonus;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.runSpeed -= this.speedBonus;

				this.hero.removeBuff(this.buff);
			}
			else
			{
				this.speedBonus = value.runSpeed * this.bonus;

				value.runSpeed += this.speedBonus;

				if (!this.buff)
					this.buff = new BuffRadialView((new HighSpeedButton).upState, 1.0, 0, gls("Скорость увеличена"));
				value.addBuff(this.buff);
			}

			super.hero = value;
		}
	}
}