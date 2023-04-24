package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.SamuraiSakura;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesSamurai extends PerkClothesCreateObject
	{
		public function PerkClothesSamurai(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as SamuraiSakura).lifeTime = 15 * 1000;
		}

		override protected function get objectClass():Class
		{
			return SamuraiSakura;
		}
	}
}