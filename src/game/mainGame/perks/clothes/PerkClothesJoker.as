package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.EnergyObject;
	import game.mainGame.entity.magic.SurpriseBox;

	public class PerkClothesJoker extends PerkClothesEnergyObject
	{
		public function PerkClothesJoker(hero : Hero)
		{
			super(hero);
			this.activateSound = "joker_appearance";

		}

		override protected function get energyObject():EnergyObject
		{
			return new SurpriseBox();
		}
	}
}