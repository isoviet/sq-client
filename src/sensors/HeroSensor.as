package sensors
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;

	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IGhost;
	import game.mainGame.entity.IJumpable;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.simple.GameBody;

	import utils.SaltValue;

	public class HeroSensor extends EventDispatcher implements ISensor
	{
		private var fixture:b2Fixture = null;

		private var _contactsCount:SaltValue = new SaltValue(0);
		private var hero:Hero;
		private var contacts:Dictionary = new Dictionary(false);

		private var jumpableContacts:int = 0;

		public var lastContact:IGameObject = null;
		private var worldManifold:b2WorldManifold;
		private var _floorContactsObject: Dictionary = new Dictionary(false);

		public function HeroSensor(fixture:b2Fixture, hero:Hero):void
		{
			worldManifold = new b2WorldManifold();

			this._floorContactsObject = new Dictionary(false);
			this.contactsCount = 0;
			this.fixture = fixture;
			this.hero = hero;
			this.fixture.SetUserData(this);
		}

		public function reset():void
		{
			this.jumpableContacts = 0;
			this._floorContactsObject = new Dictionary(false);
			this.contactsCount = 0;
			contacts = new Dictionary(false);
		}

		public function get onFloor():Boolean
		{
			return (this.contactsCount != 0) && !this.hero.ghost;
		}

		public function get contactsCount():int
		{
			return Math.max(_contactsCount.value, 0);
		}

		public function set contactsCount(value:int):void
		{
			_contactsCount.value = Math.max(value, 0);
		}

		public function get canJump():Boolean
		{
			if (this.jumpableContacts > 0)
				return true;

			return floorContact;
		}

		private function get floorContact(): Boolean
		{
			for (var key:String in this._floorContactsObject)
				return true;

			return false;
		}

		public function beginContact(contact:b2Contact):void
		{
			var otherObject:* = contact.GetFixtureA().GetBody().GetUserData();
			if (otherObject == this.hero)
				otherObject = contact.GetFixtureB().GetBody().GetUserData();

			if ((otherObject is GameBody) && ((otherObject as GameBody).ghost || otherObject is IGhost))
				return;

			if ((otherObject is IPersonalObject) && ((otherObject as IPersonalObject).breakContact(this.hero.id)))
				return;

			if (this.hero.ghost)
				return;

			if (otherObject is IGameObject)
				this.lastContact = otherObject;

			if (otherObject is IJumpable)
				this.jumpableContacts++;

			contacts[contact] = otherObject;
			this.contactsCount++;

			var pointNormal:b2Vec2 = contact.GetManifold().m_localPlaneNormal;
			var angleNormal:Number = Math.abs(Math.atan2(pointNormal.y, pointNormal.x));
			var pointLocal:b2Vec2 = contact.GetManifold().m_localPoint;
			var angleLocal:Number = Math.abs(Math.atan2(pointLocal.y, pointLocal.x));

			if (angleNormal == 0 && angleLocal >= 1.5 || angleNormal == 0 && angleLocal == 0 ||
				angleLocal >= 1.5 && angleNormal >= 3 && this.hero.rotation != 0 ||
				this.hero.rotation != 0)
				this._floorContactsObject[contact] = otherObject;

			contact.GetWorldManifold(worldManifold);

			pointNormal = worldManifold.m_normal;
			angleNormal = Math.abs(Math.atan2(pointNormal.y, pointNormal.x));

			if (angleNormal >= Math.PI * 0.10 && angleNormal <= Math.PI * 0.90)
				this._floorContactsObject[contact] = otherObject;

			//playSoundWithContect(this.lastContact);
		}

		public function endContact(contact:b2Contact):void
		{
			if (this.contactsCount > 0 && contact in contacts)
			{
				if (contacts[contact] is IJumpable)
					this.jumpableContacts--;
				delete contacts[contact];
				this.contactsCount--;
			}

			if (contact in this._floorContactsObject)
				delete this._floorContactsObject[contact];
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			contact.SetEnabled(false);
		}

		public function dispose():void
		{
			this.fixture.SetUserData(null);
			this.fixture = null;
			this.lastContact = null;
		}
	}
}