package controllers
{
	import utils.InstanceCounter;

	public class ControllerHero
	{
		protected var hero:IHero = null;
		protected var _active:Boolean = true;

		public var stoped:Boolean = false;

		public function ControllerHero(hero:IHero):void
		{
			InstanceCounter.onCreate(this);
			this.hero = hero;
		}

		public function set active(value:Boolean):void
		{
			this._active = value;
		}

		public function remove():void
		{
			InstanceCounter.onDispose(this);
			this.hero = null;
		}
	}
}