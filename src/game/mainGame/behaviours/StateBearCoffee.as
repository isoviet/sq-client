package game.mainGame.behaviours
{
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StateBearCoffee extends StateSpeed
	{
		private var effect:ParticlesEffect;

		public function StateBearCoffee(time:Number, bonus:Number)
		{
			super(time, bonus);
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.disableEffect(CollectionEffects.EFFECT_BEAR_COFFEE);
				this.effect = null;
			}
			else
			{
				this.effect = value.applyEffect(CollectionEffects.EFFECT_BEAR_COFFEE);
			}

			super.hero = value;
		}
	}
}