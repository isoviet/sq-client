package game.mainGame.perks.shaman
{
	public class PerkShamanSlowFall extends PerkShamanPassive
	{
		static private const BONUSES:Object = {'free': [5, 4, 3], 'paid': [2, 1, 1]};

		private var fallBonus:Number;

		public function PerkShamanSlowFall(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SLOWFALL;
			this.fallBonus = countBonus();
		}

		override protected function countBonus():Number
		{
			var bonus:Number = BONUSES['free'][0];

			if (this.levelFree != 0)
				bonus = Math.min(BONUSES['free'][this.levelFree - 1], bonus);

			if (this.levelPaid != 0)
				bonus = Math.min(BONUSES['paid'][this.levelFree - 1], bonus);

			return bonus;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero)
				return;

			this.hero.fallVelocities.push(this.fallBonus);

			if (this.isMaxLevel)
				this.hero.maxFallJumps++;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			var index:int = this.hero.fallVelocities.indexOf(this.fallBonus);
			if (index != -1)
				this.hero.fallVelocities.splice(index, 1);

			if (this.isMaxLevel)
				this.hero.maxFallJumps--;
		}
	}
}