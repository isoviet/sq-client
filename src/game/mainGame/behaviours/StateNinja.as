package game.mainGame.behaviours
{
	import Box2D.Dynamics.b2FilterData;

	import game.mainGame.CollisionGroup;

	public class StateNinja extends HeroState
	{
		public function StateNinja(time:Number)
		{
			super(time);
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
				apply(this.hero, false);
			else
				apply(value, true);

			super.hero = value;
		}

		protected function apply(hero:Hero, value:Boolean):void
		{
			var mainFilter:b2FilterData = hero.mainFixture.GetFilterData();
			mainFilter.categoryBits = (value ? mainFilter.categoryBits | CollisionGroup.HERO_NINJA : mainFilter.categoryBits & ~CollisionGroup.HERO_NINJA);
			mainFilter.maskBits = (value ? mainFilter.maskBits | CollisionGroup.HERO_NINJA_CLOUD : mainFilter.maskBits & ~CollisionGroup.HERO_NINJA_CLOUD);
			hero.mainFixture.SetFilterData(mainFilter);

			var sensorFilter:b2FilterData = hero.footSensorFixture.GetFilterData();
			sensorFilter.categoryBits = (value ? sensorFilter.categoryBits | CollisionGroup.HERO_NINJA : sensorFilter.categoryBits & ~CollisionGroup.HERO_NINJA);
			sensorFilter.maskBits = (value ? sensorFilter.maskBits | CollisionGroup.HERO_NINJA_CLOUD : sensorFilter.maskBits & ~CollisionGroup.HERO_NINJA_CLOUD);
			hero.footSensorFixture.SetFilterData(sensorFilter);
		}
	}
}