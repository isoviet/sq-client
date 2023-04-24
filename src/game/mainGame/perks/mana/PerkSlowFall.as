package game.mainGame.perks.mana
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkSlowFall extends PerkMana
	{
		static private const SLOW_FALL_VELOCITY:Number = 1;

		private var buff:BuffRadialView = null;

		public function PerkSlowFall(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_FLYING;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.fallVelocities.push(SLOW_FALL_VELOCITY);

			if (!this.buff)
				this.buff = new BuffRadialView((new SlowFallButton).upState, 1.0, 0, gls("Белка-летяга"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			var index:int = this.hero.fallVelocities.indexOf(SLOW_FALL_VELOCITY);
			if (index != -1)
				this.hero.fallVelocities.splice(index, 1);

			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}