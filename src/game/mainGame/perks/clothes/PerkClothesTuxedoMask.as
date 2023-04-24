package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.TuxedoMaskRose;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesTuxedoMask extends PerkClothesCreateObject
	{
		public function PerkClothesTuxedoMask(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_DROP;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 3;
		}

		override protected function get objectClass():Class
		{
			return TuxedoMaskRose;
		}

		override protected function get dX():Number
		{
			return 0;
		}

		override protected function get dY():Number
		{
			return -1.5;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as TuxedoMaskRose).direct = this.hero.heroView.direction;
		}
	}
}