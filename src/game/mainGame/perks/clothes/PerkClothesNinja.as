package game.mainGame.perks.clothes
{
	public class PerkClothesNinja extends PerkClothesJumpCloud
	{
		public function PerkClothesNinja(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}
	}
}