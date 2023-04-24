package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.EvaHologram;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesEva extends PerkClothesCreateObject
	{
		public function PerkClothesEva(hero:Hero)
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 5;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as EvaHologram).lifeTime = 25 * 1000;
		}

		override protected function get objectClass():Class
		{
			return EvaHologram;
		}
	}
}