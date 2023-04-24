package game.mainGame.perks.shaman
{
	public class PerkShamanSatiety extends PerkShamanActive
	{
		private var massBonus:int = 0;

		public function PerkShamanSatiety(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SATIETY;
		}

		override protected function activate():void
		{
			super.activate();

			this.massBonus = this.hero.mass * (countBonus() / 100);
			this.hero.mass += this.massBonus;

			if (!this.buff)
				this.buff = createBuff(0);
			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.mass -= this.massBonus;
			this.hero.removeBuff(this.buff);
		}
	}
}