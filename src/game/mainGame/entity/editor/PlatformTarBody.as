package game.mainGame.entity.editor
{
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.behaviours.StateDruid;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformTarBody extends PartitionsPlatform implements ISensor
	{
		static private const BLOCK_WIDTH:int = 40;
		static private const BLOCK_HEIGHT:int = 21;

		private var squirrels:Array = [];

		public function PlatformTarBody():void
		{
			super();

			this.friction = 2000;
			this.restitution = 0;
			this.density = 1;
		}

		override public function set size(value:b2Vec2):void
		{
			value.y = (this.blockHeight / Game.PIXELS_TO_METRE);

			super.size = value;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);

			var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox(((this.swampSprite.width - 10) / 2) / Game.PIXELS_TO_METRE, (HEIGHT / 2) / Game.PIXELS_TO_METRE, new b2Vec2(((this.swampSprite.width - 10) / 2)/ Game.PIXELS_TO_METRE, (HEIGHT / 2) / Game.PIXELS_TO_METRE));
			var fixtureDef:b2FixtureDef = new b2FixtureDef(shape, this, friction, restitution, density, this.categories, this.maskBits, 0);
			this.body.CreateFixture(fixtureDef);
			super.build(world);
			this.body.GetFixtureList().SetFriction(1000);
		}

		override public function dispose():void
		{
			for each (var hero:Hero in this.squirrels)
			{
				if (!hero || !hero.isExist)
					continue;

				releaseSquirrel(hero);
			}

			this.squirrels = null;

			super.dispose();
		}

		override protected function get leftClass():Class
		{
			return OilBlackLeft;
		}

		override protected function get middleClass():Class
		{
			return OilBlackMiddle;
		}

		override protected function get rightClass():Class
		{
			return OilBlackRight;
		}

		override public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero || hero.friction <= 0)
				return;

			setHeroStuck(hero);
		}

		override public function endContact(contact:b2Contact):void
		{
			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero)
				return;

			var index:int = this.squirrels.indexOf(hero);

			if (index == -1)
				return;

			releaseSquirrel(hero);
			this.squirrels.splice(index, 1);
		}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			if (contact.GetFixtureB().GetBody().GetUserData() == this && contact.GetFixtureA().GetBody().GetUserData() is Hero)
				contact.SetEnabled(((contact.GetFixtureA().GetBody().GetUserData() as Hero).friction > 0) && maniFold.m_normal.y >= 0);
			else if (contact.GetFixtureA().GetBody().GetUserData() == this && contact.GetFixtureB().GetBody().GetUserData() is Hero)
				contact.SetEnabled(((contact.GetFixtureB().GetBody().GetUserData() as Hero).friction > 0) && !(maniFold.m_normal.y >= 0));
		}

		override public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function setHeroStuck(hero:Hero):void
		{
			if (this.squirrels.indexOf(hero) != -1 || hero.isDead || hero.inHollow || hero.behaviourController.getState(StateDruid) != null)
				return;

			hero.stuck = true;
			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			this.squirrels.push(hero);
		}

		override protected function initPlatformBD():void
		{
			this.platform = new OilBlackIcon;
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new OilBlackIcon());
		}

		override protected function draw():void
		{
			super.draw();
		}

		protected function get blockWidth():int
		{
			return BLOCK_WIDTH;
		}

		protected function get blockHeight():int
		{
			return BLOCK_HEIGHT;
		}

		private function onEvent(e:Event):void
		{
			releaseSquirrel(e['player']);
		}

		private function releaseSquirrel(hero:Hero):void
		{
			hero.stuck = false;

			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}
	}
}