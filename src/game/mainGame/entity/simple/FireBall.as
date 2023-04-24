package game.mainGame.entity.simple
{
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class FireBall extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.1, 0.1, 0.1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		private var disposed:Boolean = false;
		private var sended:Boolean = false;

		private var controller:b2ConstantAccelController;
		private var fly:Boolean = true;
		private var mainFixture:b2Fixture = null;

		public var scale:Number = 1;
		private var collectionEffect:CollectionEffects;
		private var effect:ParticlesEffect;

		public function FireBall():void
		{
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.SetBullet(true);
			this.mainFixture = this.body.CreateFixture(FIXTURE_DEF);
			this.mainFixture.SetUserData(this);
			this.fixedRotation = true;
			super.build(world);

			setScale(this.scale);

			if (!this.builded)
				this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(-60, 0)));

			this.collectionEffect = CollectionEffects.instance;

			if (this.effect)
				this.collectionEffect.removeEffect(this.effect);

			this.effect = collectionEffect.getEffectByName(CollectionEffects.EFFECTS_FIRE_BALL);
			this.effect.view.emitterX = this.x;
			this.effect.view.emitterY = this.y;
			this.effect.view.startSize = 30;
			this.effect.start();
			this.effect.view.visible = true;

			Hero.self.getStarlingView().parent.addChild(this.effect.view);

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);

			setTimeout(stopFly, 600, this);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;

			this.effect.view.emitterX = this.x;
			this.effect.view.emitterY = this.y;

			this.body.SetBullet(this.body.GetLinearVelocity().Length() > 10);

			if (!this.fly || this.body.GetLinearVelocity().Length() < 10)
				destroyController();
		}

		override public function dispose():void
		{
			destroyController();
			super.dispose();

			if (!this.effect)
				return;

			this.effect.stop();
			this.collectionEffect.removeEffect(this.effect);
			this.effect = null;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.playerId, this.scale]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
			this.scale = data[1][1];
		}

		public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = null;
			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			else if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (hero == null)
			{
				destroy();
				return;
			}

			if (!hero.isSelf || hero.id == this.playerId)
				return;

			setHeroOnFire(hero);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var hero:Hero = null;
			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			else if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if (hero == null)
				return;

			TweenMax.to(this, 1, {'alpha': 0});

			contact.SetEnabled(hero != null && hero.id != this.playerId);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function destroy():void
		{
			if (this.disposed)
				return;

			if (!this.body || !this.gameInst || !this.gameInst.map)
				return;

			this.gameInst.map.destroyObjectSync(this, true);

			this.disposed = true;
		}

		public function setScale(value:Number):void
		{
			var shape:b2CircleShape = new b2CircleShape((6 / Game.PIXELS_TO_METRE) * value);
			this.mainFixture.GetShape().Set(shape);
		}

		private function stopFly(fireBall:FireBall):void
		{
			if (fireBall)
				fireBall.fly = false;
		}

		private function setHeroOnFire(hero:Hero):void
		{
			if (!this.gameInst || hero.onFire)
			{
				destroy();
				return;
			}

			if (!this.sended)
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'OnFire': [this.id, hero.id, this.playerId]}));

			this.alpha = 0;
			this.sended = true;
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if (!('OnFire' in data))
				return;

			if (data['OnFire'][0] != this.id)
				return;

			if (this.gameInst && this.gameInst.squirrels)
			{
				var hero:Hero = (this.gameInst.squirrels.get(data['OnFire'][1]) as Hero);
				if (hero)
					hero.setOnFire(true, CollectionEffects.EFFECTS_SQUIRREL_FIRE_BLUE);
			}

			destroy();
		}

		private function destroyController():void
		{
			if (!this.controller)
				return;

			this.gameInst.world.RemoveController(this.controller);
			this.controller.Clear();
			this.controller = null;
		}
	}
}