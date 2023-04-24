package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.EnergyObject;
	import game.mainGame.entity.magic.GoldSack;

	public class PerkClothesLeprechaun extends PerkClothesEnergyObject
	{
		public function PerkClothesLeprechaun(hero:Hero)
		{
			super(hero);

			this.activateSound = "leprechaun";
		}

		override protected function get energyObject():EnergyObject
		{
			return new GoldSack();
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}
	}
}