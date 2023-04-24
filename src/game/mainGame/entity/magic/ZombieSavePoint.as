package game.mainGame.entity.magic
{
	import game.mainGame.perks.clothes.PerkClothesFactory;

	public class ZombieSavePoint extends SavePointObject
	{
		public function ZombieSavePoint()
		{
			super(0, 10);

			this.perkCode = PerkClothesFactory.ZOMBIE;
		}

		override protected function get animation():Class
		{
			return ClothesPerkGrave1;
		}
	}
}