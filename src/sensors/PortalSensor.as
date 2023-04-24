package sensors
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;

	import sounds.GameSounds;

	import utils.starling.IStarlingAdapter;

	public class PortalSensor extends EventDispatcher implements ISensor
	{
		static private const TELEPORT_DELAY:int = 200;
		static private const MAX_VELOCITY:Number = 1000;

		private var fixture:b2Fixture = null;
		private var heroes:Object = {};
		private var lastTeleportTime:Object = {};

		public var useDirection:Boolean;
		public var direction:Number;

		public function PortalSensor(fixture:b2Fixture):void
		{
			this.fixture = fixture;
			this.fixture.SetUserData(this);
		}

		public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = getHero(contact);

			if (hero.id != Game.selfId && hero.id > 0)
				return;

			if (!(hero.id in this.lastTeleportTime))
				this.lastTeleportTime[hero.id] = 0;

			if (getTimer() - this.lastTeleportTime[hero.id] < TELEPORT_DELAY)
				return;

			this.lastTeleportTime[hero.id] = getTimer();
			GameSounds.play('portal');

			dispatchEvent(new PortalSensorEvent(PortalSensorEvent.CONTACT, hero));
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function teleport(hero:Hero):void
		{
			if (!(hero.id in this.lastTeleportTime))
				this.lastTeleportTime[hero.id] = 0;

			if (getTimer() - this.lastTeleportTime[hero.id] < TELEPORT_DELAY)
				return;

			this.lastTeleportTime[hero.id] = getTimer();
			this.heroes[hero.id] = hero;
		}

		public function doTeleport():void
		{
			var pos:b2Vec2 = this.position.Copy();
			pos.Add(new b2Vec2(22.5 / Game.PIXELS_TO_METRE, 22.5 / Game.PIXELS_TO_METRE));

			for each(var hero:Hero in this.heroes)
			{
				if (useDirection)
				{
					var velocityLength:Number = Math.min(hero.velocity.Length(), MAX_VELOCITY);
					hero.velocity = new b2Vec2(Math.cos(this.direction) * velocityLength, Math.sin(this.direction) * velocityLength);
				}

				hero.position = pos;
				hero.sendLocation(Keyboard.UP);
				hero.dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));
				hero.dispatchEvent(new Event(Hero.EVENT_TELEPORT));
				delete this.heroes[hero.id];
			}
		}

		public function dispose():void
		{
			var view:*;

			if (this.fixture.GetBody().GetUserData() is IStarlingAdapter) {
				view = this.fixture.GetBody().GetUserData();
				if (view && view.parentStarling != null) {
					view.parentStarling.removeChildStarling(view);
				}
			} else {
				view = this.fixture.GetBody().GetUserData();
				if (view && view.parent != null)
					view.parent.removeChild(view);
			}

			removeBody();
		}

		public function removeBody():void
		{
			this.fixture.GetBody().GetWorld().DestroyBody(this.fixture.GetBody());
		}

		private function getHero(contact:b2Contact):Hero
		{
			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				return contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				return contact.GetFixtureB().GetBody().GetUserData();
			return null;
		}

		private function get position():b2Vec2
		{
			return this.fixture.GetBody().GetPosition();
		}
	}
}