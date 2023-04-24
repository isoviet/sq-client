package utils.starling.particleSystem
{
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;

	import utils.starling.extensions.FFParticleSystem;
	import utils.starling.extensions.SystemOptions;

	public class ParticlesEffect
	{
		private var particleSystem:FFParticleSystem;
		private var systemOptions:SystemOptions;
		public var additionAngle:Number = 0;

		public function ParticlesEffect(bmdOrTexture: *, configEffect:String, atlasXML:String = null, params:Object = null)
		{
			var config:XML = XML(configEffect);
			var atlas:XML = atlasXML ? XML(atlasXML) : null;
			var texture:Texture = bmdOrTexture is Texture ? bmdOrTexture : Texture.fromBitmapData(bmdOrTexture);

			systemOptions = SystemOptions.fromXML(config, texture, atlas);

			if (params)
				systemOptions = systemOptions.appendFromObject(params);

			particleSystem = new FFParticleSystem(systemOptions);
			particleSystem.smoothing = TextureSmoothing.NONE;
			particleSystem.touchable = false;
		}

		public function get view():FFParticleSystem
		{
			return particleSystem;
		}

		public function set view(value:FFParticleSystem): void
		{
			particleSystem = value;
		}

		public function pause(): void
		{
			particleSystem.pause();
		}

		public function stop(): void
		{
			if (particleSystem)
			{
				particleSystem.stop();
				Starling.juggler.remove(particleSystem);
			}
		}

		public function start(duration: Number = 0): void
		{
			if (particleSystem)
			{
				particleSystem.start(duration);
				Starling.juggler.add(particleSystem);
			}
		}

		public function removeFromParent(dispose: Boolean = true): void
		{
			stop();
			particleSystem.removeFromParent(dispose);

			if (dispose)
			{
				particleSystem.dispose();
				particleSystem = null;
			}
		}
	}
}