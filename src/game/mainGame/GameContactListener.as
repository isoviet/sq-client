package game.mainGame
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;

	public class GameContactListener extends b2ContactListener
	{
		private var world:b2World;

		public function GameContactListener(world:b2World):void
		{
			this.world = world;
		}

		override public function BeginContact(contact:b2Contact):void
		{
			var data0:* = contact.GetFixtureA().GetUserData();
			var data1:* = contact.GetFixtureB().GetUserData();

			if (data0 is ISensor)
				data0.beginContact(contact);

			if (data1 is ISensor)
				data1.beginContact(contact);
		}

		override public function EndContact(contact:b2Contact):void
		{
			var data0:* = contact.GetFixtureA().GetUserData();
			var data1:* = contact.GetFixtureB().GetUserData();

			if (data0 is ISensor)
				data0.endContact(contact);

			if (data1 is ISensor)
				(contact.GetFixtureB().GetUserData()).endContact(contact);
		}

		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			var data0:* = contact.GetFixtureA().GetUserData();
			var data1:* = contact.GetFixtureB().GetUserData();

			if (data0 is ISensor)
				data0.postSolve(contact, impulse);

			if (data1 is ISensor)
				data1.postSolve(contact, impulse);
		}

		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var data0:* = contact.GetFixtureA().GetUserData();
			var data1:* = contact.GetFixtureB().GetUserData();

			var body0:* = contact.GetFixtureA().GetBody().GetUserData();
			var body1:* = contact.GetFixtureB().GetBody().GetUserData();

			if (body0 is GameBody && body1 is GameBody && (body0).fixed && (body1).fixed)
			{
				contact.SetEnabled(false);
				return;
			}

			if (data0 is ISensor)
				data0.preSolve(contact, oldManifold);

			if (data1 is ISensor)
				data1.preSolve(contact, oldManifold);
		}
	}
}