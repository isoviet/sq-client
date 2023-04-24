package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.EnergyObject;
	import game.mainGame.entity.magic.HipstersCocktail;

	public class PerkClothesHipster extends PerkClothesEnergyObject
	{
		public function PerkClothesHipster(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
		}

		override protected function get energyObject():EnergyObject
		{
			return new HipstersCocktail();
		}
	}
}