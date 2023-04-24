package game.mainGame.perks.clothes.scrat
{
	import game.mainGame.perks.clothes.ITransformation;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import game.mainGame.perks.clothes.PerkClothesMagician;

	public class PerkScratMagician extends PerkClothesMagician
	{
		public function PerkScratMagician(hero:Hero):void
		{
			super(hero);
			this.code = PerkClothesFactory.PERK_SCRAT_MAGICIAN;
		}

		override protected function get validHero():Boolean
		{
			return this.hero.isScrat;
		}

		override protected function resetTransformations():void
		{
			for (var i:int = 0; i < this.hero.perkController.perksCharacter.length; i++)
			{
				if ((this.hero.perkController.perksCharacter[i] is ITransformation) && this.hero.perkController.perksCharacter[i].active)
				{
					this.hero.perkController.perksCharacter[i].active = false;
					this.hero.sendLocation(-this.hero.perkController.perksCharacter[i].code);
				}
			}
		}
	}
}