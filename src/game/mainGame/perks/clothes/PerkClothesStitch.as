package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.StitchLazer;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesStitch extends PerkClothesCreateObject
	{
		public function PerkClothesStitch(hero:Hero)
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 1;
		}

		override protected function get dY():Number
		{
			return -1;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as StitchLazer).lifeTime = 5 * 1000;
			(castObject as StitchLazer).direction = this.hero.heroView.direction;
		}

		override protected function get objectClass():Class
		{
			return StitchLazer;
		}
	}
}