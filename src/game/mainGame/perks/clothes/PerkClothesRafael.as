package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	import game.mainGame.perks.clothes.base.PerkClothesAddView;

	public class PerkClothesRafael extends PerkClothesAddView
	{
		private var movie:MovieClip = null;

		public function PerkClothesRafael(hero:Hero):void
		{
			super(hero);

			this.activateSound = "cowabunga";
		}

		override public function get activeTime():Number
		{
			return 5;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override protected function createView():MovieClip
		{
			var answer:MovieClip = new RafaelPerkView();
			return answer;
		}

		override protected function activate():void
		{
			super.activate();

			if (this.view)
				this.view.addFrameScript(this.view.totalFrames - 1, function():void
				{
					view.stop();
				});
		}
	}
}