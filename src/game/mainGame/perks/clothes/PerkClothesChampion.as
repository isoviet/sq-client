package game.mainGame.perks.clothes
{
	public class PerkClothesChampion extends PerkClothesOlympus
	{
		public function PerkClothesChampion(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override protected function get bonus():Number
		{
			return 0.25;
		}
	}
}