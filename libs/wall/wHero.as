package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.controllers.ControllerHero;
	import landing.controllers.IHero;
	import events.MovieClipPlayCompleteEvent;
	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.IUpdate;
	import landing.game.mainGame.entity.EntityFactory;
	import landing.game.mainGame.entity.editor.CoverIce;
	import landing.game.mainGame.entity.editor.Covered;
	import landing.game.mainGame.entity.editor.Island;
	import landing.game.mainGame.entity.editor.PlatformGroundBody;
	import landing.game.mainGame.entity.editor.PlatformHerbBody;
	import landing.game.mainGame.entity.simple.Balk;
	import landing.game.mainGame.entity.simple.BalkIce;
	import landing.game.mainGame.entity.simple.BalkIceLong;
	import landing.game.mainGame.entity.simple.BalkLong;
	import landing.game.mainGame.entity.simple.Box;
	import landing.game.mainGame.entity.simple.BoxBig;
	import landing.game.mainGame.entity.simple.BoxIce;
	import landing.game.mainGame.entity.simple.BoxIceBig;
	import landing.game.mainGame.events.SquirrelEvent;
	import landing.sensors.HeroSensor;

	import com.greensock.TweenMax;

	public class wHero extends Sprite implements IHero, IUpdate
	{
		static private const JUMP_VELOCITY:int = 30;
		static private const AIR_ACCELERATION:int = 5;
		static private const RUN_SPEED:int = 15;
		static private const RUN_ACCELERATION:int = 18;

		static private const MASS:int = 24;

		static private const CAST_UPDATE_TIME:int = 10;

		static public const EVENT_CAST_SUCCESS:String = "Hero.castSuccess";
		static public const EVENT_CAST_FAILED:String = "Hero.castFaild";
		static public const EVENT_DIE:String = "Hero.die";
		static public const EVENT_BREAK_JOINT:String = "Hero.breakJoint";

		static public const STATE_REST:int = 0;
		static public const STATE_RUN:int = 1;
		static public const STATE_JUMP:int = 2;
		static public const STATE_SHAMAN:int = 3;
		static public const STATE_DEAD:int = 4;

		static public const NUDE_MOD:int = 0;
		static public const ACORN_MOD:int = 1;

		private var label:GameField = null;
		private var heroView:wHeroView = null;
		private var isSendingPacket:Boolean = false;

		private var bodyDef:b2BodyDef = null;
		private var mainFixture:b2Fixture = null;

		private var left:Boolean = false;
		private var right:Boolean = false;

		private var onShamanFunction:Function = null;
		private var controller:ControllerHero = null;
		private var footSensor:HeroSensor = null;
		private var deathTimer:Timer = new Timer(1000, 1);
		private var castTimer:Timer = new Timer(CAST_UPDATE_TIME);
		private var world:b2World = null;
		private var castStartTime:int = 0;
		private var castTime:int = 0;

		private var messageField:TextField = null;
		private var sprite:Sprite = new Sprite();
		private var timer:Timer = new Timer(4000, 1);

		public var inHollow:Boolean = false;
		public var onBalloon:Boolean = false;
		public var isShaman:Boolean = false;
		public var isDead:Boolean = false;
		public var body:b2Body;

		public var loaded:Boolean = false;
		private var playerId:int;

		public function wHero(playerId:int, world:b2World, x:int = 0, y:int = 0, isTest:Boolean = false, isSendingPacket:Boolean = false):void
		{
			super();

			this.world = world;

			this.playerId = playerId;

			this.heroView = new wHeroView();
			addChild(this.heroView);

			initPhysic(x, y);
			hide();

			this.isSendingPacket = isSendingPacket;

			reset();

			setPosition(x, y);

			this.deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteDeath);
			this.castTimer.addEventListener(TimerEvent.TIMER, onCastUpdate);

			this.sprite.x = 0;
			this.sprite.y = 0;
			addChild(this.sprite);
		}

		public function reset():void
		{
			this.heroView.hasAcorn = false;
			this.heroView.isShaman = false;
			this.heroView.running = false;
			this.heroView.fly = false;
			this.heroView.dead = false;
			this.heroView.direction = false;
			this.heroView.isCasting = false;

			this.heroView.circle.visible = false;

			this.body.SetLinearVelocity(new b2Vec2(0, 0));
			this.left = false;
			this.right = false;
			this.inHollow = false;
			this.shaman = false;
			this.dead = false;

			this.footSensor.reset();

			if (this.controller != null)
				this.controller.active = true;
		}

		public function sendLocation(keyCode:int = 0):void
		{
		}


		public function remove():void
		{
			dispatchEvent(new Event(wHero.EVENT_BREAK_JOINT));

			this.world.DestroyBody(this.body);

			if (this.controller == null)
				return;

			this.controller.active = false;
			this.controller.remove();
			this.controller = null;
		}

		public function get casting():Boolean
		{
			return this.heroView.isCasting;
		}

		public function set casting(value:Boolean):void
		{
			this.heroView.isCasting = value;
		}

		public function turnLeft():void
		{
			this.heroView.direction = true;
		}

		public function turnRight():void
		{
			this.heroView.direction = false;
		}

		public function castStart(onComplete:Function = null, castTime:int = 2000):void
		{
			this.heroView.isCasting = true;

			if (this.id != WallShadow.SELF_ID)
				return;

			this.castStartTime = getTimer();
			this.castTime = castTime;
			this.castTimer.reset();
			this.castTimer.start();
		}

		public function castStop(completed:Boolean):void
		{
			this.heroView.isCasting = false;

			if (this.id != WallShadow.SELF_ID)
				return;

			if (completed && this.controller != null)
				this.controller.active = false;
			this.castTimer.stop();
		}

		public function getCirclePosition():Point
		{
			return new Point(this.heroView.circle.x, this.heroView.circle.y).add(new Point(this.x, this.y));
		}

		public function get id():int
		{
			return this.playerId;
		}

		public function set shaman(value:Boolean):void
		{
			this.heroView.isShaman = value;
			this.isShaman = value;
		}

		public function show():void
		{
			if (this.inHollow && this.id == WallShadow.SELF_ID)
				return;

			if (this.isDead)
				return;

			this.heroView.visible = true;
			this.body.SetActive(true);
		}

		public function hide():void
		{
			if (this.controller != null)
				this.controller.active = false;

			this.heroView.visible = false;
			this.isDead = true;
			this.body.SetActive(false);
		}

		public function onHollow():void
		{
			dispatchEvent(new Event(wHero.EVENT_BREAK_JOINT));

			this.inHollow = true;

			hide();
		}

		public function set dead(value:Boolean):void
		{
			if (this.isDead == value)
				return;
			this.isDead = value;

			this.heroView.dead = value;

			if (!value)
			{
				reset();
				return;
			}

			this.deathTimer.reset();
			this.deathTimer.start();

			dispatchEvent(new Event(wHero.EVENT_BREAK_JOINT));
			dispatchEvent(new SquirrelEvent(SquirrelEvent.DIE, this));
		}

		public function setPosition(x:int, y:int):void
		{
			this.body.SetPositionAndAngle(new b2Vec2(x / WallShadow.PIXELS_TO_METRE, y / WallShadow.PIXELS_TO_METRE), this.body.GetAngle());

			this.x = this.body.GetPosition().x * WallShadow.PIXELS_TO_METRE;
			this.y = this.body.GetPosition().y * WallShadow.PIXELS_TO_METRE + 21;
		}

		public function getPosition():Point
		{
			var v:b2Vec2 = this.body.GetPosition();
			return new Point(v.x * WallShadow.PIXELS_TO_METRE, v.y * WallShadow.PIXELS_TO_METRE);
		}

		public function setClothing(itemIds:Array):void
		{
			this.heroView.setClothing(itemIds);
		}

		public function setMode(mode:int):void
		{
			this.heroView.hasAcorn = (mode == ACORN_MOD);
		}

		public function hasAcorn():Boolean
		{
			return this.heroView.hasAcorn;
		}

		public function removeClothing():void
		{
			this.heroView.removeClothing();
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.controller != null)
				this.controller.active = this.heroView.visible;
			//if (this.inHollow)
			//	return;

			if (this.isDead)
				return;

			this.body.SetAwake(true);

			this.heroView.fly = !this.footSensor.onFloor;
			this.heroView.running = (this.left || this.right) && !(this.left && this.right) && !this.heroView.isCasting;
			this.mainFixture.SetFriction(this.heroView.running ? 0 : 1);

			if (this.heroView.running)
			{
				var velocity:b2Vec2 = this.body.GetLinearVelocity();
				this.heroView.direction = left;

				if (this.footSensor.onFloor)
					velocity.x += (left ? -RUN_ACCELERATION / 2 : RUN_ACCELERATION / 2);
				else
					velocity.x += (left ? -AIR_ACCELERATION : AIR_ACCELERATION);

				velocity.x = (Math.abs(velocity.x) < RUN_SPEED) ? velocity.x : (left ? -RUN_SPEED : RUN_SPEED);
				this.body.SetLinearVelocity(velocity);
			}

			this.x = this.body.GetPosition().x * WallShadow.PIXELS_TO_METRE;
			this.y = this.body.GetPosition().y * WallShadow.PIXELS_TO_METRE + 21;

			if (this.id != WallShadow.SELF_ID)
				return;

			checkDie();
		}

		public function removeCircle():void
		{
			this.heroView.circle.visible = false;
		}

		public function showCircle():void
		{
			this.heroView.circle.visible = true;
		}

		public function wakeUp():void
		{
			this.isDead = (this.id == WallShadow.SELF_ID) ? this.isDead : false;

			show();
		}

		public function jump(start:Boolean):void
		{
			if (this.heroView.isCasting && start)
				return;

			if (!start)
				return;

			dispatchEvent(new Event(wHero.EVENT_BREAK_JOINT));

			if (!this.footSensor.onFloor)
				return;

			var velocity:b2Vec2 = this.body.GetLinearVelocity();
			velocity.y = -JUMP_VELOCITY;
			this.body.SetLinearVelocity(velocity);
		}

		public function moveLeft(start:Boolean):void
		{
			if (this.heroView.isCasting && start)
				return;

			this.left = start;
		}

		public function moveRight(start:Boolean):void
		{
			if (this.heroView.isCasting && start)
				return;

			this.right = start;
		}

		public function setController(controller:ControllerHero):void
		{
			this.controller = controller;
		}

		public function get position():b2Vec2
		{
			return this.body.GetPosition();
		}

		public function set position(value:b2Vec2):void
		{
			this.body.SetPosition(value);
		}

		public function get velocity():b2Vec2
		{
			return this.body.GetLinearVelocity();
		}

		public function set velocity(value:b2Vec2):void
		{
			this.body.SetLinearVelocity(value);
		}

		private function onCastUpdate(e:TimerEvent):void
		{
			if (this.id != WallShadow.SELF_ID)
				return;

			this.heroView.castProgress = ((getTimer() - castStartTime) / castTime) * 100;
		}

		private function onCompleteDeath(e:TimerEvent):void
		{
			this.heroView.visible = false;

			dispatchEvent(new MovieClipPlayCompleteEvent(MovieClipPlayCompleteEvent.DEATH));
		}

		private function stop():void
		{
			var v:b2Vec2 = this.body.GetLinearVelocity();
			v.x = 0;
			this.body.SetLinearVelocity(v);
		}

		private function checkDie():void
		{
			var shift:int = 80;
			if (this.x < -shift || this.x > WallShadow.WIDTH + shift)
			{
				this.dead = true;
				this.x += (this.x < 0 ? 90 : -90);
			}
			else if (this.y > 620)
			{
				if ((this.x > -shift && this.x < 0) || (this.x > WallShadow.WIDTH && this.x < WallShadow.WIDTH))
					this.x += (this.x < 0 ? - this.x + 6 : 754 - this.x);

				this.dead = true;
				this.y = this.y - 150;
			}
		}

		private function initPhysic(x:int, y:int):void
		{
			this.bodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);
			this.bodyDef.position.Set(this.heroView.width / (2 * WallShadow.PIXELS_TO_METRE) + x / WallShadow.PIXELS_TO_METRE, this.heroView.height / (2 * WallShadow.PIXELS_TO_METRE) + y / WallShadow.PIXELS_TO_METRE);
			this.bodyDef.allowSleep = true;
			this.body = this.world.CreateBody(this.bodyDef);

			this.mainFixture = this.body.CreateFixture(new b2FixtureDef(new b2CircleShape(2), null, 0, 0.1, 1, CollisionGroup.HERO_CATEGORY, CollisionGroup.OBJECT_CATEGORY | CollisionGroup.HERO_DETECTOR_CATEGORY, 0, false));

			var polygonShape:b2CircleShape = new b2CircleShape(1.9);
			polygonShape.SetLocalPosition(new b2Vec2(0, 0.2));

			this.footSensor = new HeroSensor(this.body.CreateFixture(new b2FixtureDef(polygonShape, null, 0, 0.1, 1, CollisionGroup.HERO_SENSOR_CATEGORY | CollisionGroup.HERO_CATEGORY, CollisionGroup.OBJECT_CATEGORY, 0, false)));

			var massData:b2MassData = new b2MassData();
			massData.mass = MASS;
			this.body.SetMassData(massData);

			this.body.SetUserData(this);
		}
	}
}