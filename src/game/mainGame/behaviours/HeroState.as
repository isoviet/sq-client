package game.mainGame.behaviours
{
	public class HeroState
	{
		protected var _time:Number = 0;
		protected var permanent:Boolean = false;

		protected var _hero:Hero = null;

		public function HeroState(time:Number):void
		{
			this._time = time;
			this.permanent = this.time == 0;
		}

		public function get time():Number
		{
			return this._time;
		}

		public function get ended():Boolean
		{
			return this._time <= 0 && !this.permanent;
		}

		public function updatePhysic(timestep:Number):void
		{}

		public function update(timestep:Number):void
		{
			if (!this.permanent)
				this._time -= timestep;
		}

		public function set hero(value:Hero):void
		{
			this._hero = value;
		}

		public function get hero():Hero
		{
			return this._hero;
		}
	}
}