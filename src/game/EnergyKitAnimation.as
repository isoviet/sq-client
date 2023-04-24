package game
{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;

	import game.BaseCollectionHeroAnimation;

	import utils.starling.StarlingAdapterMovie;

	public class EnergyKitAnimation extends BaseCollectionHeroAnimation
	{
		private var icon: StarlingAdapterMovie;

		public function EnergyKitAnimation()
		{
			super();
		}

		public function set view(value:MovieClip):void
		{
			if (this.icon)
				this.icon.removeFromParent();

			this.icon = new StarlingAdapterMovie(value);
		}

		override protected function setIcon(itemId:int, kind:int):void
		{
			if (itemId || kind) {/*unused*/}

			this.iconImage = this.icon;
			this.iconImage.scaleX = this.iconImage.scaleY = 0.8;
			//this.iconImage.filters = [new GlowFilter(0xFFCC33, 1, 4, 4, 3.08)];
		}
	}
}