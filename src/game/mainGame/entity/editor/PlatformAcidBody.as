package game.mainGame.entity.editor
{
	import flash.events.Event;

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;

	import game.mainGame.behaviours.StateDruid;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformAcidBody extends PlatformGroundBody implements ISensor
	{
		public function PlatformAcidBody():void
		{
			super();
		}

		override protected function get categoriesBitsGhost():uint
		{
			return this.categoriesBits;
		}

		public function beginContact(contact:b2Contact):void
		{
			if (this.ghost)
			{
				contact.SetEnabled(false);
				return;
			}
			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (!hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);
			if ((hero != null) && !(hero.heroView.hareView && (hero.heroView.hareView as HareView).rock  || hero.armadillo || hero.immortal || hero.inHollow || hero.behaviourController.getState(StateDruid) != null))
			{
				hero.dispatchEvent(new Event(Hero.EVENT_DEADLY_CONTACT));
				hero.dieReason = Hero.DIE_ACID;
				hero.kill();
			}
		}

		public function endContact(contact:b2Contact):void
		{
			if (this.ghost)
				contact.SetEnabled(false);
		}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (this.ghost)
				contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			beginContact(contact);
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new Acid());
		}

		override protected function initPlatformBD():void
		{
			this.platform = new Acid();
		}
	}
}