package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.Blizzard;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesBlizzard extends PerkClothesCreateObject

	{
		public function PerkClothesBlizzard(hero:Hero):void
		{
			super(hero);

			this.activateSound = "snowfreeze";
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get dX():Number
		{
			return 7.5;
		}

		override protected function get dY():Number
		{
			return -2;
		}

		override protected function get objectClass():Class
		{
			return Blizzard;
		}
	}
}