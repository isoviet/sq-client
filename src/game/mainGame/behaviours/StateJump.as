package game.mainGame.behaviours
{
	public class StateJump extends HeroState
	{
		protected var jumpBonus:Number = 0;

		protected var bonus:Number = 0;

		public function StateJump(time:Number, bonus:Number)
		{
			super(time);

			this.bonus = bonus;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.jumpVelocity -= this.jumpBonus;
			}
			else
			{
				this.jumpBonus = value.runSpeed * this.bonus;

				value.jumpVelocity += this.jumpBonus;
			}

			super.hero = value;
		}
	}
}