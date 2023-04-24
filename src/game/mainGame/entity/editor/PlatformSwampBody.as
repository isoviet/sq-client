package game.mainGame.entity.editor
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import sensors.ISensor;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformSwampBody extends PartitionsPlatform implements ISensor
	{
		static private const HEIGHT:Number = 23.6;

		public function PlatformSwampBody():void
		{
			super(false);
			leftWidthBlock = new leftClass().width - 12;
			middleWidthBlock -= 2;
			draw();
		}

		override public function get landSound():String
		{
			return "land_swamp";
		}

		override public function build(world:b2World):void
		{
			if (!this.body) {
				this.body = world.CreateBody(BODY_DEF);
				this.body.SetUserData(this);

				var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox(((this.swampSprite.width - 40) / 2) / Game.PIXELS_TO_METRE, (HEIGHT / 2) / Game.PIXELS_TO_METRE, new b2Vec2(((this.swampSprite.width- 40) / 2)/ Game.PIXELS_TO_METRE, (HEIGHT / 2) / Game.PIXELS_TO_METRE));
				var fixtureDef:b2FixtureDef = new b2FixtureDef(shape, this, friction, restitution, density, this.categories, this.maskBits, 0);
				this.body.CreateFixture(fixtureDef);
			}

			super.build(world);
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new SwampIcon());
		}

		override public function beginContact(contact:b2Contact):void
		{}

		override public function endContact(contact:b2Contact):void
		{}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);

			if (contact.GetFixtureA().GetUserData() == this)
				slowDown(contact.GetFixtureB().GetBody(), worldManifold.m_points[0]);
			else
				slowDown(contact.GetFixtureA().GetBody(), worldManifold.m_points[1]);
		}

		override public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		override protected function get leftClass():Class
		{
			return SwampLeft;
		}

		override protected function get middleClass():Class
		{
			return SwampMiddle;
		}

		override protected function get rightClass():Class
		{
			return SwampRight;
		}

		private function slowDown(body:b2Body, position:b2Vec2):void
		{
			if (body == this.body || (position.x == 0 && position.y == 0))
				return;

			var velocity:b2Vec2 = body.GetLinearVelocity();
			var torque:Number = body.GetAngularVelocity();

			velocity.x *= 0.8;
			velocity.y *= 0.8;

			torque *= 0.8;

			body.SetLinearVelocity(velocity);
			body.SetAngularVelocity(torque);
		}
	}
}