package game.mainGame.entity.simple
{
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILandSound;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.PinUtil;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import particles.Explode;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class BalkGlassLong extends CacheVolatileBody implements IPinable, ISensor, ILandSound
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(100 / Game.PIXELS_TO_METRE, 5 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.3, 0.1, 0.8, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
		static private const PINS:Array = [[-100 / Game.PIXELS_TO_METRE, 0], [0, 0], [100 / Game.PIXELS_TO_METRE, 0]];

		private var view:StarlingAdapterSprite = null;
		private var destroyed:Boolean = false;

		public function BalkGlassLong()
		{
			this.view = new StarlingAdapterSprite(new GlassBalkBig());
			this.view.x = -100;
			this.view.y = -5;
			addChildStarling(this.view);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		public function get landSound():String
		{
			return "glass";
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);
		}

		override public function dispose():void
		{
			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (this.destroyed)
				return;

			if (impulse.normalImpulses[0] < 350)
				return;

			if (!(this.gameInst && this.gameInst.squirrels.isSynchronizing))
				return;

			this.destroyed = true;

			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);

			commandDestroy(worldManifold.m_points[0], this.gameInst.gravity, impulse.normalImpulses[0]);
		}

		private function playAnimation(point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			this.view.visible = false;
			var chunk: StarlingAdapterSprite = StarlingConverter.splitMClipToSprite(new GlassBalkLongPieces);
			addChildStarling(chunk);
			Explode.explodeBody(chunk, point, gravity, impulse);
		}

		private function commandDestroy(point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			if (this.gameInst is SquirrelGameEditor)
				setTimeout(destroy, 0, point, gravity, impulse);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'destroyGlass': [this.id, [point.x, point.y], [gravity.x, gravity.y], impulse]}));
		}

		private function destroy(point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			playAnimation(point, gravity, impulse);
			if (!this.gameInst)
				return;

			this.gameInst.map.remove(this, true);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;
			if ('destroyGlass' in data)
			{
				if (data['destroyGlass'][0] != this.id)
					return;

				destroy(new b2Vec2(data['destroyGlass'][1][0], data['destroyGlass'][1][1]), new b2Vec2(data['destroyGlass'][2][0], data['destroyGlass'][2][1]), data['destroyGlass'][3]);
			}
		}
	}
}