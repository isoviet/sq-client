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
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import sensors.ISensor;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.textures.TextureSmoothing;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class SheepBomb extends GameBody implements ILifeTime, ICastChange, IShoot, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(9 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, true, b2Body.b2_dynamicBody);

		static private const MAX_LENGTH:int = 100;

		protected var _aging:Boolean = false;
		protected var _lifeTime:Number = 100;
		protected var disposed:Boolean = false;

		protected var _cast:Cast = null;
		protected var oldCastTime:Number;

		protected var _aimCursor:StarlingAdapterSprite = null;

		protected var view:StarlingAdapterSprite;
		protected var viewExplode:StarlingAdapterMovie;

		public var velocity:Number;
		protected var effect:ParticlesEffect;

		public function SheepBomb():void
		{
			this.view = new StarlingAdapterSprite(new SheepBombView());
			this.view.scaleXY(0.5, 0.5);
			addChildStarling(this.view);

			this.viewExplode = new StarlingAdapterMovie(new SheepBombExplodeView());
			this.viewExplode.scaleXY(0.5, 0.5);
			this.viewExplode.visible = false;
			this.viewExplode.stop();
			this.viewExplode.x = -6;
			this.viewExplode.y = -17;
			addChildStarling(this.viewExplode);
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

			if (this.effect)
				CollectionEffects.instance.removeEffect(this.effect);

			this.effect = CollectionEffects.instance.getEffectByName(this.effectName);
			this.effect.view.visible = false;
			this.effect.view.smoothing = TextureSmoothing.TRILINEAR;
		}

		protected function get effectName():String
		{
			return CollectionEffects.EFFECT_SHEEP_BOMB;
		}

		override public function dispose():void
		{
			this._cast = null;

			if (this._aimCursor)
				this._aimCursor = null;

			this.viewExplode.stop();
			this.view.removeFromParent(true);

			if (this.effect)
			{
				var tween:Tween = new Tween(this.effect.view, 0.2, Transitions.EASE_IN);
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
				CollectionEffects.instance.removeEffect(this.effect);
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

			this.view.visible = false;

			this.viewExplode.addEventListener(Event.COMPLETE, onExplode);
			this.viewExplode.visible = true;
			this.viewExplode.loop = false;
			this.viewExplode.play();

			GameSounds.play("sheep_bomb");

			this.effect.view.visible = true;
			this.effect.view.emitterX = this.x;
			this.effect.view.emitterY = this.y;
			this.effect.start();

			try
			{
				this.gameInst.map.foregroundObjects.addChildStarling(this.effect.view);
			}
			catch (e:Error)
			{
				Logger.add("Error" + e.getStackTrace());
			}

			doEffect();

			GameSounds.play("halloween_bomb_explode");
		}

		protected function doEffect():void
		{
			if (Game.selfId != this.playerId)
				return;
			try
			{
				for each (var hero:Hero in this.gameInst.squirrels.players)
				{
					if (hero.id == this.playerId)
						continue;

					var pos:b2Vec2 = this.position.Copy();
					pos.Subtract(hero.position);

					if (pos.Length() > 8)
						continue;
					Connection.sendData(PacketClient.ROUND_SKILL_ACTION, PerkClothesFactory.ALCHEMIST_SHEEP, hero.id, 0);
				}
			}
			catch (e:Error)
			{
				Logger.add("Error" + e.getStackTrace());
			}
		}

		protected function onExplode(e:Event):void
		{
			this.aging = true;

			this.viewExplode.removeEventListener(Event.COMPLETE, onExplode);
			this.viewExplode.visible = false;
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}