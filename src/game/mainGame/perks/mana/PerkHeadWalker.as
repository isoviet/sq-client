package game.mainGame.perks.mana
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkHeadWalker extends PerkMana
	{
		private var buff:BuffRadialView = null;

		public function PerkHeadWalker(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_BARBARIAN;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.headWalker = true;

			if (!this.buff)
				this.buff = new BuffRadialView((new HeadWalkerButton).upState, 1.0, 0, gls("Белка-Варвар"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.headWalker = false;

			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}