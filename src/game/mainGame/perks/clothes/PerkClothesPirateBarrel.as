package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.PirateBarrel;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesPirateBarrel extends PerkClothesCreateObject
	{
		public function PerkClothesPirateBarrel(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get dX():Number
		{
			return 8;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as PirateBarrel).lifeTime = 20 * 1000;
		}

		override protected function get objectClass():Class
		{
			return PirateBarrel;
		}
	}
}