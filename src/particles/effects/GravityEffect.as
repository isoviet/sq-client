package particles.effects
{
	import particles.ParticleBlock;

	public class GravityEffect implements IParticleEffect
	{
		public function GravityEffect():void {}

		public function apply(particle:ParticleBlock, step:Number, params:* = null):void
		{
			if (particle.frozen)
				return;

			particle.velocity.x += params.gravity.x * step;
			particle.velocity.y += params.gravity.y * step;
		}
	}
}