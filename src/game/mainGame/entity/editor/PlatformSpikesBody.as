package game.mainGame.entity.editor
{
	import flash.events.Event;

	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;

	import sensors.ISensor;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformSpikesBody extends PlatformGroundBody implements ISensor
	{
		protected var maxHeight:int = 28;

		public function PlatformSpikesBody():void
		{
			super();
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new Spikes());
		}

		override protected function initPlatformBD():void
		{
			this.platform = new Spikes();
		}

		override public function get size():b2Vec2
		{
			return super.size;
		}

		override public function set size(value:b2Vec2):void
		{
			value.y = maxHeight;
			super.size = value;
		}

		override protected function resize(width:int, height:int):void
		{
			if (height) {/*unused*/}
			super.resize(width, maxHeight);
		}

		override protected function draw():void
		{
			super.draw();
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
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			var normal:b2Vec2 = maniFold.m_normal.Copy();

			if (contact.GetFixtureB().GetUserData() == this)
				normal = normal.GetNegative();

			var upVector:b2Vec2 = ((this.body != null) ? new b2Vec2(Math.cos(this.body.GetAngle() - Math.PI / 2), Math.sin(this.body.GetAngle() - Math.PI / 2)) : new b2Vec2(0, 0));

			if (b2Math.Dot(normal, upVector) < 0.5)
				return;
			var hero:Hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			if (!hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);
			if ((hero != null) && checkHeroVulnerable(hero))
			{
				hero.dispatchEvent(new Event(Hero.EVENT_DEADLY_CONTACT));
				hero.dieReason = Hero.DIE_SPIKES;
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

		private function checkHeroVulnerable(hero:Hero):Boolean
		{
			return !(hero.heroView.hareView && (hero.heroView.hareView as HareView).rock || hero.persian || hero.armadillo || hero.immortal || hero.inHollow);
		}
	}
}