package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILandSound;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import particles.Explode;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class BoxGlass extends CacheVolatileBody implements ISensor, ILandSound
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(30 / Game.PIXELS_TO_METRE, 30 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.3, 0.1, 0.8, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_REF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var view:DisplayObject = null;
		private var destroyed:Boolean = false;

		private var hero:Hero = null;
		private var jointToHero:b2Joint = null;

		private var deserializedId:int = -1;

		public function BoxGlass():void
		{
			this.view = getView();
			this.view.x = -30;
			this.view.y = -30;
			addChildStarling(this.view);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		public function get landSound():String
		{
			return "glass";
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_REF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);

			if (this.deserializedId != -1)
				pinSquirrel(this.deserializedId);
		}

		public function getView(): StarlingAdapterSprite {
			 return new StarlingAdapterSprite(new GlassBox());
		}

		override public function dispose():void
		{
			releaseHero();

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			if (this.hero != null)
				result.push(this.hero.id);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			if (1 in data)
				this.deserializedId = data[1];
		}

		public function beginContact(contact:b2Contact):void
		{
			if (this.hero != null || this.destroyed)
				return;

			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero || hero.isDead || hero.inHollow || hero.frozen || hero.hasJoints("glassBox"))
				return;

			var manifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(manifold);

			var normal:b2Vec2 = manifold.m_normal.Copy();

			if (contact.GetFixtureB().GetUserData() == this)
				normal = normal.GetNegative();

			var upVector:b2Vec2 = ((this.body != null) ? new b2Vec2(Math.cos(this.body.GetAngle() - Math.PI / 2), Math.sin(this.body.GetAngle() - Math.PI / 2)) : new b2Vec2(0, 0));

			if (b2Math.Dot(normal, upVector) < 0.5)
				return;

			commandPinSquirrel(hero.id);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (this.destroyed)
				return;

			if (impulse.normalImpulses[0] < 650)
				return;

			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (hero != null && this.hero == null)
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
			var chunk: StarlingAdapterSprite = StarlingConverter.splitMClipToSprite(new GlassBoxPieces());
			addChildStarling(chunk);
			Explode.explodeBody(chunk, point, gravity, impulse);
		}

		private function commandPinSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				pinSquirrel(heroId);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'pinBoxGlassSquirrel': [this.id, heroId]}));
		}

		private function commandDestroy(point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			if (this.gameInst is SquirrelGameEditor)
				setTimeout(destroy, 0, point, gravity, impulse);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'destroyGlass': [this.id, [point.x, point.y], [gravity.x, gravity.y], impulse]}));
		}

		private function pinSquirrel(heroId:int):void
		{
			if (!this.gameInst || this.hero != null)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || hero.hasJoints("glassBox") || hero.frozen)
				return;

			this.hero = hero;
			this.hero.torqueApplied = true;
			this.hero.inertia = 1;
			this.hero.addChildStarling(this.view);
			this.view.y -= 11;

			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);
			hero.addEventListener(Hero.EVENT_TELEPORT, onEvent);
			hero.addEventListener(Hero.EVENT_REMOVE, onEvent);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2(0, 1.1);
			jointDef.localAnchorB = new b2Vec2();
			jointDef.enableLimit = true;
			jointDef.lowerAngle = 0;
			jointDef.upperAngle = 0;

			jointDef.bodyA = this.body;
			jointDef.bodyB = hero.body;
			this.jointToHero = this.body.GetWorld().CreateJoint(jointDef);
			this.jointToHero.SetUserData("glassBox");
		}

		private function onEvent(e:Event):void
		{
			releaseHero();
		}

		private function releaseHero():void
		{
			if (!this.hero)
				return;

			addChildStarling(this.view);
			this.view.y += 11;

			this.hero.inertia = 0;
			this.hero.torqueApplied = false;
			this.hero.body.SetAngularVelocity(0);

			this.hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			this.hero.removeEventListener(Hero.EVENT_TELEPORT, onEvent);
			this.hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
			this.hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			this.hero.removeEventListener(Hero.EVENT_REMOVE, onEvent);
			this.hero = null;

			if (this.jointToHero)
			{
				this.body.GetWorld().DestroyJoint(this.jointToHero);
				this.jointToHero = null;
			}
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

			if ('pinBoxGlassSquirrel' in data)
			{
				if (data['pinBoxGlassSquirrel'][0] != this.id)
					return;

				pinSquirrel(data['pinBoxGlassSquirrel'][1]);
			}

			if ('destroyGlass' in data)
			{
				if (data['destroyGlass'][0] != this.id)
					return;

				destroy(new b2Vec2(data['destroyGlass'][1][0], data['destroyGlass'][1][1]), new b2Vec2(data['destroyGlass'][2][0], data['destroyGlass'][2][1]), data['destroyGlass'][3]);
			}
		}
	}
}