package game.mainGame.behaviours
{
	import flash.display.MovieClip;

	public class StateDruid extends HeroState
	{
		protected var animation:MovieClip = null;

		public function StateDruid(time:Number)
		{
			super(time);

			this.animation = new DruidPerkView();
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