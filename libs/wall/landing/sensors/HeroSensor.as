package landing.sensors
{
	import flash.events.EventDispatcher;

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;

	import landing.game.mainGame.entity.IGameObject;

	public class HeroSensor extends EventDispatcher implements ISensor
	{
		private var fixture:b2Fixture = null;

		public var contactsCount:int = 0;
		public var lastContact:IGameObject = null;

		public function HeroSensor(fixture:b2Fixture):void
		{
			this.contactsCount = 0;
			this.fixture = fixture;
			this.fixture.SetUserData(this);
		}

		public function reset():void
		{
			this.contactsCount = 0;
		}

		public function get onFloor():Boolean
		{
			return (this.contactsCount > 0);
		}

		public function beginContact(contact:b2Contact):void
		{
			if (contact.GetFixtureA() == this.fixture)
				this.lastContact = contact.GetFixtureB().GetBody().GetUserData();
			else
				this.lastContact = contact.GetFixtureA().GetBody().GetUserData();

			this.contactsCount++;
		}

		public function endContact(contact:b2Contact):void
		{
			this.contactsCount--;
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			contact.SetEnabled(false);
		}
	}
}