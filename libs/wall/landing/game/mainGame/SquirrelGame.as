package landing.game.mainGame
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	public class SquirrelGame extends Sprite
	{
		static private const FIXED_TIMESTEP:Number = 1 / 60;
		static private const VELOCITY_INTERATION:int = 10;
		static private const POSITION_INTERATION:int = 8;
		static private const USE_FIXED_TIMESTEP:Boolean = true;

		private var lastUpdate:int;
		private var elapsedTime:Number = 0;

		protected var _simulate:Boolean = false;

		public var world:b2World = new b2World(new b2Vec2(0, 100), true);
		public var map:GameMap;
		public var squirrels:SquirrelCollection;
		public var cast:Cast;

		public function SquirrelGame():void
		{
			this.world.userData = this;

			addChild(this.map);
			addChild(this.squirrels);
			addChild(this.cast);

			this.world.SetContactListener(new GameContactListener);
			this.world.SetContactFilter(new ContactFilter);
		}

		public function getShamanTools():Array
		{
			return this.map.shamanTools;
		}

		protected function get simulate():Boolean
		{
			return this._simulate;
		}

		protected function set simulate(value:Boolean):void
		{
			if (this._simulate == value)
				return;
			this._simulate = value;

			if (!value)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdate, false);
				return;
			}

			this.lastUpdate = getTimer();
			this.elapsedTime = 0;

			addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);

			this.map.build(world);
		}

		private function onUpdate(e:Event):void
		{
			var timeStep:Number = (getTimer() - this.lastUpdate) / 1000
			this.lastUpdate = getTimer();
			update(timeStep);
		}

		public function dispose():void
		{
			this.map.dispose();
			this.map = null;

			this.cast.dispose();
			this.cast = null;

			this.squirrels.dispose();
			this.squirrels = null;

			this.world.SetDestructionListener(null);
			this.world.SetContactListener(null);
			this.world.userData = null;

			this.simulate = false;
			this.world = null;

			while (this.numChildren > 0)
				removeChildAt(0);
		}

		public function update(timeStep:Number):void
		{
			if (!this.simulate)
				return;

			this.elapsedTime += timeStep;

			var updateStartTime:int = getTimer();
			var simulateTimeStep:Number = USE_FIXED_TIMESTEP ? FIXED_TIMESTEP : elapsedTime;

			while (this.elapsedTime >= simulateTimeStep)
			{
				this.world.Step(simulateTimeStep, VELOCITY_INTERATION, POSITION_INTERATION);
				this.elapsedTime -= simulateTimeStep;
			}

			var boxTime:int = getTimer();

			this.world.ClearForces();
			this.map.update(timeStep);
			this.squirrels.update(timeStep);
			this.cast.update(timeStep);
		}
	}
}