package clans
{
	import flash.events.EventDispatcher;

	public class PerkTotems extends EventDispatcher
	{
		protected var totemId:int = -1;
		protected var hero:Hero = null;

		public var bonus:int = 0;

		public function PerkTotems(hero:Hero, bonus:int):void
		{
			this.hero = hero;
			this.bonus = bonus;
			super();
		}

		public function get id():int
		{
			return this.totemId;
		}

		public function dispose():void
		{
			this.hero = null;
		}
	}
}