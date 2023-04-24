package game.mainGame.behaviours
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class StateChaos extends HeroState
	{
		static private const DISTANCE:Number = 20;
		static private const HALF_DISTANCE:Number = DISTANCE >> 1;

		protected var animation:MovieClip = null;
		protected var zoneRect:Rectangle = null;

		public function StateChaos(time:Number)
		{
			super(time);

			this.animation = new PerkKickMovie();
			this.animation.y = -60;
		}

		override public function update(timeStep:Number):void
		{
			super.update(timeStep);

			if (!this.zoneRect || !this.hero)
				return;
			var pos:Point = this.hero.getPosition();
			if (pos.x > zoneRect.right)
			{
				this.hero.moveRight(false);
				this.hero.moveLeft(true);
			}
			else if (pos.x < zoneRect.left)
			{
				this.hero.moveLeft(false);
				this.hero.moveRight(true);
			}
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.isStoped = false;
				if (this.hero.heroView.contains(this.animation))
					this.hero.heroView.removeChild(this.animation);

				this.hero.moveLeft(false);
				this.hero.moveRight(false);
			}
			else
			{
				value.heroView.addChild(this.animation);
				value.isStoped = true;

				var pos:Point = value.getPosition();
				this.zoneRect = new Rectangle(pos.x - HALF_DISTANCE, pos.y - HALF_DISTANCE, DISTANCE, DISTANCE);

				value.moveRight(false);
				value.moveLeft(true);
			}

			super.hero = value;
		}
	}
}