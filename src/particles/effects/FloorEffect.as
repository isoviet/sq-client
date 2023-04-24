package particles.effects
{
	import flash.geom.Point;

	import particles.ParticleBlock;

	public class FloorEffect implements IParticleEffect
	{
		public function FloorEffect():void {}

		public function apply(particle:ParticleBlock, step:Number, params:* = null):void
		{
			if (particle.y <= params.height)
				return;

			if (!particle.frozen)
			{
				particle.frozen = true;
				particle.velocity = new Point(0, 0);
				particle.torque = 0;
			}

			if (!params.useFade)
				return;

			params.fadeDelay -= step;

			if (params.fadeDelay > 0)
				return;

			particle.alpha -= params.fadeSpeed * step;
		}
	}
}