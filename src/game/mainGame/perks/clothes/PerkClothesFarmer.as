package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.FarmerField;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesFarmer extends PerkClothesCreateObject
	{
		public function PerkClothesFarmer(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 3;
		}

		override protected function get dX():Number
		{
			return 3;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as FarmerField).lifeTime = 15 * 1000;
		}

		override protected function get objectClass():Class
		{
			return FarmerField;
		}
	}
}