package game.mainGame.perks.clothes
{
	import game.mainGame.entity.simple.Bomb;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesRembo extends PerkClothesCreateObject
	{
		public function PerkClothesRembo(hero:Hero):void
		{
			super(hero);
			this.activateSound = "rembo";
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function get startCooldown():Number
		{
			return 10;
		}

		override protected function get objectClass():Class
		{
			return Bomb;
		}

		override protected function get dY():Number
		{
			return 1.5;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.fly;
		}
	}
}