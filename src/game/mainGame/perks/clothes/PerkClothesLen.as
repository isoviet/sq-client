package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	public class PerkClothesLen extends PerkClothes
	{
		private var view:MovieClip = null;

		public function PerkClothesLen(hero:Hero)
		{
			super(hero);

			this.view = new LenPerkView();
			this.activateSound = "guitar";
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.active)
				return;
			if (this.hero && this.hero.heroView.running)
				this.active = false;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.changeView(this.view);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.changeView();
		}
	}
}