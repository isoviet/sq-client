package landing.sensors
{
	import flash.events.EventDispatcher;

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;

	import landing.game.mainGame.CollisionGroup;
	import landing.sensors.events.DetectHeroEvent;

	public class HeroDetector extends EventDispatcher implements ISensor
	{
		private var fixture:b2Fixture = null;

		public function HeroDetector(fixture:b2Fixture):void
		{
			this.fixture = fixture;
			this.fixture.SetUserData(this);
		}

		public function beginContact(contact:b2Contact):void
		{
			onContact(contact);
		}

		public function endContact(contact:b2Contact):void
		{
			onContact(contact);
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			contact.SetEnabled(false);
		}

		private function getHero(contact:b2Contact):wHero
		{
			if (contact.GetFixtureA().GetFilterData().categoryBits & CollisionGroup.HERO_CATEGORY)
				return contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetFilterData().categoryBits & CollisionGroup.HERO_CATEGORY)
				return contact.GetFixtureB().GetBody().GetUserData();
			return null;
		}

		private function onContact(contact:b2Contact):void
		{
			var hero:wHero = getHero(contact);
			if (!(hero))
				return;

			dispatchEvent(new DetectHeroEvent(hero));
		}
	}
}