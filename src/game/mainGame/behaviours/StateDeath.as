package game.mainGame.behaviours
{
	import flash.display.MovieClip;

	public class StateDeath extends HeroState
	{
		protected var animation:MovieClip = null;

		public function StateDeath(time:Number)
		{
			super(time);

			this.animation = new PerkDeathView();
			this.animation.y = -75;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				if (this.hero.heroView.contains(this.animation))
					this.hero.heroView.removeChild(this.animation);
			}
			else
			{
				value.heroView.addChild(this.animation);
			}

			super.hero = value;
		}
	}
}