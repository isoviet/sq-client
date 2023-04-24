package game.mainGame.entity.magic
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.behaviours.StateStun;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StitchLazer extends GameBody implements ILifeTime, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(1 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 1.0, 0.5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static public const MAX_VELOCITY:int = 100;
		static public const POWER:int = 75;

		public var direction:Boolean = false;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 5 * 1000;

		private var disposed:Boolean = false;
		private var exploded:Boolean = false;

		private var controller:b2ConstantAccelController;

		private var effect:ParticlesEffect;

		public function StitchLazer()
		{}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetBullet(true);

			super.build(world);

			if (!this.builded)
				this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(this.direction ? -MAX_VELOCITY : MAX_VELOCITY, 0)));

			if (this.effect)
				CollectionEffects.instance.removeEffect(this.effect);

			this.effect = CollectionEffects.instance.getEffectByName(CollectionEffects.EFFECT_STITCH);
			this.effect.view.visible = true;
			this.effect.view.emitterX = this.x;
			this.effect.view.emitterY = this.y;
			this.effect.view.emitAngle += this.direction ? Math.PI : 0;
			this.effect.start();

			Hero.self.getStarlingView().parent.addChild(this.effect.view);

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);

			Connection.listen(onPacket, [PacketRoundCommand.PACKET_ID]);
		}

		public function beginContact(contact:b2Contact):void
		{
			explode();
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.effect && this.effect.view)
			{
				this.effect.view.emitterX = this.x;
				this.effect.view.emitterY = this.y;
			}

			if (!this.body)
				return;
			if (!this.aging || this.disposed || this.exploded)
				return;

			if (!this.gameInst.squirrels.isSynchronizing)
				return;

			for each (var hero:Hero in this.gameInst.squirrels.players)
			{
				if (hero.isDead || hero.inHollow || hero.id == this.playerId)
					continue;
				var pos:b2Vec2 = hero.position.Copy();
				pos.Subtract(this.position);
				if (pos.Length() > 2)
					continue;
				this.exploded = true;
				var command:Object = {};
				command['stitch'] = {'x': this.position.x, 'y': this.position.y, 'id': this.id};
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode(command));
				return;
			}

			this.lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			if (!("stitch" in packet.dataJson) || packet.dataJson['stitch']['id'] != this.id)
				return;
			Connection.forget(onPacket, [PacketRoundCommand.PACKET_ID]);
			this.position = new b2Vec2(packet.dataJson['stitch']['x'], packet.dataJson['stitch']['y']);

			explode();
		}

		private function explode():void
		{
			for each (var hero:Hero in this.gameInst.squirrels.players)
			{
				if (hero.isDead || hero.inHollow)
					continue;
				var pos:b2Vec2 = hero.position.Copy();
				pos.Subtract(this.position);
				if (pos.Length() > 6)
					continue;
				var velocity:b2Vec2 = new b2Vec2(POWER * (pos.x / pos.Length()), POWER * (pos.y / pos.Length()));
				hero.body.SetLinearVelocity(velocity);
				if (hero.id != this.playerId)
					hero.behaviourController.addState(new StateStun(0.5));
			}
			destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime, this.playerId, this.direction]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.playerId = data[1][2];
			this.direction = data[1][3];
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;
			if (this.body == null)
				return;
			this.gameInst.map.destroyObjectSync(this, true);
		}

		override public function dispose():void
		{
			super.dispose();

			if (!this.effect)
				return;
			var tween:Tween = new Tween(this.effect.view, 0.5, Transitions.EASE_IN);
			tween.animate("alpha", 0);
			tween.onComplete = removeEffect;
			Starling.juggler.add(tween);
		}

		private function removeEffect():void
		{
			if (!this.effect)
				return;
			this.effect.stop();
			CollectionEffects.instance.removeEffect(this.effect);
			this.effect = null;
		}
	}
}