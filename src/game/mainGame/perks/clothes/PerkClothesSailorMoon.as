package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.SailorMoonPlanet;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesSailorMoon extends PerkClothesCreateObject
	{
		public function PerkClothesSailorMoon(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get objectClass():Class
		{
			return SailorMoonPlanet;
		}

		override protected function get dX():Number
		{
			return 10;
		}

		override protected function get dY():Number
		{
			return 3;
		}
	}
}