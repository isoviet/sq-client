package game.mainGame.behaviours
{
	import flash.display.MovieClip;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.simple.Element;
	import sensors.events.DetectHeroEvent;

	public class StateBearHoney extends HeroState
	{
		protected var animation:MovieClip = null;
		protected var radius:Number = 0;

		public function StateBearHoney(time:Number, radius:Number)
		{
			super(time);

			this.radius = radius;

			this.animation = new BearPerkAuraView();
			this.animation.x = -75;
			this.animation.y = -100;
		}

		override public function update(timestep:Number):void
		{
			super.update(timestep);

			if (!this.hero)
				return;
			for each (var element:Element in this.hero.game.map.elements)
			{
				if (element.sensor == null)
					continue;
				var point:b2Vec2 = element.position.Copy();
				point.Subtract(this.hero.position);
				if (point.Length() > this.radius)
					continue;
				element.sensor.dispatchEvent(new DetectHeroEvent(this.hero));
			}
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