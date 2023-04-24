package particles
{
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import particles.effects.IParticleEffect;

	import utils.starling.StarlingAdapterSprite;

	public class ParticleBlock extends StarlingAdapterSprite implements IParticle
	{
		private var params:Dictionary = new Dictionary();
		private var effects:Array = [];

		public var velocity:Point = new Point(0, 0);
		public var torque:Number = 0;

		public var timeToLive:Number;

		public var frozen:Boolean = false;

		public function ParticleBlock():void {}

		public function addEffect(effect:IParticleEffect, params:* = null):void
		{
			this.params[effect] = params;
			this.effects.push(effect);
		}

		public function update(step:Number):void
		{
			if (!frozen)
			{
				updateParams(step);
			}

			applyEffects(step);

			this.timeToLive -= step;
		}

		public function get garbage():Boolean
		{
			return this.timeToLive < 0;
		}

		private function updateParams(step:Number):void
		{
				this.rotation += this.torque * step;

				this.x += this.velocity.x * step;
				this.y += this.velocity.y * step;
		}

		private function applyEffects(step:Number):void
		{
			for each(var effect:IParticleEffect in this.effects)
				effect.apply(this, step, this.params[effect]);
		}
	}
}