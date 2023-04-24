package game.mainGame.entity.editor
{
	import game.mainGame.entity.shaman.OneWayBalk;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class OneWayWildBalk extends OneWayBalk
	{
		private var collectionEffect:CollectionEffects;
		private var effect:ParticlesEffect;

		public function OneWayWildBalk()
		{
			super();

			this.view.y -= 10;

			this.collectionEffect = CollectionEffects.instance;
			this.effect = collectionEffect.getEffectByName(CollectionEffects.EFFECT_WILD_WAY);

			this.effect.view.visible = true;
			this.effect.view.rotation = 90 * Game.D2R;
			this.effect.view.y = -15;
			this.effect.start();

			addChildStarling(this.effect.view);
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.effect && this.collectionEffect)
			{
				this.effect.stop();
				this.collectionEffect.removeEffect(this.effect);
				this.effect = null;
			}
		}

		override protected function get imageClass():Class
		{
			return OneWayWildBalkImg;
		}
	}
}