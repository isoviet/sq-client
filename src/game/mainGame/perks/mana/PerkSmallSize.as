package game.mainGame.perks.mana
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkSmallSize extends PerkMana
	{
		private var buff:BuffRadialView = null;

		public function PerkSmallSize(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_TINY;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.scale = 0.5;

			if (!this.buff)
				this.buff = new BuffRadialView((new SmallSizeButton).upState, 1.0, 0, gls("Малыш"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.scale = 1;

			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}