package particles
{
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterSprite;

	public class ParticleEngine extends StarlingAdapterSprite
	{
		static private const GC_TIMEOUT:int = 1;

		private var _particles:Dictionary = new Dictionary();

		private var lastGC:int = -1;

		public function ParticleEngine():void
		{}

		public function addParticle(particle:IParticle):void
		{
			this._particles[particle] = particle;
			if (particle is IStarlingAdapter)
				addChildStarling(particle as StarlingAdapterSprite);
		}

		public function updateAll(step:Number):void
		{
			for each (var particle:IParticle in this._particles)
				particle.update(step);
			collectGarbage();
		}

		public function clear():void
		{
			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			this._particles = new Dictionary();
		}

		private function collectGarbage():void
		{
			if (getTimer() - this.lastGC < GC_TIMEOUT)
				return;

			this.lastGC = getTimer();

			for each (var particle:IParticle in this._particles)
			{
				if (!particle.garbage)
					continue;

				delete this._particles[particle];

				if (particle is IStarlingAdapter)
					removeChildStarling(particle as StarlingAdapterSprite);
			}
		}
	}
}