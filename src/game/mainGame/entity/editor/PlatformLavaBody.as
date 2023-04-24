package game.mainGame.entity.editor
{
	import flash.geom.Point;

	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;

	import game.mainGame.SquirrelGame;
	import sensors.ISensor;
	import views.LavaExplosionView;

	import utils.GeomUtil;
	import utils.starling.StarlingAdapterSprite;

	public class PlatformLavaBody extends PlatformGroundBody implements ISensor
	{
		public function PlatformLavaBody():void
		{
			super();
		}

		override public function get landSound():String
		{
			return "land_lava";
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new Lava());
		}

		override protected function initPlatformBD():void
		{
			this.platform = new Lava();
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);

			var normal:b2Vec2 = worldManifold.m_normal.Copy();
			if (contact.GetFixtureA().GetUserData() == this)
			{
				pushOff(contact.GetFixtureB().GetBody(), normal, worldManifold.m_points[0]);
			}
			else
			{
				normal.NegativeSelf();
				pushOff(contact.GetFixtureA().GetBody(), normal, worldManifold.m_points[1]);
			}
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function pushOff(body:b2Body, normal:b2Vec2, position:b2Vec2):void
		{
			if (!(body.GetUserData() is Hero))
				return;
			if (position.x == 0 && position.y == 0)
				return;

			var velocity:b2Vec2 = body.GetLinearVelocity();
			if (b2Math.Dot(velocity, normal) < 0)
				return;

			normal.Multiply(20);
			velocity.Add(normal);
			body.SetLinearVelocity(velocity);

			var boom:LavaExplosionView = new LavaExplosionView(GeomUtil.getAngle(new Point(), new Point(normal.x, normal.y)) - 90, 90);
			boom.x = position.x * Game.PIXELS_TO_METRE;
			boom.y = position.y * Game.PIXELS_TO_METRE;
			boom.scaleX = 0.5;
			boom.scaleY = 0.5;
			this.addChild(boom);

			if (((this.body.GetWorld().userData as SquirrelGame) != null) && ((this.body.GetWorld().userData as SquirrelGame).map != null))
				(this.body.GetWorld().userData as SquirrelGame).map.addChild(boom);
		}
	}
}