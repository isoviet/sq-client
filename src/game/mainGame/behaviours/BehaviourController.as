package game.mainGame.behaviours
{
	import flash.utils.Dictionary;

	public class BehaviourController
	{
		private var states:Dictionary = new Dictionary();
		private var hero:Hero = null;

		public function BehaviourController(hero:Hero):void
		{
			this.hero = hero;
		}

		public function addState(state:HeroState):void
		{
			var stateClass:Class = (state as Object).constructor as Class;
			if (stateClass in this.states)
				(this.states[stateClass] as HeroState).hero = null;
			state.hero = this.hero;
			this.states[stateClass] = state;
		}

		public function removeState(state:HeroState):void
		{
			var stateClass:Class = (state as Object).constructor as Class;
			if (!(stateClass in this.states))
				return;
			state.hero = null;
			delete this.states[stateClass];
		}

		public function getState(stateClass:Class):HeroState
		{
			if (stateClass in this.states)
				return this.states[stateClass];
			return null;
		}

		public function update(timestep:Number):void
		{
			for each (var state:HeroState in this.states)
			{
				state.update(timestep);
				if (!state.ended)
					continue;
				state.hero = null;
				delete this.states[(state as Object).constructor as Class];
			}
		}

		public function updatePhysic(timestep:Number):void
		{
			for each (var state:HeroState in this.states)
				state.updatePhysic(timestep);
		}
	}
}