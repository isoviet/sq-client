package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.ThroneHologram;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesThrone extends PerkClothesCreateObject
	{
		public function PerkClothesThrone(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as ThroneHologram).lifeTime = 15 * 1000;
		}

		override protected function get objectClass():Class
		{
			return ThroneHologram;
		}
	}
}