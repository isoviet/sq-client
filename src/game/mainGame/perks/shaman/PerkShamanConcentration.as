package game.mainGame.perks.shaman
{
	public class PerkShamanConcentration extends PerkShamanPassive
	{
		private var radiusBonus:Number;

		public function PerkShamanConcentration(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_CONCENTRATION;
		}

		override protected function activate():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			if (!this.hero.isSelf)
				return;

			this.radiusBonus = this.hero.game.cast.castRadius * (countBonus() / 100);
			this.hero.game.cast.castRadius += this.radiusBonus;
			if (!this.isMaxLevel)
				return;

			this.hero.hideCircle = false;
			this.hero.showCircle();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero.isSelf)
				return;

			this.hero.hideCircle = true;
			this.hero.removeCircle();

			if (!this.hero.game || !this.hero.game.cast)
				return;

			this.hero.game.cast.castRadius -= this.radiusBonus;
		}
	}
}