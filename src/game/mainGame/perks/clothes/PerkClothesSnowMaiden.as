package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	import game.mainGame.perks.clothes.base.PerkClothesAddView;

	public class PerkClothesSnowMaiden extends PerkClothesAddView
	{
		public function PerkClothesSnowMaiden(hero:Hero)
		{
			super(hero);
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override protected function createView():MovieClip
		{
			var answer:MovieClip = new PerkSnowMaidenView();
			answer.scaleX = answer.scaleY = 0.7;
			answer.y -= 60;
			answer.addFrameScript(answer.totalFrames - 1, function():void
			{
				answer.gotoAndPlay(16);
			});
			return answer;
		}
	}
}