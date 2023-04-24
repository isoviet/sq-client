package game.mainGame.perks.clothes
{
	public class PerkClothesSalutSnowgirl extends PerkClothesSalutBase
	{
		public function PerkClothesSalutSnowgirl(hero:Hero):void
		{
			super(hero);

			this.typeSalut = 0;
			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}
	}
}