package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.AnubisObelisk;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesAnubis extends PerkClothesCreateObject
	{
		public function PerkClothesAnubis(hero:Hero)
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get objectClass():Class
		{
			return AnubisObelisk;
		}

		override protected function get dX():Number
		{
			return 0;
		}

		override protected function get dY():Number
		{
			return -5;
		}
	}
}