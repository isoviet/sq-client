package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.PirateCannon;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesPirate extends PerkClothesCreateObject
	{
		public function PerkClothesPirate(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.running && !this.hero.heroView.fly;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get dY():Number
		{
			return -1;
		}

		override protected function get objectClass():Class
		{
			return PirateCannon;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as PirateCannon).direction = this.hero.heroView.direction;
		}
	}
}