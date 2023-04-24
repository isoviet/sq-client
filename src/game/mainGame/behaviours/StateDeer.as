package game.mainGame.behaviours
{
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Vec2;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StateDeer extends HeroState
	{
		private var effect: ParticlesEffect;

		public function StateDeer(time:Number)
		{
			super(time);
		}

		override public function updatePhysic(timestep:Number):void
		{
			super.update(timestep);

			var velocity:b2Vec2 = this.hero.velocity;

			velocity.MulM(this.hero.body.GetTransform().R.GetInverse(new b2Mat22));
			velocity.y = -2;
			velocity.MulM(this.hero.body.GetTransform().R);

			this.hero.body.SetLinearVelocity(velocity);
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.climbing = false;
				this.hero.disableEffect(CollectionEffects.EFFECT_DEER);
				this.effect = null;
			}
			else
			{
				this.effect = value.applyEffect(CollectionEffects.EFFECT_DEER);
				value.climbing = true;
			}

			super.hero = value;
		}
	}
}