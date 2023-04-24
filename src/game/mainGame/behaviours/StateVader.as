package game.mainGame.behaviours
{
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Vec2;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StateVader extends HeroState
	{
		private var power:Number = 0;
		private var slowPower:Number = 0;

		private var effect:ParticlesEffect;

		public function StateVader(time:Number, power:Number, slowPower:Number)
		{
			super(time);

			this.power = power;
			this.slowPower = slowPower;
		}

		override public function updatePhysic(timestep:Number):void
		{
			super.update(timestep);

			var velocity:b2Vec2 = this.hero.velocity;
			velocity.x *= this.slowPower;

			velocity.MulM(this.hero.body.GetTransform().R.GetInverse(new b2Mat22));
			velocity.y = -this.power;
			velocity.MulM(this.hero.body.GetTransform().R);

			this.hero.body.SetLinearVelocity(velocity);
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.disableEffect(CollectionEffects.EFFECT_VADER);
				this.effect = null;
			}
			else
			{
				this.effect = value.applyEffect(CollectionEffects.EFFECT_VADER);
			}

			super.hero = value;
		}
	}
}