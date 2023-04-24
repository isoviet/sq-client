package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.AidBridge;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesAid extends PerkClothesCreateObject
	{
		public function PerkClothesAid(hero:Hero)
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override protected function get objectClass():Class
		{
			return AidBridge;
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