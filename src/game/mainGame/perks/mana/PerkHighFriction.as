package game.mainGame.perks.mana
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkHighFriction extends PerkMana
	{
		private var buff:BuffRadialView = null;

		private var bonus:Number = 0;

		public function PerkHighFriction(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_ROUGH;
		}

		override protected function activate():void
		{
			super.activate();

			this.bonus = this.hero.friction * 10000;
			this.hero.friction += this.bonus;

			if (!this.buff)
				this.buff = new BuffRadialView((new HightFrictionButton).upState, 1.0, 0, gls("Цепкие лапки"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.friction -= this.bonus;

			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}