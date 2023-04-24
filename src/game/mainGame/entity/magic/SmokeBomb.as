package game.mainGame.entity.magic
{
	import flash.events.Event;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.Cast;
	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.cast.ICastChange;
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;
	import sounds.GameSounds;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.textures.TextureSmoothing;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.extensions.Particle;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class SmokeBomb extends GameBody implements ILifeTime, ICastChange, IShoot, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(9 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, true, b2Body.b2_dynamicBody);

		static private const MAX_LENGTH:int = 100;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 10 * 1000;
		private var disposed:Boolean = false;

		private var _cast:Cast = null;
		private var oldCastTime:Number;

		private var _aimCursor:StarlingAdapterSprite = null;

		private var view:StarlingAdapterMovie;

		private var collectionEffect:CollectionEffects;
		private var effect:ParticlesEffect;

		public var velocity:Number;

		public function SmokeBomb():void
		{
			this.view = new StarlingAdapterMovie(new SmokeBombExplode());
			this.view.loop = false;
			this.view.gotoAndStop(1);
			addChildStarling(this.view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);
			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(this.velocity, 0)));

			this.collectionEffect = CollectionEffects.instance;

			if (this.effect)
				this.collectionEffect.removeEffect(this.effect);

			this.effect = collectionEffect.getEffectByName(CollectionEffects.EFFECTS_BLACK_SMOKE, {'sortFunction': ageSortDesc});
			this.effect.view.visible = false;
			this.effect.view.smoothing = TextureSmoothing.TRILINEAR;

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function dispose():void
		{
			this._cast = null;

			if (this._aimCursor)
				this._aimCursor = null;

			this.view.stop();
			this.view.removeFromParent(true);

			if (this.effect)
			{
				var tween:Tween = new Tween(this.effect.view, 2, Transitions.EASE_IN);
				tween.animate("alpha", 0);
				tween.onComplete = removeEffect;
				Starling.juggler.add(tween);
			}

			super.dispose();
		}

		private function removeEffect():void
		{
			if (this.effect)
			{
				this.effect.stop();
				this.collectionEffect.removeEffect(this.effect);
				this.effect = null;
			}
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;

			this.body.SetBullet(this.body.GetLinearVelocity().Length() > 100);

			if (!this.aging || this.disposed)
				return;

			this._lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.lifeTime, this.velocity]);
			result.push([this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.lifeTime = data[1][0];
			this.velocity = data[1][1];

			this.playerId = data[2][0];
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

		public function set cast(cast:Cast):void
		{
			this._cast = cast;
		}

		public function setCastParams():void
		{
			this.oldCastTime = this._cast.castTime;

			this._cast.castTime = 0;
		}

		public function resetCastParams():void
		{
			if (!this._cast)
				return;

			this._cast.castTime = this.oldCastTime;
		}

		public function get maxVelocity():Number
		{
			return this.velocity;
		}

		public function get aimCursor(): StarlingAdapterSprite
		{
			if (this._aimCursor == null)
				this._aimCursor = new StarlingAdapterSprite(new PoiseArrow());

			return this._aimCursor;
		}

		public function onAim(point: Point):void
		{
			var mousePosition:b2Vec2 = new b2Vec2(point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE);
			var weaponAngle:Number = Math.atan2(mousePosition.y - this.position.y, mousePosition.x - this.position.x);

			point = point.subtract(new Point(this.x, this.y));

			this._aimCursor.x = this.x;
			this._aimCursor.y = this.y;
			this._aimCursor.rotation = 0;
			this._aimCursor.scaleX = 1;
			this.velocity = Math.min(int(point.length), MAX_LENGTH);
			this._aimCursor.scaleX = this.velocity / this._aimCursor.width;
			this._aimCursor.rotation = weaponAngle * Game.R2D;
		}

		public function beginContact(contact:b2Contact):void
		{
			if (this.fixed || this.disposed)
				return;

			this.fixed = true;

			this.view.addEventListener(Event.COMPLETE, onExplode);
			this.view.play();
		}

		private function onExplode(e:Event):void
		{
			this.view.removeEventListener(Event.COMPLETE, onExplode);

			this.view.visible = false;

			if (this.playerId != Game.selfId)
				return;

			GameSounds.play("smoke");

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'smokeBomb': []}));
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function ageSortDesc(a:Particle, b:Particle):Number
		{
			if (a.active && b.active)
			{
				if (a.currentTime < b.currentTime)
					return 1;
				if (a.currentTime > b.currentTime)
					return -1;
			}
			else if (a.active && !b.active)
			{
				return -1;
			}
			else if (!a.active && b.active)
			{
				return 1;
			}
			return 0;
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if (!('smokeBomb' in data))
				return;

			if (!this.effect)
				return;

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			this.effect.view.visible = true;
			this.effect.view.emitterX = this.x;
			this.effect.view.emitterY = this.y - 25;
			this.effect.view.startSize = 550;
			this.effect.view.startSizeVariance = 550;
			this.effect.start();

			try
			{
				this.gameInst.map.foregroundObjects.addChildStarling(this.effect.view);
			}
			catch (e:Error)
			{
				Logger.add("Error" + e.getStackTrace());
			}
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}