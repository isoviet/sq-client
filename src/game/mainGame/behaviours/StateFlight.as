package game.mainGame.behaviours
{
	import Box2D.Common.Math.b2Mat22;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StateFlight extends HeroState implements IStateActive
	{
		private var power:Number = 0;
		private var _active:Boolean = false;
		private var effect: ParticlesEffect;

		public function StateFlight(time:Number, power:Number)
		{
			super(time);

			this.power = power;
		}

		public function set active(value:Boolean):void
		{
			if (value == this._active)
				return;
			this._active = value;

			if (value)
			{
				this.effect = this.hero.applyEffect(CollectionEffects.EFFECT_ALTRONE);
				this.effect.additionAngle = Math.PI * 0.5;
			}
			else
			{
				this.hero.disableEffect(CollectionEffects.EFFECT_ALTRONE);
				this.effect = null;
			}
		}

		override public function set hero(value:Hero):void
		{
			if (value == null)
				this.active = false;
			super.hero = value;
		}

		public function get active():Boolean
		{
			return this._active;
		}

		override public function update(timestep:Number):void
		{
			super.update(timestep);

			if (!this.active)
				return;
			//check
			this.hero.velocity.MulM(this.hero.body.GetTransform().R.GetInverse(new b2Mat22));
			this.hero.velocity.y = -this.power;
			this.hero.velocity.MulM(this.hero.body.GetTransform().R);
			this.hero.body.SetLinearVelocity(this.hero.velocity);
		}
	}
}