package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2JointEdge;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import clans.Clan;
	import clans.ClanManager;
	import controllers.ControllerHero;
	import controllers.IHero;
	import events.MovieClipPlayCompleteEvent;
	import footers.FooterGame;
	import game.gameData.EducationQuestManager;
	import game.gameData.OutfitData;
	import game.mainGame.ActiveBodiesCollector;
	import game.mainGame.CameraController;
	import game.mainGame.CastItems;
	import game.mainGame.CollisionGroup;
	import game.mainGame.GameMap;
	import game.mainGame.ISideObject;
	import game.mainGame.IUpdate;
	import game.mainGame.KickButton;
	import game.mainGame.SideIconView;
	import game.mainGame.SquirrelGame;
	import game.mainGame.behaviours.Behaviour;
	import game.mainGame.behaviours.BehaviourController;
	import game.mainGame.behaviours.IStateActive;
	import game.mainGame.behaviours.StateBanshee;
	import game.mainGame.behaviours.StateContused;
	import game.mainGame.behaviours.StateFlight;
	import game.mainGame.behaviours.StateFlightCat;
	import game.mainGame.entity.ILandSound;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.cast.DragTool;
	import game.mainGame.entity.editor.PlatformTarBody;
	import game.mainGame.entity.simple.AcornBody;
	import game.mainGame.entity.simple.DragonFlamer;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.simple.Poise;
	import game.mainGame.entity.simple.PoiseInvisible;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.gameBattleNet.HeroBattle;
	import game.mainGame.gameNet.SquirrelGameNet;
	import game.mainGame.gameSurvivalNet.GameMapSurvivalNet;
	import game.mainGame.gameTwoShamansNet.GameMapTwoShamansNet;
	import game.mainGame.gameTwoShamansNet.HeroTwoShamans;
	import game.mainGame.perks.PerkController;
	import game.mainGame.perks.clothes.ui.ClothesToolBar;
	import game.mainGame.perks.dragon.ui.DragonPerksToolBar;
	import game.mainGame.perks.hare.ui.HarePerksToolBar;
	import game.mainGame.perks.mana.ui.PerksToolBar;
	import game.mainGame.perks.shaman.PerkShaman;
	import game.mainGame.perks.shaman.PerkShamanBigHead;
	import game.mainGame.perks.shaman.ui.ShamanToolBar;
	import game.mainGame.perks.ui.FastPerksBar;
	import loaders.RuntimeLoader;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.Screens;
	import sensors.HeroSensor;
	import sensors.ISensor;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import views.BuffView;
	import views.Settings;

	import com.api.Player;
	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.structs.PacketLoginShamanInfo;
	import protocol.packages.server.structs.PacketRoundSkillsItemsCharactersSkills;

	import starling.animation.Tween;
	import starling.core.Starling;

	import utils.FiltersUtil;
	import utils.InstanceCounter;
	import utils.SaltValue;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class Hero extends StarlingAdapterSprite implements IHero, IUpdate, ISensor, ISideObject
	{
		static private const HARE_RUN_FACTOR:Number = 0.7;
		static private const HARE_JUMP_FACTOR:int = 15;
		static private const DRAGON_JUMP_FACTOR:int = 15;
		static private const CONTUSED_RUN_FACTOR:Number = 1.3;
		static private const RESPAWN_VITALITY_TIME:int = 5000;

		static private const CAST_UPDATE_TIME:int = 10;

		static private const CAST_EFFECTS:Array = [
			CollectionEffects.EFFECT_CAST_SHAMAN,
			CollectionEffects.EFFECT_CAST_SHAMAN,
			CollectionEffects.EFFECT_CAST_FLOWER_SHAMAN
		];

		static private const LOAD_MASK:int = PlayerInfoParser.SEX | PlayerInfoParser.WEARED | PlayerInfoParser.CLAN | PlayerInfoParser.SHAMAN_SKILLS;

		static public const INTERPOLATION_STEP:Number = 0.1;

		static public const EVENT_SCALE:String = "Hero.scale";
		static public const EVENT_REMOVE:String = "Hero.remove";
		static public const EVENT_DIE:String = "Hero.die";
		static public const EVENT_BREAK_JOINT:String = "Hero.breakJoint";
		static public const EVENT_BREAK_MAGIC_JOINT:String = "Hero.breakGum";
		static public const EVENT_BREAK_ROPE:String = "Hero.breakRope";
		static public const EVENT_DOUBLE_JUMP:String = "Hero.doubleJump";
		static public const EVENT_DEADLY_CONTACT:String = "Hero.deadlyContact";
		static public const EVENT_TELEPORT:String = "Hero.teleport";
		static public const EVENT_UP:String = "Hero.up";
		static public const EVENT_UP_END:String = "Hero.EVENT_UP_END";
		static public const EVENT_PERK_QUEST:String = "Hero.perkQuest";

		static public const GLOW_FILTERS:Array = [[], [FiltersUtil.glowLight], [FiltersUtil.glowLightHighlight]];

		static public const JUMP_VELOCITY:int = 30;

		static public const STATE_STOPED:int = -1;
		static public const STATE_REST:int = 0;
		static public const STATE_RUN:int = 1;
		static public const STATE_JUMP:int = 2;
		static public const STATE_SHAMAN:int = 3;
		static public const STATE_DEAD:int = 4;
		static public const STATE_EMOTION:int = 5;

		static public const DB_STAND:String = "stand";
		static public const DB_RUN:String = "run";
		static public const DB_JUMP:String = "jump";
		static public const DB_CAST:String = "cast";
		static public const DB_LAUGH:String = "laugh";
		static public const DB_CRY:String = "cry";
		static public const DB_KISS:String = "kiss";
		static public const DB_ANGRY:String = "angry";
		static public const DB_CAST3:String = "cast3";

		static public const DB_STATES:Object = {
			(STATE_REST.toString()): DB_STAND,
			(STATE_RUN.toString()): DB_RUN,
			(STATE_JUMP.toString()): DB_JUMP,
			(STATE_SHAMAN.toString()): DB_CAST
		};

		static public const RESPAWN_NONE:int = 0;
		static public const RESPAWN_SIMPLE:int = 1;
		static public const RESPAWN_HARD:int = 2;

		static public const TEAM_NONE:int = 0;
		static public const TEAM_RED:int = 1;
		static public const TEAM_BLUE:int = 2;
		static public const TEAM_BLACK:int = 3;

		static public const NUDE_MOD:int = 0;
		static public const NUT_MOD:int = 1;

		static public const EMOTION_NONE:int = 0;
		static public const EMOTION_LAUGH:int = 1;
		static public const EMOTION_CRY:int = 2;
		static public const EMOTION_ANGRY:int = 3;
		static public const EMOTION_KISS:int = 4;
		static public const EMOTION_MAX_TYPE:int = 5;

		static public const TELEPORT_DESTINATION_ACORN_HOLLOW:int = 0;
		static public const TELEPORT_DESTINATION_SHAMAN:int = 1;
		static public const TELEPORT_DESTINATION_RESPAWN:int = 2;

		static public const DIE_FALL:int = 0;
		static public const DIE_BULLET:int = 1;
		static public const DIE_ACID:int = 2;
		static public const DIE_SPIKES:int = 3;
		static public const DIE_QUICKSAND:int = 4;
		static public const DIE_THIRST:int = 5;
		static public const DIE_SUICIDE:int = 6;
		static public const DIE_REPORT:int = 7;

		static public const Y_POSITION_COEF:int = 21;

		static private var _self:Hero = null;
		static private var _listeners:Dictionary = new Dictionary();

		private var _shaman:Boolean = false;
		private var _lighting: StarlingAdapterSprite;

		private var _isPlayedOnce:Boolean = false;

		protected var _jumpVelocity:SaltValue = new SaltValue(JUMP_VELOCITY);
		protected var _airAcceleration:SaltValue = new SaltValue(5);
		protected var _runSpeed:Number = 15;
		protected var _runAcceleration:int = 18;

		protected var _maxInAirJumps:SaltValue = new SaltValue(0);
		protected var _maxFallJumps:SaltValue = new SaltValue(0);
		protected var _inAirJumpFactor:Number = 1;
		protected var _swimFactor:Number = 1;
		protected var _mass:int = 4;
		private var _inertia:Number = 0;
		protected var _friction:Number = 1;
		protected var _restitution:Number = 0.1;
		protected var _scale:Number = 1;
		protected var _headWalker:int = 0;
		protected var _transparent:Boolean = false;
		protected var _sendMove:Boolean = false;
		protected var _wizard:Boolean = false;
		protected var _collideSquirrels:Boolean = false;
		protected var _perksAvailable:Boolean = true;

		protected var transparentTween:TweenMax = null;

		protected var avalibleJumpCount:SaltValue = new SaltValue(0);
		protected var availableFallJumpCount:SaltValue = new SaltValue(0);

		protected var bodyDef:b2BodyDef = null;
		public var mainFixture:b2Fixture = null;

		protected var stoped:int = 0;
		protected var controller:ControllerHero = null;
		protected var deathTimer:Timer = new Timer(1000, 1);
		protected var castTimer:Timer = new Timer(CAST_UPDATE_TIME);
		protected var castStartTime:int = 0;
		protected var castTime:int = 0;

		public var footSensorFixture:b2Fixture;

		protected var _isHare:Boolean = false;
		protected var _isScrat:Boolean = false;
		protected var _isDragon:Boolean = false;
		protected var _colideWithSquirrels:Boolean = false;

		protected var killed:Boolean = false;
		protected var vitalityTween:TweenMax = null;

		protected var viewButton:DisplayObject = null;

		protected var buffView:BuffView;

		protected var _gummed:Boolean = false;
		protected var _onFire:Boolean = false;
		protected var _stuck:Boolean = false;
		protected var _inBubble:Boolean = false;
		protected var _immortal:Boolean = false;
		protected var _frozen:Boolean = false;

		protected var currentHighlight:int = -1;

		protected var clan:Clan = null;

		protected var interpolateVector:b2Vec2 = null;

		protected var _lastJumpPos:b2Vec2 = null;

		protected var extGravity:b2Vec2 = new b2Vec2();
		protected var footSensor:HeroSensor = null;
		protected var world:b2World = null;

		protected var vitalityTimer:Timer = new Timer(Hero.RESPAWN_VITALITY_TIME, 1);
		protected var icon: StarlingAdapterSprite = null;
		protected var _team:int = Hero.TEAM_NONE;

		private var _isVisible: Boolean = false;

		private var effects:Object = {};
		private var collectionEffect:CollectionEffects;

		private var _isCasting:Boolean = false;
		private var castEffect:ParticlesEffect = null;

		private var behaviours:Dictionary = new Dictionary();

		public var onRemove:Boolean = false;

		public var body:b2Body;

		public var useGravity:Boolean = true;
		public var lastKiller:int = -1;
		public var dieReason:int = -1;

		public var frags:uint = 0;
		public var heroView:HeroView = null;
		public var up:Boolean = false;
		public var left:Boolean = false;

		public var right:Boolean = false;

		public var fallVelocities:Array = [];

		public var perkController:PerkController = null;
		public var behaviourController:BehaviourController = null;

		public var inHollow:Boolean = false;
		public var hangOnRope:Boolean = false;

		public var isDead:Boolean = false;

		public var isNew:Boolean = false;
		public var persian:Boolean = false;
		public var armadillo:Boolean = false;
		public var acornShare:Boolean = false;

		public var torqueApplied:Boolean = false;

		public var castItems:CastItems = new CastItems();

		public var player:Player = null;
		public var swim:Boolean = false;
		public var lastStateSwim:Boolean = false;
		public var submerge:Boolean = false;
		public var hover:Boolean = false;
		public var climbing:Boolean = false;
		public var ghost:Boolean = false;
		public var isVendigo:Boolean = false;

		public var isVictim:Boolean = false;

		public var acornGrabbed:Boolean = false;
		public var viewChanged:Boolean = false;
		public var healedByDeath:Boolean = false;

		public var healedByPerk:Boolean = false;
		public var resetMass:Boolean = false;
		public var resetRestitution:Boolean = false;

		public var resetI:Boolean = false;
		public var hideCircle:Boolean = true;
		public var useRunningCast:Boolean = false;

		public var telekinesisColor:int = DragTool.DEFAULT_DRAG_COLOR;
		public var accelerateFactor:Number = 1;

		public var questFactor:Number = 1;

		public var followId:int = 0;

		public function Hero(playerId:int, world:b2World, x:int = 0, y:int = 0):void
		{
			Logger.add("new Hero:" + playerId);
			InstanceCounter.onCreate(this);
			_lighting = new StarlingAdapterSprite(new SquirrellLighting());
			_lighting.alignPivot();

			super();

			this.touchable = false;

			this.world = world;

			this.heroView = new this.viewClass(playerId);
			this.heroView.y = 21;
			addChild(this.heroView);
			addChildStarling(this.heroView);

			this.game.addChildStarling(this.heroView.circle);
			this.game.addChild(this.heroView.circle);
			this.heroView.circle.visible = false;

			this.player = Game.getPlayer(playerId);

			if (Game.selfId == this.id)
				self = this;

			initPhysic(x, y);
			this.perkController = new PerkController(this);
			this.behaviourController = new BehaviourController(this);
			hide();

			reset();

			if (playerId > 0)
			{
				this.player.addEventListener(Hero.LOAD_MASK, onPlayerLoad);
				Game.request(playerId, Hero.LOAD_MASK, true);
			}

			if (id == Game.selfId)
				this.buffView = new BuffView();

			setPosition(x, y);

			this.deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteDeath);
			this.castTimer.addEventListener(TimerEvent.TIMER, onCastUpdate);
			this.vitalityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteRespawnVitality);

			this.mouseEnabled = true;
			this.mouseChildren = true;

			CameraController.dispatcher.addEventListener("CAMERA_CHANGE", onCamera);

			this.isNew = true;

			collectionEffect = CollectionEffects.instance;
		}

		static public function get selfEvents():Array
		{
			return [Hero.EVENT_REMOVE, Hero.EVENT_DIE, SquirrelEvent.RESET, SquirrelEvent.LEAVE, SquirrelEvent.HIDE, SquirrelEvent.DIE, SquirrelEvent.RESPAWN];
		}

		static public function get self():Hero
		{
			return _self;
		}

		static public function set self(value:Hero):void
		{
			if (self == value)
				return;

			if (self)
			{
				for (var i:int = 0; i < selfEvents.length; i++)
					_self.removeEventListener(selfEvents[i], onEventHandler);
			}
			_self = value;

			if (self)
			{
				for (i = 0; i < selfEvents.length; i++)
					_self.addEventListener(selfEvents[i], onEventHandler);
			}
		}

		static public function get selfAlive():Boolean
		{
			return (self != null && !self.inHollow && !self.isDead);
		}

		static private function onEventHandler(e:Event):void
		{
			for (var listen:* in _listeners)
			{
				if (listen == null)
					delete _listeners[listen];
				else
					if (_listeners[listen] == e.type)
						(listen as Function).apply(null);
			}
		}

		// незабываем дополнять события в self
		static public function listenSelf(events:Array, callback:Function):void
		{
			for each(var event:String in events)
				_listeners[callback] = event;
		}

		static public function forget(callback:Function):void
		{
			for (var listen:* in _listeners)
				if((listen as Function) == callback)
					delete _listeners[listen];
		}

		public function get viewClass():Class
		{
			return HeroView;
		}

		public function get isSelf():Boolean
		{
			return (this.id == Game.self.id || this.id < 0);
		}

		public function get isCheater():Boolean
		{
			return this.id == ScreenGame.cheaterId;
		}

		public function get isExist():Boolean
		{
			return this.body != null;
		}

		public function get angle():Number
		{
			if (!this.body)
				return 0;

			return this.body.GetAngle();
		}

		override public function set x(value: Number): void
		{
			super.x = value;
			for each(var effect:ParticlesEffect in this.effects)
			{
				effect.view.emitterX = value;
				effect.view.emitAngle = (effect.additionAngle == 0 ? (heroView.direction ? Math.PI : 0) : 0) +  this.body.GetAngle() + effect.additionAngle;
			}
		}

		override public function set y(value: Number): void
		{
			super.y = value;
			for each(var effect:ParticlesEffect in this.effects)
			{
				effect.view.emitterY = value;
				effect.view.emitAngle = (effect.additionAngle == 0 ? (heroView.direction ? Math.PI : 0) : 0) +  this.body.GetAngle() + effect.additionAngle;
			}
		}

		public function set angle(value:Number):void
		{
			this.body.SetAngle(value);

			for each(var effect:ParticlesEffect in this.effects)
			{
				effect.view.emitAngle = (effect.additionAngle == 0 ? (heroView.direction ? Math.PI : 0) : 0) + this.body.GetAngle() + effect.additionAngle;
			}
		}

		public function hasJoints(userData:*):Boolean
		{
			if (!this.body)
				return false;

			var list:b2JointEdge = this.body.GetJointList();
			for (; list; list = list.next)
			{
				if (list.joint.GetUserData() == userData)
					return true;
			}

			return false;
		}

		public function get rCol1():b2Vec2
		{
			return this.body.GetTransform().R.col1;
		}

		public function get rCol2():b2Vec2
		{
			return this.body.GetTransform().R.col2;
		}

		public function get onFloor():Boolean
		{
			return this.footSensor.onFloor;
		}

		public function getLocalVector(v:b2Vec2):b2Vec2
		{
			return this.body.GetLocalVector(v);
		}

		public function applyImpulse(impulse:b2Vec2):void
		{
			this.body.ApplyImpulse(impulse, this.body.GetWorldCenter());
		}

		//TODO
		public function earthQuake():void
		{
			/*if ((this.heroView.hareView as HareView).stompFrame < (12 - 4) && (this.heroView.hareView as HareView).stompFrame > (12 + 4) || !this.footSensor.onFloor)
				return;*/

			var strength:Number = 30;
			this.game.shift = this.game.shift.add(new Point(Math.random() * strength - strength/2, Math.random() * strength - strength/2));
		}

		public function bindToJointDef(jointDef:b2DistanceJointDef, point:b2Vec2, isFirstBody:Boolean = true):void
		{
			if (isFirstBody)
				jointDef.localAnchorA = this.body.GetLocalPoint(point);
			else
				jointDef.localAnchorB = this.body.GetLocalPoint(point);
		}

		public function bindToDistanceJointDef(jointDef:b2DistanceJointDef, isFirstBody:Boolean = true):void
		{
			if (isFirstBody)
				jointDef.bodyA = this.body;
			else
				jointDef.bodyB = this.body;
		}

		public function bindToRevoluteJointDef(jointDef:b2RevoluteJointDef, isFirstBody:Boolean = true):void
		{
			if (isFirstBody)
				jointDef.bodyA = this.body;
			else
				jointDef.bodyB = this.body;
		}

		public function extGravityAdd(v:b2Vec2):void
		{
			this.extGravity.Add(v);
		}

		//TODO
		public function checkShift(shift:Number):Boolean
		{
			return (this.x > this.game.map.size.x + shift);
		}

		public function reset():void
		{
			this.perkController.resetRound();

			if (this.body)
				this.body.renewTransform();

			this.castEffect = null;
			disposeAllParticleEffect();

			for each(var behaviour:Behaviour in this.behaviours)
				behaviour.remove();

			this.behaviours = new Dictionary();

			this.heroView.resetEmotion();
			this.heroView.hideCollectionAnimation();
			this.heroView.hasNut = false;
			this.heroView.shaman = false;
			this.heroView.running = false;
			this.heroView.fly = false;
			this.heroView.dead = false;
			this.heroView.direction = false;
			this.heroView.isHare = false;
			this.heroView.isDragon = false;
			this.heroView.circle.visible = false;
			this.heroView.update();

			this.body.SetLinearVelocity(new b2Vec2(0, 0));
			this.runSpeed = 15;
			this.runAcceleration = 15;

			this.isHare = false;
			this.isDragon = false;
			this.isNew = false;
			this.left = false;
			this.right = false;
			this.hover = false;
			this.inHollow = false;
			this.shaman = false;
			this.dead = false;
			this.colideWithSquirrels = false;
			this.acornGrabbed = false;
			this.gummed = false;
			this.setOnFire(false);
			this.healedByDeath = false;
			this.torqueApplied = false;
			this.ghost = false;
			this.isVendigo = false;
			this.isVictim = false;

			this.team = Hero.TEAM_NONE;

			this.killed = false;
			this.lastKiller = -1;
			this.dieReason = -1;
			this.frags = 0;
			this.questFactor = 1.0;

			this.footSensor.reset();

			this.castItems.reset();

			if (this.controller != null)
				this.controller.active = true;

			if (this.clan)
			{
				ClanManager.request(this.player['clan_id'], true, ClanInfoParser.INFO | ClanInfoParser.STATE | ClanInfoParser.TOTEMS);
				this.clan.addEventListener(ClanInfoParser.INFO | ClanInfoParser.STATE | ClanInfoParser.TOTEMS, onClanLoaded);
			}

			if (this.heroView.scratView)
				AnimationDataCollector.resetAge((this.heroView.scratView as ScratView).usingClothes);

			dispatchEvent(new SquirrelEvent(SquirrelEvent.RESET, this));
			if (this.viewChanged && (this.player['weared'] != null))
			{
				this.heroView.setClothing(this.player['weared_packages'], this.player['weared_accessories']);
				this.viewChanged = false;
			}

			setCurseView(null);

			this.heroView.showCheaterPointer(this.isCheater);
		}

		public function sendLocation(keyCode:int = 0):void
		{
			if (/*this.id != Game.selfId || */this.isDead || this.inHollow || !this.sendMove)
				return;

			Logger.add("Hero.sendLocation:" + keyCode);
			Connection.sendData(PacketClient.ROUND_HERO, keyCode, this.position.x, this.position.y, this.velocity.x, this.velocity.y);
		}

		public function get playerName():String
		{
			return this.player['name'];
		}

		public function remove():void
		{
			this.onRemove = true;

			this.castEffect = null;
			disposeAllParticleEffect();

			Logger.add("Hero remove:" + player['id']);
			InstanceCounter.onDispose(this);
			this.sendMove = false;

			dispatchEvent(new Event(Hero.EVENT_REMOVE));
			dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_MAGIC_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_ROPE));

			ActiveBodiesCollector.removeBody(this.body);

			this.world.DestroyBody(this.body);
			this.body.SetUserData(null);
			this.mainFixture.SetUserData(null);
			this.footSensorFixture.SetUserData(null);

			releaseAcorn();

			if (this.clan)
				this.clan.removeEventListener(onClanLoaded);

			CameraController.dispatcher.removeEventListener("CAMERA_CHANGE", onCamera);

			if (!RuntimeLoader.loaded)
				return;

			this.castItems.dispose();

			if (this.id == Game.selfId)
			{
				PerksToolBar.hero = null;
				HarePerksToolBar.hero = null;
				ClothesToolBar.hero = null;
				DragonPerksToolBar.hero = null;
				FastPerksBar.hero = null;
			}

			this.perkController.dispose();

			this.footSensor = null;
			this.world = null;
			this.body = null;
			this.footSensorFixture = null;
			this.icon = null;

			if (this.buffView && this.buffView.parent)
			{
				this.buffView.dispose();
				this.buffView.parent.removeChild(this.buffView);
			}
			this.buffView = null;

			if (this.heroView.circle.parentStarling)
				this.heroView.circle.parentStarling.removeChildStarling(this.heroView.circle, false);

			if (this.heroView.aura && this.heroView.aura.parent)
				this.heroView.aura.parent.removeChild(this.heroView.aura);

			this.heroView.remove();

			this.deathTimer.stop();
			this.castTimer.stop();
			this.vitalityTimer.stop();

			this.deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onCompleteDeath);
			this.castTimer.removeEventListener(TimerEvent.TIMER, onCastUpdate);
			this.vitalityTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onCompleteRespawnVitality);

			if (this.player)
				this.player.removeEventListener(onPlayerLoad);

			if (this.controller == null)
				return;

			this.controller.active = false;
			this.controller.remove();
			this.controller = null;

			if (Game.selfId == this.id)
				self = null;
		}

		public function castStart(castTime:int = 2000):void
		{
			if (this.game.paused)
				return;

			if (!(this.heroView.running && this.useRunningCast))
				this.isCasting = true;

			if (this.id != Game.selfId && this.id > 0 || castTime == 0 )
				return;

			this.heroView.castProgress = 0;

			this.castStartTime = getTimer();
			this.castTime = castTime;
			this.castTimer.reset();
			this.castTimer.start();
		}

		public function castStop(completed:Boolean):void
		{
			this.isCasting = false;

			if (this.id != Game.selfId && this.id > 0)
				return;

			this.heroView.castProgress = 0;

			if (completed && this.controller != null)
				this.controller.active = false;
			this.castTimer.stop();
		}

		public function get isStoped():Boolean
		{
			return this.stoped > 0;
		}

		public function set isStoped(value:Boolean):void
		{
			this.stoped = Math.max(0, this.stoped + (value ? 1 : -1));

			if (this.controller)
				this.controller.stoped = this.isStoped;
			if (!this.isStoped)
				return;

			this.left = false;
			this.right = false;
			this.up = false;
		}

		public function get perksShaman():Vector.<PerkShaman>
		{
			return this.perkController.perksShaman;
		}

		public function getCirclePosition():Point
		{
			return this.globalToLocal(this.game.localToGlobal(new Point(this.heroView.circle.x, this.heroView.circle.y))).add(new Point(this.x, this.y));
		}

		public function get id():int
		{
			return this.player.id;
		}

		public function get shaman():Boolean
		{
			return this._shaman;
		}

		public function set shaman(value:Boolean):void
		{
			if (this.shaman == value)
				return;
			this._shaman = value;

			if (this.isDragon)
				this.isDragon = false;

			this.castEffect = null;
			disposeAllParticleEffect();

			Logger.add("Shaman ", this.id, value);

			this.heroView.shaman = value;

			if (this.shaman)
			{
				this.castEffect = applyEffect(CAST_EFFECTS[this.heroView.typeShaman], 1, true);
				this.castEffect.view.alpha = 0;
				this.castEffect.view.visible = false;
				this.castEffect.start();

				initShamanPerks(this.player['shaman_skills']);
			}
			else
			{
				for each (var perkShaman:PerkShaman in this.perksShaman)
					perkShaman.reset();
			}

			this.isCasting = false;
			dispatchEvent(new SquirrelEvent(SquirrelEvent.SHAMAN, this));

			if (!value)
				return;

			dispatchEvent(new Event(Hero.EVENT_BREAK_ROPE));

			if (this.isScrat)
				releaseAcorn();
			if (this.game is SquirrelGameNet)
				EducationQuestManager.done(EducationQuestManager.SHAMAN);
		}

		public function setEmotion(type:int):void
		{
			if ((type >= Hero.EMOTION_MAX_TYPE) && !this.isHare)
			{
				sendSmile(type);
				return;
			}
			if ((this.heroView.emotion ? this.heroView.emotionType : -1) == type)
				this.heroView.resetEmotion();
			else
			{
				this.heroView.setEmotion(type);
				dispatchEvent(new SquirrelEvent(SquirrelEvent.EMOTION, this));
			}
		}

		public function get game():SquirrelGame
		{
			return this.world == null ? null : this.world.userData;
		}

		public function show():void
		{
			if (this.inHollow && this.id == Game.selfId)
				return;

			if (this.isDead || !this.isExist)
				return;

			_isPlayedOnce = true;

			this.heroView.circle.visible = false;
			this.heroView.visible = true;
			this.heroView.update();

			if (this.heroView.aura)
				this.heroView.aura.visible = true;

			this.body.SetActive(true);

			if (this.buffView && Game.gameSprite && !Game.gameSprite.contains(buffView))
				Game.gameSprite.addChild(this.buffView);
			if (this.buffView)
				this.buffView.visible = true;

			updatePosition();
		}

		public function updateState():void
		{
			this.heroView.visible = false;

			if (this.heroView.aura)
				this.heroView.aura.visible = false;

			this.body.SetActive(false);

			if (this.buffView)
				this.buffView.visible = false;

			show();
		}

		public function hide():void
		{
			if (this.controller != null)
				this.controller.active = false;

			this.heroView.visible = false;

			if (this.heroView.aura)
				this.heroView.aura.visible = false;

			this.heroView.circle.visible = false;

			this.isDead = true;
			this.body.SetActive(false);
			this.left = false;
			this.right = false;
			this.up = false;
			if (this.buffView)
				this.buffView.visible = false;

			update();

			if (this.heroView.hareView)
				(this.heroView.hareView as HareView).setState(STATE_REST);

			dispatchEvent(new SquirrelEvent(SquirrelEvent.HIDE, this));
		}

		public function onHollow(type:int = TEAM_NONE):void
		{
			dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_MAGIC_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_ROPE));
			dispatchEvent(new HollowEvent(this, type));

			this.inHollow = true;

			if (this.isScrat)
				releaseAcorn();

			hide();

			if (this.clan && this.id == Game.selfId)
				ClanManager.request(this.clan.id, true, ClanInfoParser.RANK);
		}

		public function set dead(value:Boolean):void
		{
			//TODO убрать этот кусок в навыки шамана
			if (value && this.dieReason == DIE_FALL && this.immortal && this.isSelf)
			{
				if (!this.shaman)
					teleport(TELEPORT_DESTINATION_SHAMAN);
				else
				{
					if (!this.game || !this.game.map)
						return;
					switch (this.team)
					{
						case TEAM_NONE:
						case TEAM_BLUE:
							teleportTo(this.game.map.shamansPosition.pop());
							break;
						case TEAM_RED:
							teleportTo((this.game.map as GameMapTwoShamansNet).redShamansPosition.pop());
							break;
						case TEAM_BLACK:
							teleportTo((this.game.map as GameMapSurvivalNet).blackShamansPosition.pop());
							break;
					}
				}

				if (this.sendMove && this.isSelf)
					sendLocation();
				return;
			}

			if (this.isDead == value)
				return;

			this.isDead = value;
			this.heroView.dead = value;

			if (!value)
			{
				this.dieReason = -1;
				this.deathTimer.stop();
				return;
			}

			if (!this.killed)
				this.lastKiller = -1;

			this.killed = false;

			if (!(this is HeroTwoShamans) || !this.shaman)
			{
				this.deathTimer.reset();
				this.deathTimer.start();
			}

			this.left = false;
			this.right = false;
			this.up = false;
			this.gummed = false;
			this.setOnFire(false);
			this.hover = false;
			this.ghost = false;

			setCurseView(null);

			releaseAcorn();

			this.castItems.reset();

			onCompleteRespawnVitality();

			dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_MAGIC_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_ROPE));
			dispatchEvent(new SquirrelEvent(SquirrelEvent.DIE, this));
		}

		public function getPosition():Point
		{
			var v:b2Vec2 = this.body.GetPosition();
			return new Point(v.x * Game.PIXELS_TO_METRE, v.y * Game.PIXELS_TO_METRE);
		}

		public function setMode(mode:int):void
		{
			this.heroView.hasNut = (mode == NUT_MOD);

			if (!this.heroView.hasNut)
				return;

			if (this.isHare)
				grabAcorn();

			dispatchEvent(new SquirrelEvent(SquirrelEvent.ACORN, this));
		}

		public function get hasNut():Boolean
		{
			return this.heroView.hasNut;
		}

		public function update(timeStep:Number = 0):void
		{
			this.perkController.updatePerks(timeStep);
			this.behaviourController.update(timeStep);

			if (this.isSelf)
			{
				if (this.currentHighlight != Settings.highlight)
				{
					this.currentHighlight = Settings.highlight;

					if (_lighting && heroView && heroView.getStarlingView())
					{
						_lighting.alpha = this.currentHighlight * 0.4;
						_lighting.alignPivot();
						_lighting.y = -_lighting.height / 2.5;
						_lighting.scaleX = heroView.scaleX;
						_lighting.scaleY = heroView.scaleY;
						heroView.getStarlingView().addChildAt(_lighting.getStarlingView(), 0);
					}
				}
			}

			for each(var behaviour:Behaviour in this.behaviours)
				behaviour.update(timeStep);

			if (this.controller != null)
				this.controller.active = this.heroView.visible && !this._stuck;

			if (this.isDead)
				return;

			physicUpdate(timeStep);

			this.behaviourController.updatePhysic(timeStep);

			if (!this.isSelf)
				return;

			checkDie();
		}

		public function physicUpdate(timeStep:Number = 0):void
		{
			if (timeStep) {}

			if (this.footSensor && this.footSensor.onFloor && this.footSensor.canJump)
			{
				this.avalibleJumpCount.value = this.maxInAirJumps;
				this.availableFallJumpCount.value = this.maxFallJumps;
				this._lastJumpPos = null;
			}

			if (this.resetMass)
			{
				this.mass = this.mass;
				this.resetMass = false;
			}

			if (this.resetI)
			{
				this.inertia = this.inertia;
				this.resetI = false;
			}

			if (this.resetRestitution)
			{
				this.mainFixture.SetRestitution(_restitution);
				this.resetRestitution = false;
			}

			this.body.SetAwake(true);

			if (this.heroView.fly && this.footSensor.onFloor && isSelf)
				playLandingSound();

			this.heroView.fly = this.hover || (!this.footSensor.onFloor && !((this.swim || this.climbing) && (this.left || this.right || this.up) || (this.submerge)));

			this.heroView.running = (this.left || this.right) && !(this.left && this.right) && (!this.heroView.isCasting || (this.heroView.isCasting && this.useRunningCast)) || (this.up && this.swim) || (this.up && this.climbing);

			this.heroView.update();

			this.mainFixture.SetFriction(this.heroView.running ? 0 : _friction);

			var velocity:b2Vec2 = this.body.GetLinearVelocity().Copy();
			var inverseSpeed:Boolean = this.body.GetAngle() != 0;

			if (inverseSpeed)
				velocity.MulM(this.body.GetTransform().R.GetInverse(new b2Mat22));

			if (this.up && this.fallVelocities.length != 0)
			{
				for each (var _velocity:Number in this.fallVelocities)
					if (velocity.y > _velocity)
						velocity.y = _velocity;
			}

			if ((this.left || this.right) && !(this.left && this.right) && !this.heroView.isCasting)
			{
				var contusedFactor:Number = this.behaviourController.getState(StateContused) != null ? -1 : 1;
				contusedFactor *= this.questFactor;

				if (this.footSensor.onFloor)
				{
					velocity.x += (left ? -1 : 1) * (runAcceleration / 2 * this.scale) * contusedFactor;
					velocity.x = (Math.abs(velocity.x) < actualSpeed) ? velocity.x : ((left ? -actualSpeed : actualSpeed) * contusedFactor);
				}
				else if (this.up)
				{
					velocity.x += (left ? -1 : 1) * (runAcceleration / 2 * this.scale) * contusedFactor;
					velocity.x = (Math.abs(velocity.x) < actualSpeed) ? velocity.x : ((left ? -actualSpeed : actualSpeed) * contusedFactor * this.accelerateFactor);
				}
				else
				{
					velocity.x += (left ? -1 : 1) * (airAcceleration * this.scale) * contusedFactor;
					velocity.x = (Math.abs(velocity.x) < actualSpeed) ? velocity.x : ((left ? -actualSpeed : actualSpeed) * contusedFactor);
				}

				if (this.swim)
					velocity.x *= this._swimFactor;

				this.heroView.direction = this.left && (contusedFactor > 0) || !this.left && (contusedFactor < 0);
			}

			if (inverseSpeed)
				velocity.MulM(this.body.GetTransform().R);

			this.body.SetLinearVelocity(velocity);

			if ((this.isHare && !(this.heroView.hareView as HareView).rock || this.isScrat) && this.hasNut)
			{
				if (self && !self.hasNut && !(this.isHare && self.isHare) && !(this.isScrat && !this.acornShare))
				{
					var pos:b2Vec2 = self.position.Copy();
					pos.Subtract(this.position);
					if (pos.Length() < 4)
					{
						(this.game.map.get(AcornBody)[0] as AcornBody).onAcorn(new DetectHeroEvent(self, false));
						if (this.isScrat)
							Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.PLAY_GIVE_NUT, 1, this.id);
					}
				}
			}

			this.swim = false;
			this.submerge = false;
			this.heroView.messageSprite.scaleX = this.scale > 0 ? 1 : -1;

			if (this.interpolateVector && (this.heroView.running || this.heroView.fly))
			{
				var delta:b2Vec2 = this.interpolateVector.Copy();
				delta.Normalize();
				delta.Multiply(INTERPOLATION_STEP);
				this.position.Add(delta);
				this.body.SetPosition(this.position);

				this.interpolateVector.Subtract(delta);
				if (this.interpolateVector.Length() < INTERPOLATION_STEP)
					this.interpolateVector = null;
			}

			updatePosition();

			this.extGravity.SetZero();

			this.useGravity = true;
		}

		public function showCircle():void
		{
			if (this.game.cast.radius == 0)
				return;

			this.heroView.circle.visible = true;
			updateCirclePosition();
		}

		public function setCircleWidth(width:Number):void
		{
			var isPlaying:Boolean = this.heroView.circle.currentFrame > 1;

			if (isPlaying)
			{
				this.heroView.circle.visible = false;
				var currentFrame:int = this.heroView.circle.currentFrame;
				this.heroView.circle.gotoAndStop(0);
			}
			this.heroView.circle.rotation = 0;
			this.heroView.circle.scaleXY(int(width) / this.heroView.circleDefSize);

			if (isPlaying)
			{
				this.heroView.circle.gotoAndStop(currentFrame);
				this.heroView.circle.visible = true;
			}

			updateCirclePosition();
		}

		public function removeCircle():void
		{
			this.heroView.circle.visible = false;
		}

		public function initPerks():void
		{
			this.perkController.initManaPerk();

			if (this.id == Game.selfId)
				PerksToolBar.hero = this;
		}

		public function initFastPerks():void
		{
			if (!this.perkController.squirrelPerksAvailable || this.id != Game.selfId)
				return;

			FastPerksBar.load();
			FastPerksBar.hero = this;
		}

		public function wakeUp():void
		{
			this.isDead = (this.id == Game.selfId) ? this.isDead : false;

			show();
		}

		public function kill(killer_id:int = -1):void
		{
			if (this.id != Game.selfId && this.id > 0)
				return;

			if (this.vitalityTimer.running && this.id > 0)
				return;

			if (this.immortal)
				return;

			if (!this.isDead)
				playDeathSound();

			this.killed = true;
			this.lastKiller = killer_id;

			this.dead = true;
			this.dispatchEvent(new Event(Hero.EVENT_DIE));
		}

		public function simpleRespawn():void
		{
			this.vitalityTimer.reset();
			this.vitalityTimer.start();
			respawnAnimation();
		}

		public function respawn(withAnimation:int = RESPAWN_NONE):void
		{
			if (!this.isDead)
				return;

			if (this.body)
				this.body.renewTransform();

			dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_MAGIC_JOINT));
			dispatchEvent(new Event(Hero.EVENT_BREAK_ROPE));

			this.dead = false;
			this.gummed = false;
			this.setOnFire(false);
			this.ghost = false;

			this.velocity = new b2Vec2();
			this.heroView.resetEmotion();

			if (this.player.id == Game.selfId)
				show();

			switch (withAnimation)
			{
				case RESPAWN_SIMPLE:
					simpleRespawn();
					break;
				case RESPAWN_HARD:
					hardRespawnAnimation();
					break;
			}

			if (this.sendMove && this.isSelf)
				sendLocation();
			dispatchEvent(new SquirrelEvent(SquirrelEvent.RESPAWN, this));
		}

		public function jump(start:Boolean):void
		{
			this.up = start;

			if (this.heroView.isCasting)
				return;

			var stateFlight:IStateActive = this.behaviourController.getState(StateFlight) as StateFlight;
			if (!stateFlight)
				stateFlight = this.behaviourController.getState(StateFlightCat) as StateFlightCat;
			if (stateFlight != null)
			{
				stateFlight.active = start;
				return;
			}

			if (!start)
				return;

			var hangOnRope:Boolean = this.hangOnRope;

			dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));
			dispatchEvent(new Event(Hero.EVENT_UP));

			if (hangOnRope || this.behaviourController.getState(StateBanshee) != null)
				return;

			if (this.footSensor.onFloor || this.avalibleJumpCount.value > 0 || this.availableFallJumpCount.value > 0 || this._inBubble)
			{
				var canJump:Boolean = false;

				if (this.footSensor.onFloor && this.footSensor.canJump)
				{
					canJump = true;
					this._lastJumpPos = this.position.Copy();
				}
				else
				{
					canJump = this._inBubble;

					if (!canJump && this.availableFallJumpCount.value > 0)
					{
						if (this._lastJumpPos && !this.jumpFalling)
						{
							this.availableFallJumpCount.value--;
							canJump = true;
						}
					}

					if (!canJump && this.avalibleJumpCount.value > 0)
					{
						if (this.id == Game.selfId)
							GameSounds.playUnrepeatable("double_jump");

						dispatchEvent(new Event(Hero.EVENT_DOUBLE_JUMP));

						this.avalibleJumpCount.value--;
						canJump = true;
					}
				}

				if (!canJump)
					return;

				if (this.id == Game.selfId)
					GameSounds.play('jump');

				velocity.MulM(this.body.GetTransform().R.GetInverse(new b2Mat22));

				velocity.y = this.footSensor.onFloor ? -this.actualJumpVelocity : - this.actualJumpVelocity * this.inAirJumpFactor;

				velocity.MulM(this.body.GetTransform().R);
				this.body.SetLinearVelocity(velocity);
			}
			dispatchEvent(new Event(Hero.EVENT_UP_END));
		}

		public function moveLeft(start:Boolean):void
		{
			if (this.heroView.isCasting && !this.useRunningCast && start)
				return;

			this.left = start;

			if (start)
				this.heroView.direction = true;
		}

		public function moveRight(start:Boolean):void
		{
			if (this.heroView.isCasting && !this.useRunningCast && start)
				return;

			this.right = start;

			if (start)
				this.heroView.direction = false;
		}

		public function grabAcorn():void
		{
			if (this.isHare && !this.acornGrabbed)
			{
				var soundIndex:int = Math.random() * SoundConstants.ACORN_SOUNDS_HARE.length;
				GameSounds.playUnrepeatable(SoundConstants.ACORN_SOUNDS_HARE[soundIndex], HareView.SOUND_PROBABILITY);
			}

			var acorns:Array = this.game.map.get(AcornBody);

			this.acornGrabbed = true;

			for each(var acorn:AcornBody in acorns)
				acorn.alpha = 0;
		}

		public function releaseAcorn():void
		{
			if (!this.acornGrabbed)
				return;

			this.acornGrabbed = false;

			for each (var hero:Hero in this.game.squirrels.players)
			{
				if (!hero.acornGrabbed)
					continue;
				return;
			}

			if (!this.game.map)
				return;

			var acorns:Array = this.game.map.get(AcornBody);
			for each(var acorn:AcornBody in acorns)
				acorn.alpha = 1;
		}

		public function setController(controller:ControllerHero):void
		{
			if (this.controller)
				this.controller.remove();

			this.controller = controller;

			if (this.controller == null)
				return;

			this.controller.stoped = this.isStoped;
			this.controller.active = this.heroView.visible;
		}

		public function beginContact(contact:b2Contact):void
		{
			var data0:* = contact.GetFixtureA().GetBody().GetUserData();
			var data1:* = contact.GetFixtureB().GetBody().GetUserData();

			if (!(data0 is Hero) || !(data1 is Hero))
				return;
			if (!isSelf)
				return;

			var otherHero:Hero = (data0 == this ? data1 : data0);

			if (otherHero.gummed && !this.isHare && !this.isDead)
				this.game.squirrels.createGum(this.id, otherHero.id);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (this.ghost || this.behaviourController.getState(StateBanshee) != null)
				contact.SetEnabled(false);

			var object:* = contact.GetFixtureA().GetBody().GetUserData();
			if (object == this)
				object = contact.GetFixtureB().GetBody().GetUserData();

			if (object is PoiseInvisible)
			{
				if (!this.transparent)
					contact.SetEnabled(false);
			}
			else if ((object is Poise) && this.transparent)
				contact.SetEnabled(false);

			if (this.vitalityTimer.running && (object is IShoot || object is DragonFlamer))
				contact.SetEnabled(false);

			if ((object is GameBody) && (object as GameBody).ghost)
				contact.SetEnabled(false);

			if ((object is IPersonalObject) && (object as IPersonalObject).breakContact(this.id))
				contact.SetEnabled(false);

			if (object is PlatformTarBody)
			{
				if (this.friction <= 0)
					contact.SetEnabled(false);
				if (contact.IsEnabled())
					(object as PlatformTarBody).setHeroStuck(this);
			}

			if (!(object is Hero))
				return;

			if (this.isHare && !(world.userData as SquirrelGame).contactFilter.ShouldCollide(contact.GetFixtureA(), contact.GetFixtureB()))
			{
				contact.SetEnabled(false);
				return;
			}

			var otherHero:Hero = object as Hero;

			if (this.isHare && otherHero.gummed && !this.colideWithSquirrels)
				contact.SetEnabled(false);

			if (this.gummed || otherHero.gummed)
				contact.SetEnabled(false);

			if (!this.headWalker)
				return;

			if (this.collideSquirrels || otherHero.collideSquirrels)
			{
				contact.SetEnabled(true);
				return;
			}

			contact.SetEnabled(this.body.GetLocalVector(otherHero.position).y - this.body.GetLocalVector(this.position).y > 3.5 * otherHero.scale);

			if (otherHero.headWalker && this.body.GetLocalVector(this.position).y - this.body.GetLocalVector(otherHero.position).y > 3.5 * this.scale)
				contact.SetEnabled(true);
		}

		public function get position():b2Vec2
		{
			if (!this.body)
				return new b2Vec2();

			return this.body.GetPosition();
		}

		public function set position(value:b2Vec2):void
		{
			if (!this.body)
				return;

			this.body.SetPosition(value);
		}

		public function get velocity():b2Vec2
		{
			if (!this.body)
				return new b2Vec2();
			return this.body.GetLinearVelocity();
		}

		public function set velocity(value:b2Vec2):void
		{
			if (!this.body)
				return;
			this.body.SetLinearVelocity(value);
		}

		public function changeView(view:Sprite = null, needHeroScaleX:Boolean = true):void
		{
			var scale:Number = this.scale;
			this.scale = 1.0;

			this.heroView.setView(view, needHeroScaleX);

			this.scale = scale;
		}

		public function addView(view:DisplayObject, addOver:Boolean = false, needHeroScaleX:Boolean = true):void
		{
			this.heroView.addView(view, addOver, needHeroScaleX);
		}

		public function addViewButton(view:DisplayObject):void
		{
			if (this.viewButton is KickButton)
				(this.viewButton as KickButton).reset();

			if (this.viewButton && this.viewButton.parent)
				this.viewButton.parent.removeChild(this.viewButton);

			this.viewButton = view;

			this.viewButton.y = this.heroView.y;
			addChild(this.viewButton);
		}

		public function addBuff(buff:BuffRadialView, buffTimer:Timer = null):void
		{
			if (!this.isSelf || !this.buffView || !buff)
				return;

			this.buffView.addBuff(buff, buffTimer);
		}

		public function removeBuff(buff:BuffRadialView, buffTimer:Timer = null):void
		{
			if (!this.isSelf || !this.buffView || !buff)
				return;

			this.buffView.resetBuff(buff, buffTimer);
		}

		public function toggleBuff(value:Boolean):void
		{
			if (!this.isSelf || !this.buffView)
				return;

			this.buffView.visible = value;
		}

		public function sendSmile(type:int):void
		{
			if (type == EMOTION_NONE)
				return;

			this.heroView.sendSmile(type);
		}

		public function get team():int
		{
			return this._team;
		}

		public function set team(value:int):void
		{
			if (this._team == value)
				return;

			this._team = value;

			this.heroView.team = this.team;
			dispatchEvent(new SquirrelEvent(SquirrelEvent.TEAM, this));
		}

		public function get mass():int
		{
			return this._mass;
		}

		public function set mass(value:int):void
		{
			this._mass = value;

			var massData:b2MassData = new b2MassData();
			this.body.GetMassData(massData);
			massData.mass = value;
			if (this.body.GetWorld().IsLocked())
			{
				this.resetMass = true;
				return;
			}
			this.body.SetMassData(massData);
		}

		public function get inertia():Number
		{
			return this._inertia;
		}

		public function set inertia(value:Number):void
		{
			this._inertia = value;

			var massData:b2MassData = new b2MassData();
			this.body.GetMassData(massData);
			massData.I = value;
			if (this.body.GetWorld().IsLocked())
			{
				this.resetI = true;
				return;
			}
			this.body.SetMassData(massData);
		}

		public function get inAirJumpFactor():Number
		{
			return this._inAirJumpFactor;
		}

		public function set inAirJumpFactor(value:Number):void
		{
			this._inAirJumpFactor = value;
		}

		public function get maxInAirJumps():int
		{
			return this._maxInAirJumps.value;
		}

		public function set maxInAirJumps(value:int):void
		{
			this._maxInAirJumps.value = value;
		}

		public function get maxFallJumps():int
		{
			return this._maxFallJumps.value;
		}

		public function set maxFallJumps(value:int):void
		{
			this._maxFallJumps.value = value;
		}

		public function get runAcceleration():int
		{
			return this._runAcceleration;
		}

		public function set runAcceleration(value:int):void
		{
			this._runAcceleration = value;
		}

		public function get swimFactor():Number
		{
			return this._swimFactor;
		}

		public function set swimFactor(value:Number):void
		{
			this._swimFactor = value;
		}

		public function get actualSpeed():Number
		{
			return this._runSpeed * (this.isHare ? HARE_RUN_FACTOR : (this.behaviourController.getState(StateContused) != null ? CONTUSED_RUN_FACTOR : 1));
		}

		public function get runSpeed():Number
		{
			return this._runSpeed;
		}

		public function set runSpeed(value:Number):void
		{
			this._runSpeed = value;
		}

		public function get airAcceleration():int
		{
			return this._airAcceleration.value;
		}

		public function set airAcceleration(value:int):void
		{
			this._airAcceleration.value = value;
		}

		public function get jumpVelocity():int
		{
			return this._jumpVelocity.value;
		}

		public function set jumpVelocity(value:int):void
		{
			this._jumpVelocity.value = value;
		}

		public function get actualJumpVelocity():int
		{
			if (this.isHare)
				return this.jumpVelocity + HARE_JUMP_FACTOR;
			if (this.isDragon)
				return this.jumpVelocity + DRAGON_JUMP_FACTOR;

			return this.jumpVelocity;
		}

		public function get friction():Number
		{
			return this._friction;
		}

		public function set friction(value:Number):void
		{
			this._friction = value;
		}

		public function set restitution(value:Number):void
		{
			this._restitution = value;
		}

		public function get scale():Number
		{
			return this._scale;
		}

		public function set scale(value:Number):void
		{
			if (this.onRemove)
				return;

			if (value == 1)
			{
				for each(var perk:PerkShaman in this.perkController.perksShaman)
				{
					if (perk is PerkShamanBigHead && perk.active)
						var shamanScale:Number = PerkShamanBigHead(perk).scale;
				}
			}

			this._scale = value;

			this.heroView.scale = shamanScale || value;

			var shape:b2CircleShape = new b2CircleShape(2 * value);
			this.mainFixture.GetShape().Set(shape);

			shape = new b2CircleShape(1.9 * value);
			shape.SetLocalPosition(new b2Vec2(0, 0.2 * value));
			this.footSensorFixture.GetShape().Set(shape);

			dispatchEvent(new Event(Hero.EVENT_SCALE));
		}

		public function get headWalker():Boolean
		{
			return this._headWalker > 0;
		}

		public function set headWalker(value:Boolean):void
		{
			this._headWalker = Math.max(0, this._headWalker + (value ? 1 : -1));

			var mainFilter:b2FilterData = this.mainFixture.GetFilterData();
			mainFilter.categoryBits = (this.headWalker ? mainFilter.categoryBits | CollisionGroup.HERO_HEAD_WALKER : mainFilter.categoryBits & ~CollisionGroup.HERO_HEAD_WALKER);
			mainFilter.maskBits = (this.headWalker ? mainFilter.maskBits | CollisionGroup.HERO_CATEGORY : mainFilter.maskBits & ~CollisionGroup.HERO_CATEGORY);
			this.mainFixture.SetFilterData(mainFilter);

			var sensorFilter:b2FilterData = this.footSensorFixture.GetFilterData();
			sensorFilter.categoryBits = (this.headWalker ? sensorFilter.categoryBits | CollisionGroup.HERO_HEAD_WALKER_SENSOR : sensorFilter.categoryBits & ~CollisionGroup.HERO_HEAD_WALKER_SENSOR);
			sensorFilter.maskBits = (this.headWalker ? sensorFilter.maskBits | CollisionGroup.HERO_CATEGORY : sensorFilter.maskBits & ~CollisionGroup.HERO_CATEGORY);
			this.footSensorFixture.SetFilterData(sensorFilter);
		}

		public function get collideSquirrels():Boolean
		{
			return this._collideSquirrels;
		}

		public function set collideSquirrels(value:Boolean):void
		{
			this._collideSquirrels = value;

			this.headWalker = value;
		}

		public function get transparent():Boolean
		{
			return this._transparent;
		}

		public function set transparent(value:Boolean):void
		{
			this._transparent = value;
			this.heroView.alpha = value ? 0.4 : 1;
			if (this.transparentTween != null)
				this.transparentTween.kill();
			this.transparentTween = null;
		}

		public function get sendMove():Boolean
		{
			return this._sendMove;
		}

		public function set sendMove(value:Boolean):void
		{
			this._sendMove = value;
		}

		public function set wizard(value:Boolean):void
		{
			this._wizard = value;

			if (this.heroView.aura && this.heroView.aura.parent && !value)
				this.heroView.aura.parent.removeChild(this.heroView.aura);
			if (!this.heroView.aura && value)
			{
				this.heroView.aura = new WizardAura();
				this.heroView.aura.mouseEnabled = false;
			}
			if (this.heroView.aura && !this.heroView.aura.parent && value)
				this.game.addChild(this.heroView.aura);

			if (value)
				updateCirclePosition();
		}

		public function get wizard():Boolean
		{
			return this._wizard;
		}

		public function get perksAvailable():Boolean
		{
			return this._perksAvailable;
		}

		public function set perksAvailable(value:Boolean):void
		{
			if (this._perksAvailable == value)
				return;

			this._perksAvailable = value;
			FooterGame.updatePerkButtons();
		}

		public function teleport(destination:int, position:b2Vec2 = null):void
		{
			switch (destination)
			{
				case TELEPORT_DESTINATION_ACORN_HOLLOW:
					Connection.sendData(PacketClient.PING, 1);
					break;
				case TELEPORT_DESTINATION_SHAMAN:
					if (!this.shaman || this.isDead)
						position = this.game.squirrels.getPositionRebornSkill(this.id, this.team);
					teleportTo(position);
					if (this is HeroTwoShamans && this.isSelf)
						setTimeout(sendLocation, 0);
					break;
				case TELEPORT_DESTINATION_RESPAWN:
					if (this.game.map.respawnPosition)
						teleportTo(this.game.map.respawnPosition);
					else
						teleport(TELEPORT_DESTINATION_SHAMAN);
					break;
			}
		}

		public function teleportTo(position:b2Vec2):void
		{
			if (!this.isExist)
				return;

			dispatchEvent(new Event(Hero.EVENT_TELEPORT));

			this.velocity = new b2Vec2();

			if (position)
			{
				this.position = position;
				updatePosition();
			}

			if (!this.shaman || this.isDead)
			{
				if (this is HeroBattle && this.id == Game.selfId)
				{
					this.game.camera.enabled = true;
					if (this.game.rebornTimer != null)
						this.game.rebornTimer.reset();
				}

				if (this.isDead && !this.inHollow && !this.isDragon && !this.isHare && !(this is HeroTwoShamans))
					hardRespawnAnimation();

				if (this.isHare)
					this.setMode(Hero.NUDE_MOD);

				setTimeout(onTeleport, 0);
				return;
			}

			this.heroView.resetEmotion();
			show();
		}

		public function magicTeleportTo(position:b2Vec2):void
		{
			var animationPos:Point = game.squirrels.globalToLocal(this.heroView.localToGlobal(new Point()));
			var teleportIn:TeleportIn = new TeleportIn();
			var teleportOut:TeleportOut = new TeleportOut();

			teleportIn.x = animationPos.x;
			teleportIn.y = animationPos.y;

			var onTeleportOut:Function = function(e:Event):void
			{
				teleportOut.removeEventListener(Event.CHANGE, onTeleportOut);

				if (teleportOut.parent)
					teleportOut.parent.removeChild(teleportOut);

				isStoped = false;
			};

			var afterTeleport:Function = function():void
			{
				animationPos = game.squirrels.globalToLocal(heroView.localToGlobal(new Point()));
				teleportOut.x = animationPos.x;
				teleportOut.y = animationPos.y;
				teleportOut.play();
				game.squirrels.addChild(teleportOut);
				teleportOut.addEventListener(Event.CHANGE, onTeleportOut);
			};

			var onTeleportIn:Function = function(e:Event):void
			{
				teleportIn.removeEventListener(Event.CHANGE, onTeleportIn);

				if (teleportIn.parent)
					teleportIn.parent.removeChild(teleportIn);

				if (isDead)
				{
					isStoped = false;
					return;
				}
				teleportTo(position);
				setTimeout(afterTeleport, 0);
			};

			teleportIn.addEventListener(Event.CHANGE, onTeleportIn);
			teleportIn.play();
			this.game.squirrels.addChild(teleportIn);

			this.isStoped = true;
		}

		public function get sideIcon(): StarlingAdapterSprite
		{
			if (!this.icon)
				this.icon = new SideIconView(SideIconView.COLOR_YELLOW, SideIconView.ICON_SQUIRREL);
			return this.icon;
		}

		public function get showIcon():Boolean
		{
			if (!this.icon)
				return false;
			var show:Boolean = (!this.isDead && !this.inHollow && this.heroView.visible) && (this.shaman || this.isHare || this.id == Game.selfId);
			if (show)
			{
				(this.icon as SideIconView).color = (this.id == Game.selfId) ? SideIconView.COLOR_YELLOW : (this.isHare ? (hasNut ? SideIconView.COLOR_GREEN : SideIconView.COLOR_RED) : ((this.team == TEAM_BLUE) || (this.team == TEAM_NONE) ? SideIconView.COLOR_BLUE : SideIconView.COLOR_RED));
				(this.icon as SideIconView).icon = this.isHare ? SideIconView.ICON_HARE : (this.shaman ? SideIconView.ICON_SHAMAN : (this.isDragon ? SideIconView.ICON_DRAGON : SideIconView.ICON_SQUIRREL));
			}
			if (this.isVictim || this.isVendigo)
			{
				(this.icon as SideIconView).color = SideIconView.COLOR_RED;
				(this.icon as SideIconView).icon = this.isVendigo ? SideIconView.ICON_VENDIGO : SideIconView.ICON_VICTIM;
				return true;
			}

			return show;
		}

		public function get isHare():Boolean
		{
			return this._isHare;
		}

		public function set isHare(value:Boolean):void
		{
			if (this._isHare == value)
				return;

			this._isHare = value;
			this.heroView.isHare = value;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.HARE, this));
			Logger.add("Hare ", this.id, value);

			if (!value || this.perkController.perksHare.length != 0)
				return;

			this.perkController.initHarePerks();

			if (!this.isSelf)
				return;

			HarePerksToolBar.hero = this;
		}

		public function get isSquirrel():Boolean
		{
			return !(this.isDragon || this.isScrat || this.isHare || this.shaman);
		}

		public function get isScrat():Boolean
		{
			return this._isScrat && !this.isDragon && !this.isHare && !this.shaman;
		}

		public function set isScrat(value:Boolean):void
		{
			if (this._isScrat == value)
				return;

			this._isScrat = value;
			this.heroView.isScrat = value;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.SCRAT, this));
			Logger.add("Scrat ", this.id, value);

			if (!value || this.perkController.perksCharacter.length != 0)
				return;

			Logger.add("Init Scrat Perks", this.id);
			//this.perkController.initScratPerks();
		}

		public function get isDragon():Boolean
		{
			return this._isDragon;
		}

		public function set isDragon(value:Boolean):void
		{
			if (this._isDragon == value)
				return;

			this._isDragon = value;
			this.heroView.isDragon = value;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.DRAGON, this));
			Logger.add("Dragon ", this.id, value);

			if (!value || this.perkController.perksDragon.length != 0)
				return;

			Logger.add("Init Dragon Perks", this.id);

			this.perkController.initDragonPerks();

			if (!this.isSelf)
				return;

			DragonPerksToolBar.hero = this;
		}

		public function get colideWithSquirrels():Boolean
		{
			return this._colideWithSquirrels;
		}

		public function set colideWithSquirrels(value:Boolean):void
		{
			this._colideWithSquirrels = value;

			var mainFilter:b2FilterData = this.mainFixture.GetFilterData();
			mainFilter.categoryBits = (value ? mainFilter.categoryBits | CollisionGroup.OBJECT_CATEGORY : mainFilter.categoryBits & ~CollisionGroup.OBJECT_CATEGORY);
			mainFilter.maskBits = (value ? mainFilter.maskBits | CollisionGroup.HERO_CATEGORY : mainFilter.maskBits & ~CollisionGroup.HERO_CATEGORY);
			this.mainFixture.SetFilterData(mainFilter);

			var sensorFilter:b2FilterData = this.footSensorFixture.GetFilterData();
			sensorFilter.categoryBits = (value ? sensorFilter.categoryBits | CollisionGroup.OBJECT_CATEGORY : sensorFilter.categoryBits & ~CollisionGroup.OBJECT_CATEGORY);
			sensorFilter.maskBits = (value ? sensorFilter.maskBits | CollisionGroup.HERO_CATEGORY : sensorFilter.maskBits & ~CollisionGroup.HERO_CATEGORY);
			this.footSensorFixture.SetFilterData(sensorFilter);
		}

		public function get gummed():Boolean
		{
			return this._gummed;
		}

		public function set gummed(value:Boolean):void
		{
			this._gummed = value;

			var mainFilter:b2FilterData = this.mainFixture.GetFilterData();
			mainFilter.categoryBits = (value ? mainFilter.categoryBits | CollisionGroup.HERO_GUMMED : mainFilter.categoryBits & ~CollisionGroup.HERO_GUMMED);
			mainFilter.maskBits = ((value || this.colideWithSquirrels) ? mainFilter.maskBits | CollisionGroup.HERO_CATEGORY : mainFilter.maskBits & ~CollisionGroup.HERO_CATEGORY);

			this.mainFixture.SetFilterData(mainFilter);
			this.heroView.gummed = value;

			if (value)
			{
				var timeout:int = (ScreenGame.mode == Locations.HARD_MODE) ? 10000 : 30000;
				setTimeout(breakGum, timeout);
			}
		}

		public function get onFire():Boolean
		{
			return this._onFire;
		}

		public function setOnFire(value:Boolean, type:String = CollectionEffects.EFFECTS_SQUIRREL_FIRE):void
		{
			if (this._onFire == value)
				return;

			this._onFire = value;

			if (value)
				applyEffect(type);
			else
				disableEffect(this.effects[CollectionEffects.EFFECTS_SQUIRREL_FIRE] ? CollectionEffects.EFFECTS_SQUIRREL_FIRE : CollectionEffects.EFFECTS_SQUIRREL_FIRE_BLUE);
		}

		public function applyEffect(type:String, index:int = 1, autoStart:Boolean = true):ParticlesEffect
		{
			var effect:ParticlesEffect = collectionEffect.getEffectByName(type);
			if (autoStart)
				effect.start();

			this.effects[type] = effect;

			this.getStarlingView().parent.addChildAt(effect.view, this.getStarlingView().parent.getChildIndex(this.getStarlingView()) + index);

			return effect;
		}

		public function disableEffect(type:String):void
		{
			var effect:ParticlesEffect = this.effects[type];
			if (effect)
			{
				effect.stop();
				collectionEffect.removeEffect(effect);
				delete this.effects[type];
			}
		}

		public function set stuck(value:Boolean):void
		{
			if (this._stuck == value)
				return;

			this._stuck = value;
			this.isStoped = value;
			if (value)
				setTimeout(this.heroView.setEmotion, 0, Hero.EMOTION_CRY);
			else if (this.heroView.emotionType == Hero.EMOTION_CRY)
				this.heroView.resetEmotion();
		}

		public function set inBubble(value:Boolean):void
		{
			if (this._inBubble == value)
				return;

			this._inBubble = value;
			this._inAirJumpFactor *= value ? 3 : (1 / 3);
		}

		public function get inBubble():Boolean
		{
			return this._inBubble;
		}

		public function get immortal():Boolean
		{
			return this._immortal;
		}

		public function set immortal(value:Boolean):void
		{
			if (this._immortal == value)
				return;

			this._immortal = value;
			this.heroView.immortal = value;
		}

		public function get frozen():Boolean
		{
			return this._frozen;
		}

		public function set frozen(value:Boolean):void
		{
			if (this._frozen == value)
				return;

			this._frozen = value;
			this.isStoped = value;
		}

		public function get isCasting():Boolean
		{
			return this._isCasting;
		}

		public function set isCasting(value:Boolean):void
		{
			if (this._isCasting == value)
				return;

			this.heroView.isCasting = this._isCasting = value;

			if (!value)
				return;

			if (this.castEffect == null)
				return;

			this.castEffect.view.visible = true;

			var end:Function = function():void
			{
				if (castEffect == null)
					return;

				castEffect.view.visible = false;
			};

			var start:Function = function():void
			{
				if (castEffect == null)
					return;

				var tween:Tween = new Tween(castEffect.view, 0.3);
				tween.delay = 0.3;
				tween.fadeTo(0);
				tween.onComplete = end;
				Starling.juggler.add(tween);
			};

			var tween:Tween = new Tween(this.castEffect.view, 0.3);
			tween.fadeTo(1);
			tween.onComplete = start;
			Starling.juggler.add(tween);
		}

		public function setCurseView(view:DisplayObject):void
		{
			this.heroView.setCurseView(view);
			this.heroView.onCurse = (view != null) && !this.healedByDeath;
		}

		public function interpolate(value:b2Vec2):void
		{
			this.interpolateVector = value;
		}

		protected function updateCirclePosition():void
		{
			if (!this.isSelf && !(Screens.active as ScreenEdit))
				return;

			if (this.game.cast && this.heroView.circle.visible)
			{
				var radius:int = this.game.cast.radius;
				var circleCoords:Point = this.game.globalToLocal(this.localToGlobal(new Point(-radius, this.heroView.y - radius - 23)));
				this.heroView.circle.x = circleCoords.x;
				this.heroView.circle.y = circleCoords.y;
				this.heroView.circle.rotation = this.rotation;
			}

			if (!this.wizard || !this.heroView.aura.visible)
				return;

			circleCoords = this.game.globalToLocal(this.localToGlobal(new Point(-176, this.heroView.y - 201)));
			this.heroView.aura.x = circleCoords.x;
			this.heroView.aura.y = circleCoords.y;
			this.heroView.aura.rotation = this.rotation;
		}

		protected function onPlayerLoad(player:Player):void
		{
			player.removeEventListener(onPlayerLoad);

			if ((Screens.active is ScreenGame) && !Locations.currentLocation.teamMode)
			{
				var isScrat:Boolean = false;
				for (var i:int = 0; i < this.player['weared_packages'].length; i++)
					isScrat = isScrat || OutfitData.isScratSkin(this.player['weared_packages'][i]);
				var isScratty:Boolean = false;
				for (i = 0; i < this.player['weared_packages'].length; i++)
					isScratty = isScratty || OutfitData.isScrattySkin(this.player['weared_packages'][i]);

				this.isScrat = isScrat || isScratty;
			}

			this.heroView.setClothing(this.player['weared_packages'], this.player['weared_accessories']);

			initPerks();
			if (id == Game.selfId)
				initFastPerks();

			if (this.player['clan_id'] == 0)
			{
				this.heroView.clanName = "";
				return;
			}

			if (this.clan != null)
				return;

			this.clan = ClanManager.getClan(this.player['clan_id']);
			this.clan.addEventListener(ClanInfoParser.INFO | ClanInfoParser.TOTEMS | ClanInfoParser.TOTEMS_BONUSES | ClanInfoParser.STATE, onClanLoaded);
			ClanManager.request(this.player['clan_id'], true, ClanInfoParser.INFO | ClanInfoParser.TOTEMS | ClanInfoParser.TOTEMS_BONUSES | ClanInfoParser.STATE);
		}

		protected function get jumpFalling():Boolean
		{
			return ((this.body.GetLocalVector(this._lastJumpPos).y - this.body.GetLocalVector(this.position).y) > 0);
		}

		private function onCastUpdate(e:TimerEvent):void
		{
			if (this.id != Game.selfId && this.id > 0)
				return;

			this.heroView.castProgress = Math.min(((getTimer() - castStartTime) / castTime) * 100, 100);
		}

		private function onClanLoaded(clan:Clan, type:uint):void
		{
			if (type && clan) {/* unused */}

			if (this.clan.state == PacketServer.CLAN_STATE_SUCCESS)
				this.heroView.clanName = this.clan.name;
			else
				this.heroView.clanName = "";

			this.perkController.updateTotemPerk(this.clan);
			this.clan.removeEventListener(onClanLoaded);
		}

		private function breakGum():void
		{
			this.gummed = false;
		}

		private function onCamera(e:SquirrelEvent):void
		{
			//if (this.isSelf)
			//	return;
			//Todo return when
			//this.heroView.filters = e.player == this && this.game.camera.enabled ? GLOW_FILTERS[2] : GLOW_FILTERS[0];
		}

		private function onCompleteDeath(e:TimerEvent):void
		{
			this.heroView.visible = !this.isDead;
			this.position = new b2Vec2();
			dispatchEvent(new MovieClipPlayCompleteEvent(MovieClipPlayCompleteEvent.DEATH));
		}

		protected function checkDie():void
		{
			var shift:int = 80;
			if (this.y + shift < -this.game.map.size.y + Game.ROOM_HEIGHT)
			{
				if (this.hangOnRope)
				{
					sendLocation(Keyboard.UP);
					jump(true);
					sendLocation(Keyboard.UP * (-1));
					jump(false);
				}
				else
				{
					setPosition(this.x, -this.game.map.size.y + Game.ROOM_HEIGHT - shift);
					sendLocation();
				}
			}

			if (this.x < -shift || this.x > this.game.map.size.x + shift)
			{
				playDeathSound();

				this.dieReason = Hero.DIE_FALL;
				this.dead = true;
				this.x += (this.x < 0 ? 90 : -90);
			}
			else if (this.y > 620)
			{
				playDeathSound();

				if ((this.x > -shift && this.x < 0) || (this.x > GameMap.gameScreenWidth && this.x < GameMap.gameScreenWidth))
					this.x += (this.x < 0 ? - this.x + 6 : 754 - this.x);

				this.dieReason = Hero.DIE_FALL;
				this.dead = true;
				this.y = this.y - 150;
			}
		}

		private function setPosition(x:int, y:int):void
		{
			this.body.SetPositionAndAngle(new b2Vec2(x / Game.PIXELS_TO_METRE, y / Game.PIXELS_TO_METRE), this.body.GetAngle());

			this.x = this.body.GetPosition().x * Game.PIXELS_TO_METRE;
			this.y = this.body.GetPosition().y * Game.PIXELS_TO_METRE + Y_POSITION_COEF;
		}

		protected function playLandingSound():void
		{
			if (!(this.footSensor.lastContact is ILandSound))
				return;
			var sound:String = (this.footSensor.lastContact as ILandSound).landSound;
			if (sound != "")
				GameSounds.playUnrepeatable(sound);
		}

		private function playDeathSound():void
		{
			if (this.isHare)
			{
				var index:int = Math.random() * SoundConstants.DEATH_SOUNDS_HARE.length;
				GameSounds.play(SoundConstants.DEATH_SOUNDS_HARE[index]);
				return;
			}

			index = int(Math.random() * SoundConstants.DEATH_SOUNDS.length);
			GameSounds.play(SoundConstants.DEATH_SOUNDS[index]);
		}

		private function initPhysic(x:int, y:int):void
		{
			this.bodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
			this.bodyDef.position.Set(this.heroView.width / (2 * Game.PIXELS_TO_METRE) + x / Game.PIXELS_TO_METRE, this.heroView.height / (2 * Game.PIXELS_TO_METRE) + y / Game.PIXELS_TO_METRE);
			this.bodyDef.allowSleep = true;
			this.body = this.world.CreateBody(this.bodyDef);

			this.mainFixture = this.body.CreateFixture(new b2FixtureDef(new b2CircleShape(2), null, 0, 0.1, 1, CollisionGroup.HERO_CATEGORY, CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY | CollisionGroup.HERO_DETECTOR_CATEGORY | CollisionGroup.HERO_HEAD_WALKER | CollisionGroup.HERO_HEAD_WALKER_SENSOR | CollisionGroup.HERO_GUMMED, 0, false));
			this.mainFixture.SetUserData(this);

			var polygonShape:b2CircleShape = new b2CircleShape(1.9 * _scale);
			polygonShape.SetLocalPosition(new b2Vec2(0, 0.2 * _scale));

			this.footSensorFixture = this.body.CreateFixture(new b2FixtureDef(polygonShape, null, 0, 0.1, 1, CollisionGroup.HERO_SENSOR_CATEGORY | CollisionGroup.HERO_CATEGORY, CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY, 0, false));
			this.footSensor = new HeroSensor(footSensorFixture, this);

			var massData:b2MassData = new b2MassData();
			massData.mass = mass;
			this.body.SetMassData(massData);

			this.body.SetUserData(this);

			ActiveBodiesCollector.addBody(this.body);
		}

		protected function updatePosition():void
		{
			this.x = this.body.GetPosition().x * Game.PIXELS_TO_METRE;
			this.y = this.body.GetPosition().y * Game.PIXELS_TO_METRE;

			var g:b2Vec2 = game.gravity.Copy();

			if (this.useGravity)
				g.Multiply(1 / 60);
			else
				g = new b2Vec2();
			var v:b2Vec2 = new b2Vec2(g.x + this.extGravity.x, g.y + this.extGravity.y);
			if (v.Length() == 0 && !this.torqueApplied)
			{
				updateCirclePosition();
				return;
			}

			if (this.body.GetAngle() != (Math.atan2(v.y, v.x) - Math.PI / 2) && !this.torqueApplied)
				this.body.SetAngle(Math.atan2(v.y, v.x) - Math.PI / 2);

			this.rotation = this.body.GetAngle() * Game.R2D;
			this.heroView.playerNameSprite.cacheAsBitmap = (this.rotation == 0);

			updateCirclePosition();
		}

		private function respawnAnimation():void
		{
			this.vitalityTween = TweenMax.to(this.heroView, 0.5, {'alpha': 0.2, 'onComplete': function():void
			{
				vitalityTween = TweenMax.to(heroView, 0.5, {'alpha': 1, 'onComplete': respawnAnimation});
			}});
		}

		private function hardRespawnAnimation():void
		{
			this.heroView.alpha = 0;
			var rebornAnimation:SquirrelRebornAnimation = new SquirrelRebornAnimation();
			rebornAnimation.y = 25;
			rebornAnimation.gotoAndPlay(0);
			rebornAnimation.addEventListener("SQUIRREL_ARISE", squirrelArise);
			rebornAnimation.addEventListener(Event.CHANGE, hardRespawnComplete);
			addChild(rebornAnimation);

			if(this.isSelf == true)
				GameSounds.play("respawn");
		}

		private function squirrelArise(e:Event):void
		{
			this.transparentTween = TweenMax.to(this.heroView, 1, {'alpha': (this.transparent ? 0.4 : 1)});
		}

		private function hardRespawnComplete(e:Event):void
		{
			(e.target as MovieClip).removeEventListener("SQUIRREL_ARISE", squirrelArise);
			if((e.target as MovieClip).parent)
				(e.target as MovieClip).parent.removeChild(e.target as MovieClip);
		}

		private function onCompleteRespawnVitality(e:TimerEvent = null):void
		{
			this.vitalityTimer.stop();

			this.heroView.alpha = this.transparent ? 0.4 : 1;

			if (this.vitalityTween == null)
				return;

			this.vitalityTween.kill();
			this.vitalityTween = null;
		}

		private function onTeleport():void
		{
			if (!this.isExist || this.inHollow)
				return;

			this.dead = false;
			dispatchEvent(new SquirrelEvent(SquirrelEvent.RESPAWN, this));

			if (this.game && this.game.squirrels)
				this.game.squirrels.checkSquirrelsCount();

			this.heroView.resetEmotion();
			show();
		}

		public function initClothesPerks(perks:Vector.<PacketRoundSkillsItemsCharactersSkills>):void
		{
			this.perkController.initClothesPerks(perks);

			if (this.isSelf)
			{
				ClothesToolBar.hero = this;
				FastPerksBar.hero = this;
			}
		}

		public function get isVisible():Boolean
		{
			return _isVisible;
		}

		public function set isVisible(value: Boolean):void
		{
			_isVisible = false;
		}

		private function initShamanPerks(shamanSkills:Vector.<PacketLoginShamanInfo>):void
		{
			if (this.perkController.perksShaman.length > 0 || !shamanSkills)
				return;

			this.perkController.initShamanPerk(shamanSkills);

			if (!this.isSelf)
				return;

			ShamanToolBar.hero = this;
			FastPerksBar.hero = this;
		}

		private function disposeAllParticleEffect(): void
		{
			for (var type:String in this.effects)
				disableEffect(type);
		}

		public function get isPlayedOnce():Boolean
		{
			return _isPlayedOnce;
		}
	}
}