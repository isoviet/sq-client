package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.McTwistTimeWarp;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesMcTwist extends PerkClothesCreateObject
	{
		public function PerkClothesMcTwist(hero:Hero)
		{
			super(hero);

			this.soundOnlyHimself = true;
			this.activateSound = SOUND_APPEARANCE;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			(castObject as McTwistTimeWarp).lifeTime = 10 * 1000;
		}

		override protected function get objectClass():Class
		{
			return McTwistTimeWarp;
		}

		override protected function get dX():Number
		{
			return 0;
		}

		override protected function get dY():Number
		{
			return -2;
		}
	}
}