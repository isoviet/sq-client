package particles.effects
{
	import particles.ParticleBlock;

	public class FadeAlphaEffect implements IParticleEffect
	{
		public function FadeAlphaEffect():void{}

		public function apply(particle:ParticleBlock, step:Number, params:*= null):void
		{
			if ('fadeSpeed' in params)
				particle.alpha -= params['fadeSpeed'] * step;
		}
	}

}