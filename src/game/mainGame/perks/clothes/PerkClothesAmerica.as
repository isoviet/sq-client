package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.AmericaShield;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesAmerica extends PerkClothesCreateObject
	{
		public function PerkClothesAmerica(hero:Hero):void
		{
			super(hero);
			this.activateSound = SOUND_DROP;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override protected function get dY():Number
		{
			return -1;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as AmericaShield).lifeTime = 2 * 1000;
			(castObject as AmericaShield).direction = this.hero.heroView.direction;
		}

		override protected function get objectClass():Class
		{
			return AmericaShield;
		}
	}
}