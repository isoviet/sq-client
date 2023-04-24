package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.BearBag;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesBear extends PerkClothesCreateObject
	{
		public function PerkClothesBear(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as BearBag).type = int(Math.random() * 5);
		}

		override protected function get objectClass():Class
		{
			return BearBag;
		}
	}
}