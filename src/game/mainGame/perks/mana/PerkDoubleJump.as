package game.mainGame.perks.mana
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkDoubleJump extends PerkMana
	{
		private var buff:BuffRadialView = null;

		public function PerkDoubleJump(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_DOUBLE_JUMP;
		}

		override protected function activate():void
		{
			super.activate();
			this.hero.maxInAirJumps++;

			if (!this.buff)
				this.buff = new BuffRadialView((new DoubleJumpButton).upState, 1.0, 0, gls("Двойной прыжок"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();
			this.hero.maxInAirJumps--;
			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}