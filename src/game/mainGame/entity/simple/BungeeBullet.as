package game.mainGame.entity.simple
{
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterSprite;

	public class BungeeBullet extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(14 / Game.PIXELS_TO_METRE, 4.5 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 0.5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var controller:b2ConstantAccelController = null;
		private var bungeeCreated:Boolean = false;

		public var bungeeLength:Number;

		public function BungeeBullet():void
		{
			var view:StarlingAdapterSprite = new StarlingAdapterSprite(new BungeeBulletImage());
			view.x = -14;
			view.y = -5;
			addChildStarling(view);

			this.fixedRotation = true;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetBullet(true);
			super.build(world);

			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(200, 0)));

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);
		}

		override public function dispose():void
		{
			if (this.gameInst)
				this.gameInst.world.DestroyController(this.controller);
			this.controller = null;
			this.removeFromParent();
			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push(this.bungeeLength);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.bungeeLength = data[1];
		}

		public function beginContact(contact:b2Contact):void
		{
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			if (contact.GetFixtureB().GetUserData() == this)
				contact.SetEnabled(!(contact.GetFixtureA().GetBody().GetUserData() is BungeeHarpoon) && !this.bungeeCreated);
			else
				contact.SetEnabled(!(contact.GetFixtureB().GetBody().GetUserData() is BungeeHarpoon) && !this.bungeeCreated);

			if (!contact.IsEnabled())
				return;

			this.fixed = true;
			this.bungeeCreated = true;

			setTimeout(createBungee, 100);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function createBungee():void
		{
			if (!this.body || !this.gameInst || !this.gameInst.squirrels.isSynchronizing)
				return;

			var bungee:Bungee = new Bungee();
			bungee.isBullet = true;
			bungee.position = this.body.GetWorldPoint(new b2Vec2(0, this.bungeeLength));
			bungee.anchor0.position = this.position.Copy();
			this.gameInst.map.createObjectSync(bungee, true);
		}
	}
}