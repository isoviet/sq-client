package game.mainGame.behaviours
{
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StateOrc extends HeroState
	{
		static public const BOOST:Number = 15;
		static public const BOOST_MAX:Number = 15;

		private var direct:Boolean = false;
		private var speedBonus:Number = 0;

		private var effect:ParticlesEffect;

		public function StateOrc(time:Number, direct:Boolean)
		{
			super(time);

			this.direct = direct;
		}

		override public function update(timestep:Number):void
		{
			super.update(timestep);

			this.hero.moveLeft(this.direct);
			this.hero.moveRight(!this.direct);

			if (this.speedBonus >= BOOST_MAX)
				return;
			var dSpeed:Number = timestep * BOOST;
			this.hero.runSpeed += dSpeed;
			this.speedBonus += dSpeed;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.runSpeed -= this.speedBonus;
				this.hero.moveLeft(false);
				this.hero.moveRight(false);

				this.hero.disableEffect(CollectionEffects.EFFECT_ORC);
				this.effect = null;
			}
			else
			{
				this.effect = value.applyEffect(CollectionEffects.EFFECT_ORC);
			}
			super.hero = value;
		}
	}
}