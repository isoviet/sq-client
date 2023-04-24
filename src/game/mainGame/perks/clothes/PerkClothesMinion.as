package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateBanana;
	import game.mainGame.entity.magic.Banana;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;

	public class PerkClothesMinion extends PerkClothesCreateObject
	{
		public function PerkClothesMinion(hero:Hero)
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get objectClass():Class
		{
			return Banana;
		}

		override protected function activate():void
		{
			super.activate();

			var stateBanana:StateBanana = new StateBanana(10, true);
			this.hero.behaviourController.addState(stateBanana);
		}
	}
}