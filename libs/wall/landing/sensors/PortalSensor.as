package landing.sensors
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;

	import landing.game.mainGame.CollisionGroup;

	public class PortalSensor extends EventDispatcher implements ISensor
	{
		static private const TELEPORT_DELAY:int = 1 * 1000;

		private var fixture:b2Fixture = null;
		private var hero:wHero = null;
		private var lastTeleportTime:int = 0;

		public function PortalSensor(fixture:b2Fixture):void
		{
			this.fixture = fixture;
			this.fixture.SetUserData(this);
		}

		public function beginContact(contact:b2Contact):void
		{
			if (getTimer() - this.lastTeleportTime < TELEPORT_DELAY)
				return;

			var hero:wHero = getHero(contact);
			if (hero.id != WallShadow.SELF_ID)
				return;

			this.lastTeleportTime = getTimer();

			dispatchEvent(new PortalSensorEvent(PortalSensorEvent.CONTACT, hero));
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function teleport(hero:wHero):void
		{
			if (getTimer() - this.lastTeleportTime < TELEPORT_DELAY)
				return;

			this.lastTeleportTime = getTimer();
			this.hero = hero;
		}

		public function doTeleport():void
		{
			if (this.hero == null)
				return;

			var pos:b2Vec2 = this.position.Copy();
			pos.Add(new b2Vec2(22.5 / WallShadow.PIXELS_TO_METRE, 22.5 / WallShadow.PIXELS_TO_METRE));

			this.hero.position = pos;
			this.hero.sendLocation(Keyboard.UP);
			this.hero.dispatchEvent(new Event(wHero.EVENT_BREAK_JOINT));
			this.hero = null;
		}

		public function dispose():void
		{
			var view:DisplayObject = this.fixture.GetBody().GetUserData();

			if (view && view.parent != null)
				view.parent.removeChild(view);

			removeBody();
		}

		public function removeBody():void
		{
			this.fixture.GetBody().GetWorld().DestroyBody(this.fixture.GetBody());
		}

		private function getHero(contact:b2Contact):wHero
		{
			if (contact.GetFixtureA().GetFilterData().categoryBits & CollisionGroup.HERO_CATEGORY)
				return contact.GetFixtureA().GetBody().GetUserData();
			return contact.GetFixtureB().GetBody().GetUserData();
		}

		private function get position():b2Vec2
		{
			return this.fixture.GetBody().GetPosition();
		}
	}
}