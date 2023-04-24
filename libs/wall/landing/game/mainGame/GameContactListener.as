package landing.game.mainGame
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;

	import landing.game.mainGame.entity.simple.GameBody;
	import landing.sensors.ISensor;

	public class GameContactListener extends b2ContactListener
	{
		override public function BeginContact(contact:b2Contact):void
		{
			if (contact.GetFixtureA().GetUserData() is ISensor)
				(contact.GetFixtureA().GetUserData() as ISensor).beginContact(contact);

			if (contact.GetFixtureB().GetUserData() is ISensor)
				(contact.GetFixtureB().GetUserData() as ISensor).beginContact(contact);
		}

		override public function EndContact(contact:b2Contact):void
		{
			if (contact.GetFixtureA().GetUserData() is ISensor)
				(contact.GetFixtureA().GetUserData() as ISensor).endContact(contact);

			if (contact.GetFixtureB().GetUserData() is ISensor)
				(contact.GetFixtureB().GetUserData() as ISensor).endContact(contact);
		}

		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (contact.GetFixtureA().GetUserData() is ISensor)
				(contact.GetFixtureA().GetUserData() as ISensor).postSolve(contact, impulse);

			if (contact.GetFixtureB().GetUserData() is ISensor)
				(contact.GetFixtureB().GetUserData() as ISensor).postSolve(contact, impulse);
		}

		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var body0:* = contact.GetFixtureA().GetBody().GetUserData();
			var body1:* = contact.GetFixtureB().GetBody().GetUserData();

			if (body0 is GameBody && body1 is GameBody && (body0 as GameBody).fixed && (body1 as GameBody).fixed)
				contact.SetEnabled(false);

			if (contact.GetFixtureA().GetUserData() is ISensor)
				(contact.GetFixtureA().GetUserData() as ISensor).preSolve(contact, oldManifold);

			if (contact.GetFixtureB().GetUserData() is ISensor)
				(contact.GetFixtureB().GetUserData() as ISensor).preSolve(contact, oldManifold);
		}
	}
}