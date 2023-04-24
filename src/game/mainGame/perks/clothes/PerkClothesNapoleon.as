package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.NapoleonBouncer;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesNapoleon extends PerkClothesCreateObject
	{
		public function PerkClothesNapoleon(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override protected function get dX():Number
		{
			return 2;
		}

		override protected function get dY():Number
		{
			return 1;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.running && !this.hero.heroView.fly;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as NapoleonBouncer).lifeTime = 15 * 1000;
		}

		override protected function get objectClass():Class
		{
			return NapoleonBouncer;
		}
	}
}