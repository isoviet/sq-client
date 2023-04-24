package game.mainGame.perks.shaman
{
	public class PerkShamanWeight extends PerkShamanPassive
	{
		static private const LIFE_TIME:int = 30 * 1000;

		static public var weightBonuses:Object = {};

		public function PerkShamanWeight(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_WEIGHT;
		}

		override protected function activate():void
		{
			super.activate();

			weightBonuses[this.hero.id] = {'weight': countBonus()};
			if (this.isMaxLevel)
				weightBonuses[this.hero.id]['lifeTime'] = LIFE_TIME;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			delete weightBonuses[this.hero.id];
		}
	}
}