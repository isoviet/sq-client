package game.mainGame.perks.shaman
{
	public class PerkShamanHelium extends PerkShamanPassive
	{
		static public var heliumBonuses:Object = {};

		public function PerkShamanHelium(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_HELIUM;
		}

		override protected function activate():void
		{
			super.activate();

			heliumBonuses[this.hero.id] = {'power': countBonus(), 'doubleCast': this.isMaxLevel};
		}

		override protected function deactivate():void
		{
			super.deactivate();

			delete heliumBonuses[this.hero.id];
		}
	}
}