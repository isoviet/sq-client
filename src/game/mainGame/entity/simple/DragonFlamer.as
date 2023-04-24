package game.mainGame.entity.simple
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2PolygonShape;
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

	public class DragonFlamer extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;
		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(40 / Game.PIXELS_TO_METRE, 7 / Game.PIXELS_TO_METRE, new b2Vec2(-40 / Game.PIXELS_TO_METRE, -7 / Game.PIXELS_TO_METRE));
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.1, 0.1, 0.1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		private var disposed:Boolean = false;
		private var sended:Boolean = false;

		private var controller:b2ConstantAccelController;
		private var mainFixture:b2Fixture = null;

		public var scale:Number = 1;
		private var effect: ParticlesEffect;
		private var collectionEffect: CollectionEffects;
		private var tmr: int = 0;
		private var _hero: Hero = null;

		public function DragonFlamer():void
		{
			collectionEffect = CollectionEffects.instance;
			if (this.effect)
				collectionEffect.removeEffect(this.effect);

			this.effect = collectionEffect.getEffectByName(CollectionEffects.EFFECTS_DRAGON_FIRE);
			this.effect.view.visible = false;
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.mainFixture = this.body.CreateFixture(FIXTURE_DEF);
			this.mainFixture.SetUserData(this);
			this.fixedRotation = true;
			super.build(world);

			setScale(this.scale);

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);
			if (tmr != 0)
				clearTimeout(tmr);

			tmr = setTimeout(dispose, 1300);

			_hero = this.gameInst.squirrels.get(this.playerId);
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.effect && this.effect.view && _hero && this.body)
			{
				var defVec: b2Vec2 = new b2Vec2(15 * (_hero.heroView.direction ? -1 : 1), -5 * scale);
				var vecDragon: b2Vec2 = new b2Vec2(_hero.x, _hero.y);
				var rVec: b2Vec2 = rotateVec(defVec, this._hero.angle);
				var fireVec: b2Vec2 = new b2Vec2(vecDragon.x + rVec.x, vecDragon.y + rVec.y);

				this.effect.view.emitAngle = (_hero.heroView.direction ? Math.PI : 0) + this._hero.angle;
				this.effect.view.emitterY = fireVec.y;
				this.effect.view.emitterX = fireVec.x;
				this.body.SetPosition(fireVec);
				this.body.SetAngle((_hero.heroView.direction ? 0 : Math.PI) + this._hero.angle);

				if (!this.effect.view.parent && _hero.getStarlingView() && _hero.getStarlingView().parent)
				{
					this.effect.view.visible = true;
					this.effect.start();
					_hero.getStarlingView().parent.addChild(this.effect.view);
				}

				if (_hero.isDead == true)
				{
					destroy();
				}

			}
		}

		private function rotateVec(vec: b2Vec2, angle: Number): b2Vec2
		{
			var cos:Number = Math.cos(angle);
			var sin:Number = Math.sin(angle);

			return new b2Vec2(cos * vec.x - sin * vec.y, sin * vec.x + cos * vec.y);
		}

		override public function dispose():void
		{
			collectionEffect.removeEffect(this.effect);
			destroyController();
			super.dispose();
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

			if (hero == null || !hero.isSelf || hero.id == this.playerId)
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

			contact.SetEnabled(hero != null && hero.id != this.playerId);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function destroy():void
		{

			if (this.disposed)
				return;

			this.disposed = true;

			TweenMax.to(this, 0, {'alpha': 0, 'onComplete': death});
		}

		public function setScale(value:Number):void
		{
			scale = value;
		}

		private function setHeroOnFire(hero:Hero):void
		{
			if (!this.gameInst || hero.onFire)
			{
				return;
			}

			if (!this.sended)
			{
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'OnFire': [this.id, hero.id, this.playerId]}));
				if (this.playerId == Game.selfId)
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.DRAGON_FIRE, 1);
			}

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
					hero.setOnFire(true);
				if (data['OnFire'][2] == Game.selfId)
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.DRAGON_FIRE, 1);
			}
		}

		private function destroyController():void
		{
			if (!this.controller)
				return;

			this.gameInst.world.RemoveController(this.controller);
			this.controller.Clear();
			this.controller = null;
		}

		private function death():void
		{
			if (!this.body || !this.gameInst || !this.gameInst.map)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}