package game.mainGame.perks.clothes.base
{
	import flash.display.MovieClip;

	import game.mainGame.perks.clothes.PerkClothes;

	public class PerkClothesAddView extends PerkClothes
	{
		protected var view:MovieClip = null;

		public function PerkClothesAddView(hero:Hero)
		{
			super(hero);
		}

		protected function createView():MovieClip
		{
			return null;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero)
				return;
			this.view = createView();
			this.hero.heroView.addChild(this.view);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;
			if (this.view && this.hero.heroView.contains(this.view))
				this.hero.heroView.removeChild(this.view);
			this.view = null;
		}
	}
}