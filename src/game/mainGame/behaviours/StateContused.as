package game.mainGame.behaviours
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class StateContused extends HeroState
	{
		protected var buff:BuffRadialView = null;

		public function StateContused(time:Number)
		{
			super(time);
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.heroView.contused = false;

				this.hero.removeBuff(this.buff);
			}
			else
			{
				value.heroView.contused = true;

				if (!this.buff)
					this.buff = new BuffRadialView(new IconPerkStun(), 0.9, 0, gls("Дезориентация"), 18, 18);
				value.addBuff(this.buff);
			}

			super.hero = value;
		}
	}
}