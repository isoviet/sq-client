package game.mainGame.gameDesertNet
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.SquirrelCollection;
	import game.mainGame.entity.IWaterSource;

	public class ThirstController
	{
		static public const UPDATE_RATE:int = 500;

		static public const SHAMAN_AURA_SIZE:int = 240;
		static public const FOUNTAIN_AURA_SIZE:int = 150;

		private var timer:Timer = null;
		private var squirrels:SquirrelCollection = null;

		private var waterSources:Array = [];

		public function ThirstController(squirrels:SquirrelCollection):void
		{
			this.squirrels = squirrels;

			this.timer = new Timer(UPDATE_RATE);
			this.timer.addEventListener(TimerEvent.TIMER, update);
		}

		public function add(waterSource:*):void
		{
			if (this.waterSources.indexOf(waterSource) != -1)
				return;

			this.waterSources.push(waterSource);
		}

		public function remove(waterSource:*):void
		{
			var index:int = this.waterSources.indexOf(waterSource);

			if (index == -1)
				return;

			this.waterSources.splice(index, 1);
		}

		public function set active(value:Boolean):void
		{
			if (value)
			{
				this.timer.reset();
				this.timer.start();
			}
			else
				this.timer.stop();
		}

		public function dispose():void
		{
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER, update);

			this.waterSources = null;
		}

		private function update(e:TimerEvent):void
		{
			var shaman:HeroDesert = this.squirrels.getShamans()[0];

			if (!Hero.selfAlive || Hero.self.shaman || Hero.self.isHare)
				return;

			var isThirsty:Boolean = true;
			if (shaman)
				isThirsty = (countDistance(Hero.self, shaman) > SHAMAN_AURA_SIZE);

			for each (var waterSource:IWaterSource in this.waterSources)
			{
				if (!isThirsty)
					break;
				isThirsty = isThirsty && (countDistance(Hero.self, waterSource) > waterSource.waterAuraSize);
			}

			(Hero.self as HeroDesert).thirsty = isThirsty;
		}

		private function countDistance(object1:*, object2:*):Number
		{
			var distance:b2Vec2 = object1.position.Copy();
			distance.Subtract(object2.position.Copy());

			return distance.Length() * Game.PIXELS_TO_METRE;
		}
	}
}