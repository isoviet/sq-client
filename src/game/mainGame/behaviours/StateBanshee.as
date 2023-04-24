package game.mainGame.behaviours
{
	import flash.events.Event;

	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.b2FilterData;

	import game.mainGame.ActiveBodiesCollector;
	import game.mainGame.CollisionGroup;
	import sensors.HeroDetector;

	public class StateBanshee extends HeroState
	{
		private var controller:b2ConstantAccelController;

		public function StateBanshee(time:Number)
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
			if (value)
			{
				var heroDetector:HeroDetector = null;
				for (var list:b2ContactEdge = hero.body.GetContactList(); list; list = list.next)
				{
					heroDetector = list.contact.GetFixtureA().GetUserData() as HeroDetector;
					if (!heroDetector)
						heroDetector = list.contact.GetFixtureB().GetUserData() as HeroDetector;
					if (heroDetector)
						heroDetector.endContact(list.contact);
				}
				ActiveBodiesCollector.removeBody(hero.body);
			}
			else
				ActiveBodiesCollector.addBody(hero.body);

			hero.dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));

			var mainFilter:b2FilterData = hero.mainFixture.GetFilterData();
			mainFilter.categoryBits = (!value ? mainFilter.categoryBits | CollisionGroup.HERO_CATEGORY : mainFilter.categoryBits & ~CollisionGroup.HERO_CATEGORY);
			mainFilter.maskBits = (!value ? mainFilter.maskBits | CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY : mainFilter.maskBits & ~CollisionGroup.OBJECT_CATEGORY & ~CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY);
			hero.mainFixture.SetFilterData(mainFilter);

			var sensorFilter:b2FilterData = hero.footSensorFixture.GetFilterData();
			sensorFilter.categoryBits = (!value ? sensorFilter.categoryBits | CollisionGroup.HERO_CATEGORY | CollisionGroup.HERO_SENSOR_CATEGORY : sensorFilter.categoryBits & ~CollisionGroup.HERO_CATEGORY & ~CollisionGroup.HERO_SENSOR_CATEGORY);
			sensorFilter.maskBits = (!value ? sensorFilter.maskBits | CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY : sensorFilter.maskBits & ~CollisionGroup.OBJECT_CATEGORY & ~CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY);
			hero.footSensorFixture.SetFilterData(sensorFilter);

			if (value)
			{
				this.controller = new b2ConstantAccelController();
				this.controller.A = hero.game.world.GetGravity().GetNegative();
				this.controller.AddBody(hero.body);
				hero.game.world.AddController(this.controller);
			}
			else if (this.controller)
			{
				hero.game.world.RemoveController(this.controller);
				this.controller.Clear();
				this.controller = null;
			}
		}
	}
}