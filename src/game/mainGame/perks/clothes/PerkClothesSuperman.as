package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.SupermanSignView;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesSuperman extends PerkClothesCreateObject
	{
		public function PerkClothesSuperman(hero:Hero):void
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
			(castObject as SupermanSignView).lifeTime = 7 * 1000;
		}

		override protected function get objectClass():Class
		{
			return SupermanSignView;
		}
	}
}