package sensors
{
	import flash.events.EventDispatcher;

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;

	import sensors.events.DetectHeroEvent;

	public class HeroDetector extends EventDispatcher implements ISensor
	{
		private var fixture:b2Fixture = null;

		public var onDetect:Array = [];

		public function HeroDetector(fixture:b2Fixture):void
		{
			setFixture(fixture);
		}

		static private function getHero(contact:b2Contact):Hero
		{
			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				return contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				return contact.GetFixtureB().GetBody().GetUserData();
			return null;
		}

		public function setFixture(fixture:b2Fixture):void
		{
			this.fixture = fixture;
			this.fixture.SetUserData(this);
		}

		public function beginContact(contact:b2Contact):void
		{
			onContact(contact, DetectHeroEvent.BEGIN_CONTACT);
			var hero:Hero = getHero(contact);
			if (!hero)
				return;
			this.onDetect.push(hero);
		}

		public function endContact(contact:b2Contact):void
		{
			onContact(contact, DetectHeroEvent.END_CONTACT);
			var hero:Hero = getHero(contact);
			if (!hero)
				return;
			this.onDetect.splice(this.onDetect.indexOf(hero), 1);
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function onContact(contact:b2Contact, state:String):void
		{
			var hero:Hero = getHero(contact);
			if (hero == null)
				return;

			dispatchEvent(new DetectHeroEvent(hero, true, state));
		}
	}
}