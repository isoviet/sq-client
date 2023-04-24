package game.mainGame.behaviours
{
	import flash.display.MovieClip;

	import Box2D.Common.Math.b2Vec2;

	public class StateTimeWarp extends HeroState
	{
		private var power:Number = 0;

		protected var animation:MovieClip = null;

		public function StateTimeWarp(time:Number, power:Number)
		{
			super(time);

			this.power = power;

			this.animation = new McTwistPerkView();
			this.animation.scaleX = this.animation.scaleY = 0.5;
			this.animation.y = -90;
			this.animation.x = -this.animation.width * 0.5;
		}

		override public function updatePhysic(timestep:Number):void
		{
			super.update(timestep);

			var velocity:b2Vec2 = this.hero.velocity;
			velocity.x *= this.power;
			if (velocity.y > 0)
				velocity.y *= this.power;
			this.hero.body.SetLinearVelocity(velocity);
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
				this.animation.play();
				value.heroView.addChild(this.animation);
			}

			super.hero = value;
		}
	}
}