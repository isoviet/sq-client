package particles.effects
{
	import particles.ParticleBlock;

	public interface IParticleEffect
	{
		function apply(particle:ParticleBlock, step:Number, params:* = null):void
	}
}