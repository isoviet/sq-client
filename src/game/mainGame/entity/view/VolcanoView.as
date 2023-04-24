package game.mainGame.entity.view
{
	import starling.animation.Tween;
	import starling.core.Starling;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class VolcanoView extends StarlingAdapterSprite
	{
		private var effectParticle:ParticlesEffect = null;
		private var view:StarlingAdapterSprite = null;

		private var lastEffects:Array = [];

		public function VolcanoView():void
		{
			this.view = new StarlingAdapterSprite(new VolcanoImage());
			addChildStarling(this.view);
		}

		public function deactive():void
		{
			this.effect = CollectionEffects.EFFECT_VOLCANO_DEACTIVE;
		}

		public function prepare():void
		{
			this.effect = CollectionEffects.EFFECT_VOLCANO_PREPARE;
		}

		public function active():void
		{
			this.effect = CollectionEffects.EFFECT_VOLCANO_ACTIVE;
		}

		private function set effect(value:String):void
		{
			if (this.effectParticle)
			{
				this.lastEffects.push(this.effectParticle);

				this.effectParticle.view.emissionRate = 0;

				var tween:Tween = new Tween(this.effectParticle.view, 1.5);
				tween.animate("alpha", 0);
				tween.onComplete = removeEffect;
				Starling.juggler.add(tween);
			}

			this.effectParticle = CollectionEffects.instance.getEffectByName(value);
			this.effectParticle.view.visible = true;
			this.effectParticle.view.x = 50;
			this.effectParticle.start();

			addChildStarlingAt(this.effectParticle.view, 0);
		}

		private function removeEffect():void
		{
			if (this.lastEffects.length == 0)
				return;
			var effect:ParticlesEffect = this.lastEffects.shift();
			if (!effect)
				return;
			effect.stop();
			CollectionEffects.instance.removeEffect(effect);
		}
	}
}