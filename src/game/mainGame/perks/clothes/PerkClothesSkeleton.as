package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.SkeletonSkullObject;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesSkeleton extends PerkClothesCreateObject
	{
		public function PerkClothesSkeleton(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 3;
		}

		override protected function get objectClass():Class
		{
			return SkeletonSkullObject;
		}

		override protected function get dX():Number
		{
			return 0;
		}

		override protected function get dY():Number
		{
			return 1;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as SkeletonSkullObject).lifeTime = 10 * 1000;
		}
	}
}