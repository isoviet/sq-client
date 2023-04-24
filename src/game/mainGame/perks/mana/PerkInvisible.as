package game.mainGame.perks.mana
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkInvisible extends PerkMana
	{
		private var buff:BuffRadialView = null;

		public function PerkInvisible(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_INVISIBLE;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.transparent = true;

			if (!this.buff)
				this.buff = new BuffRadialView((new InvisibleButton).upState, 1.0, 0, gls("Невидимка"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.transparent = false;

			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}