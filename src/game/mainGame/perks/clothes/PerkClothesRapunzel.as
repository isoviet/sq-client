package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.RapunzelLight;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesRapunzel extends PerkClothesCreateObject
	{
		public function PerkClothesRapunzel(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 2;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as RapunzelLight).aging = false;
		}

		override protected function get objectClass():Class
		{
			return RapunzelLight;
		}
	}
}