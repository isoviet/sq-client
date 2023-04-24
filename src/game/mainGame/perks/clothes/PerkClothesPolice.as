package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	import game.mainGame.perks.clothes.base.PerkClothesAddView;

	public class PerkClothesPolice extends PerkClothesAddView
	{
		public function PerkClothesPolice(hero:Hero):void
		{
			super(hero);

			this.activateSound = "police";
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override protected function createView():MovieClip
		{
			var answer:MovieClip = new SirenCreate();
			answer.y -= 60;
			return answer;
		}
	}
}