package game.mainGame.behaviours
{
	import Box2D.Common.Math.b2Mat22;

	public class StateRabbit extends HeroState
	{
		private var power:Number = 0;

		public function StateRabbit(time:Number, power:Number)
		{
			super(time);

			this.power = power;
		}

		override public function update(timestep:Number):void
		{
			super.update(timestep);

			if (!this.hero || !this.hero.onFloor)
				return;

			this.hero.velocity.MulM(this.hero.body.GetTransform().R.GetInverse(new b2Mat22));
			this.hero.velocity.y = -this.power;
			this.hero.velocity.MulM(this.hero.body.GetTransform().R);
			this.hero.body.SetLinearVelocity(this.hero.velocity);
		}
	}
}