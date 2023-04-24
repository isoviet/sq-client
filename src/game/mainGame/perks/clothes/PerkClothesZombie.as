package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.ZombieSavePoint;
	import game.mainGame.perks.clothes.base.PerkClothesSavePoint;

	public class PerkClothesZombie extends PerkClothesSavePoint
	{
		public function PerkClothesZombie(hero:Hero):void
		{
			super(hero);

			this.activateSound = "zombie";
			this.soundOnlyHimself = true;
		}

		override protected function get objectClass():Class
		{
			return ZombieSavePoint;
		}
	}
}