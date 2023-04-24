package game.mainGame
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import dialogs.Dialog;
	import screens.ScreenStarling;
	import views.RebornTimer;

	import luaAlchemy.LuaAlchemy;

	import protocol.PacketServer;
	import protocol.packages.server.PacketRoomRound;

	import utils.InstanceCounter;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.collections.DisplayObjectManager;

	public class SquirrelGame extends StarlingAdapterSprite
	{
		static private const FIXED_TIMESTEP:Number = 1 / 60;
		static private const MAX_TIME:Number = 1 / 15;
		static private const VELOCITY_INTERATION:int = 8;
		static private const POSITION_INTERATION:int = 3;
		static private const USE_FIXED_TIMESTEP:Boolean = true;
		static private const LAGS_HIGH_BORDER:int = 200;
		static private const TIMESCALE:Number = 0.9;
		static public const TIMESCALE_NEWBIE:Number = 0.8;
		static public const DEFAULT_GRAVITY:b2Vec2 = new b2Vec2(0, 100);

		static private var _instance:SquirrelGame = null;

		private var _paused:Boolean = false;
		private var lastUpdate:int;
		private var elapsedTime:Number = 0;
		private var lagCounter:int = 0;
		private var lagWarningShowed:Boolean = false;
		private var _scriptUtils:ScriptUtils = null;
		private var hintArrows:Object = {};

		protected var _dialogResult:Dialog = null;
		protected var _simulate:Boolean = false;

		public var rebornTimer:RebornTimer = null;
		public var world:b2World = new b2World(DEFAULT_GRAVITY, true);
		public var map:GameMap;
		public var squirrels:SquirrelCollection;
		public var cast:Cast;
		public var camera:CameraController;
		public var sideIcons:SideIconsController;
		public var scripts:LuaAlchemy = new LuaAlchemy();
		public var contactFilter:ContactFilter = new ContactFilter();
		public var foreground:StarlingAdapterSprite = new StarlingAdapterSprite();

		public var timescale:Number = TIMESCALE;

		static public function get instance():SquirrelGame
		{
			return _instance;
		}

		public function SquirrelGame():void
		{
			_instance = this;

			Logger.add("SquirrelGame.SquirrelGame");
			super();
			InstanceCounter.onCreate(this);
			this.world.userData = this;

			this.foreground.mouseEnabled = false;
			this.foreground.mouseChildren = false;

			addChild(this.map);
			addChildStarling(this.squirrels);
			addChild(this.squirrels);
			addChildStarling(this.map.foregroundObjects);

			if (this.cast)
				addChildStarling(this.cast);

			this.world.SetContactListener(new GameContactListener(world));
			this.world.SetContactFilter(contactFilter);

			this.camera = new CameraController(this);

			this.sideIcons = new SideIconsController(this.map);
			addChildStarling(this.sideIcons);
			this._scriptUtils = new ScriptUtils(this);

			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
			onChangeScreenSize();
		}

		private function onChangeScreenSize(e: Event = null): void
		{
			if (FullScreenManager.instance().fullScreen && FullScreenManager.instance().needResize)
			{
				if (this.sideIcons)
					this.sideIcons.rectangle = new Rectangle(0, 40, GameMap.gameScreenWidth, GameMap.gameScreenHeight - 40);

				this.scaleFlashX = ScreenStarling.scaleFactorScreen;
				this.scaleFlashY = ScreenStarling.scaleFactorScreen;

				if (this.map)
					this.shift = this.shift;
			}
			else
			{
				if (this.sideIcons)
					this.sideIcons.rectangle = new Rectangle(0, 40, Config.GAME_WIDTH, Config.GAME_HEIGHT - 40);

				this.scaleFlashX = 1;
				this.scaleFlashY = 1;
			}
		}

		public function get scriptUtils():ScriptUtils
		{
			if (!this._scriptUtils)
			{
				Logger.add("Init LuaAlchemy");

				this.scripts = new LuaAlchemy();
				this._scriptUtils = new ScriptUtils(this);
			}

			return this._scriptUtils;
		}

		public function toggleResultVisible():void
		{
			if (!this._dialogResult)
				return;
			this._dialogResult.visible ? this._dialogResult.hide() : this._dialogResult.show();
		}

		public function round(packet: PacketRoomRound):void
		{
			this.cast.round(packet);
			this.map.round(packet);
			this.squirrels.round(packet);

			if(this._dialogResult != null)
			{
				if (packet.type == PacketServer.ROUND_RESULTS)
					this._dialogResult.show();
				else
					this._dialogResult.hide();
			}

			clearHintArrows();
		}

		public function get gravity():b2Vec2
		{
			return this.world.GetGravity();
		}

		public function set gravity(value:b2Vec2):void
		{
			this.world.SetGravity(value);
		}

		public function set shift(value:Point):void
		{
			if (int(value.x) == this.map.x && int(value.y) == this.map.y)
				return;

			this.squirrels.x = this.map.foregroundObjects.x = int(value.x);
			this.squirrels.y = this.map.foregroundObjects.y = int(value.y);

			this.map.shift = value;

			if (this.cast)
			{
				this.cast.x = int(value.x);
				this.cast.y = int(value.y);
			}
		}

		public function get shift():Point
		{
			return new Point(this.map.x, this.map.y);
		}

		public function get simulate():Boolean
		{
			return this._simulate;
		}

		public function set simulate(value:Boolean):void
		{
			if (this._simulate == value)
				return;

			this._simulate = value;

			if (!value)
			{
				EnterFrameManager.removeListener(onUpdate);
				return;
			}

			this.lagCounter = 0;
			this.lagWarningShowed = false;

			this.paused = false;

			this.lastUpdate = getTimer();
			this.elapsedTime = 0;

			EnterFrameManager.addListener(onUpdate);

			this.map.build(world);
		}

		public function get paused():Boolean
		{
			return this._paused;
		}

		public function set paused(value:Boolean):void
		{
			if (this._paused == value)
				return;
			this._paused = value;
		}

		public function addHintArrow(name:String, pos:Point, angle:Number):void
		{
			if (name in this.hintArrows)
				return;

			var arrow:ArrowMovie = new ArrowMovie();
			arrow.x = pos.x - 13;
			arrow.y = pos.y;
			arrow.rotation = (angle - 90) / Game.D2R;

			if (contains(arrow)) return;

			addChild(arrow);

			this.hintArrows[name] = arrow;
		}

		public function removeHintArrow(name:String):void
		{
			if (!(name in this.hintArrows))
				return;

			removeChild(this.hintArrows[name]);
			this.hintArrows[name] = null;

			delete this.hintArrows[name];
		}

		public function clearHintArrows():void
		{
			for (var name:String in this.hintArrows)
				removeHintArrow(name);
		}

		public function dispose():void
		{
			FullScreenManager.instance().removeEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
			Logger.add("SquirrelGame.dispose");
			InstanceCounter.onDispose(this);

			this.map.dispose();
			this.map = null;
			Logger.add("SquirrelGame.cast");
			if (this.cast)
				this.cast.dispose();
			this.cast = null;

			Logger.add("SquirrelGame.squirrels");
			if (this.squirrels != null)
				this.squirrels.dispose();

			this.squirrels = null;

			Logger.add("SquirrelGame.world");
			this.world.SetDestructionListener(null);
			this.world.SetContactListener(null);
			this.world.userData = null;

			this.simulate = false;
			this.world = null;

			Logger.add("SquirrelGame.removeChild");
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			Logger.add("SquirrelGame.scriptUtils");
			if (this._scriptUtils)
				this._scriptUtils.dispose();

			Logger.add("SquirrelGame.script");
			if (this.scripts)
				this.scripts.close();

			this._scriptUtils = null;
			this.scripts = null;

			Logger.add("SquirrelGame.sideIcon");
			if (this.sideIcons)
				this.sideIcons.dispose();

			this.sideIcons = null;

			Logger.add("SquirrelGame.camera");
			if (this.camera)
				this.camera.dispose();
			this.camera = null;

			this.contactFilter = null;

			Logger.add("SquirrelGame.DisplayObjectManager.disposeExcess()");
			DisplayObjectManager.getInstance().disposeExcess();

			if (this._dialogResult != null)
				this._dialogResult.hide();

			_instance = null;
		}

		public function update(timeStep:Number):void
		{
			if (!this.simulate)
				return;

			if (this.paused)
			{
				this.elapsedTime = 0;
				return;
			}
			this.elapsedTime += timeStep;

			var simulateTimeStep:Number = USE_FIXED_TIMESTEP ? FIXED_TIMESTEP / this.timescale : elapsedTime;

			if (!this.lagWarningShowed && Game.showLagWarning)
			{
				if (this.elapsedTime > MAX_TIME)
				{
					this.lagCounter += 5;
					FPSCounter.addMark(0x80FF00);
				}
				else
					this.lagCounter--;

				if (elapsedTime > MAX_TIME * 2)
				{
					this.lagCounter += 10;
					FPSCounter.addMark(0xFF0000);
				}
				else
					this.lagCounter -= 2;

				this.lagCounter = (this.lagCounter < 0 ? 0 : this.lagCounter);

				if (this.lagCounter > LAGS_HIGH_BORDER || !ScreenStarling.hardwareAccelerationEnable)
					this.lagWarningShowed = true;
			}

			for (; this.elapsedTime >= simulateTimeStep;)
			{
				try
				{
					this.world.Step(simulateTimeStep * this.timescale, VELOCITY_INTERATION, POSITION_INTERATION);
					this.squirrels.update(simulateTimeStep);
					this.elapsedTime -= simulateTimeStep;
					this.world.ClearForces();
				}
				catch (e: Error)
				{
					Logger.add('SquirrelGame->update: ' + e.message);
				}
			}

			this.map.update(timeStep);

			if (this.cast)
				this.cast.update(timeStep);

			this.camera.update();
		}

		public function onError():void
		{}

		private function onUpdate():void
		{
			var timeStep:Number = (getTimer() - this.lastUpdate) / 1000;
			this.lastUpdate = getTimer();
			update(timeStep);
		}
	}
}