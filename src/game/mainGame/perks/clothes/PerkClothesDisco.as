package game.mainGame.perks.clothes
{
	public class PerkClothesDisco extends PerkClothesTransformation
	{
		public function PerkClothesDisco(hero:Hero):void
		{
			super(hero);
			this.animation = DiscoPerkView;
		}
	}
}