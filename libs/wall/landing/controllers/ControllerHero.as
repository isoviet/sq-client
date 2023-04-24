package landing.controllers
{
	public class ControllerHero
	{
		protected var hero:IHero = null;
		protected var _active:Boolean = true;

		public function ControllerHero(hero:IHero):void
		{
			this.hero = hero;
		}

		public function set active(value:Boolean):void
		{
			this._active = value;
		}

		public function setHero(hero:IHero):void
		{
			this.hero = hero;
		}

		public function remove():void
		{}
	}
}