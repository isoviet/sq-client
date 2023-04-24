package game.mainGame.perks.clothes
{
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.textures.TextureSmoothing;

	import utils.starling.extensions.Particle;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class PerkClothesAssassinSmoke extends PerkClothes
	{
		private var collectionEffect:CollectionEffects;
		private var effect:ParticlesEffect;

		public function PerkClothesAssassinSmoke(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_SMOKE;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero)
				return;

			this.collectionEffect = CollectionEffects.instance;

			if (this.effect)
				this.collectionEffect.removeEffect(this.effect);

			this.effect = collectionEffect.getEffectByName(CollectionEffects.EFFECTS_YELLOW_SMOKE, {'sortFunction': ageSortDesc});
			this.effect.view.visible = true;
			this.effect.view.smoothing = TextureSmoothing.TRILINEAR;
			this.effect.view.emitterX = this.hero.x;
			this.effect.view.emitterY = this.hero.y;
			this.effect.view.startSize = 650;
			this.effect.view.startSizeVariance = 650;
			this.effect.start();

			Hero.self.getStarlingView().parent.addChild(this.effect.view);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.effect)
			{
				var tween:Tween = new Tween(this.effect.view, 2, Transitions.EASE_IN);
				tween.animate("alpha", 0);
				tween.onComplete = removeEffect;
				Starling.juggler.add(tween);
			}
		}

		private function ageSortDesc(a:Particle, b:Particle):Number
		{
			if (a.active && b.active)
			{
				if (a.currentTime < b.currentTime)
					return 1;
				if (a.currentTime > b.currentTime)
					return -1;
			}
			else if (a.active && !b.active)
			{
				return -1;
			}
			else if (!a.active && b.active)
			{
				return 1;
			}
			return 0;
		}

		private function removeEffect():void
		{
			if (!this.effect)
				return;
			this.effect.stop();
			this.collectionEffect.removeEffect(this.effect);
			this.effect = null;
		}
	}
}