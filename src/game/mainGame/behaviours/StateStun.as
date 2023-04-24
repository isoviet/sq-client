package game.mainGame.behaviours
{
	import flash.display.MovieClip;

	public class StateStun extends HeroState
	{
		protected var animation:MovieClip = null;

		public function StateStun(time:Number)
		{
			super(time);

			this.animation = new PerkKickMovie();
			this.animation.y = -60;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.isStoped = false;
				if (this.hero.heroView.contains(this.animation))
					this.hero.heroView.removeChild(this.animation);
			}
			else
			{
				value.heroView.addChild(this.animation);
				value.isStoped = true;
			}

			super.hero = value;
		}
	}
}