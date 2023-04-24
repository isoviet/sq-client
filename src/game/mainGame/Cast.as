package game.mainGame
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import controllers.ControllerHeroLocal;
	import footers.FooterGame;
	import footers.Footers;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.IShootBattle;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.cast.DragTool;
	import game.mainGame.entity.cast.Hammer;
	import game.mainGame.entity.cast.ICastChange;
	import game.mainGame.entity.cast.ICastDrawable;
	import game.mainGame.entity.cast.ICastRemote;
	import game.mainGame.entity.cast.ICastTool;
	import game.mainGame.entity.joints.JointDrag;
	import game.mainGame.entity.joints.JointRevolute;
	import game.mainGame.entity.joints.JointToBody;
	import game.mainGame.entity.joints.JointToBodyFixed;
	import game.mainGame.entity.joints.JointToBodyMotor;
	import game.mainGame.entity.joints.JointToBodyMotorCCW;
	import game.mainGame.entity.joints.JointToWorld;
	import game.mainGame.entity.joints.JointToWorldFixed;
	import game.mainGame.entity.joints.JointToWorldMotor;
	import game.mainGame.entity.joints.JointToWorldMotorCCW;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.simple.Portal;
	import game.mainGame.events.CastEvent;
	import game.mainGame.gameBattleNet.HeroBattle;
	import screens.ScreenStarling;
	import sounds.GameSounds;

	import interfaces.IDispose;

	import protocol.packages.server.PacketRoomRound;

	import starling.core.Starling;
	import starling.events.Touch;
	import starling.events.TouchEvent;

	import utils.ClassUtil;
	import utils.InstanceCounter;
	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterSprite;

	public class Cast extends StarlingAdapterSprite implements IUpdate
	{
		static private const CAST_TIME:int = 700;
		static private const CAST_ROTATE_DELTA:Number = 10 * (Game.D2R);
		static private const PINS:Array = [JointToWorld, JointToWorldFixed, JointToBody, JointToBodyFixed, JointToBodyMotor, JointToBodyMotorCCW, JointToWorldMotor, JointToWorldMotorCCW];
		static private const PINKEYS:Array = ["C", "V", "B", "N", "M", ",", ".", "/"];

		static private const CAST_HINT_X:Number = 5;
		static private const CAST_HINT_Y:Number = -3;

		static public const CIRCLE_WIDTH:int = 222;

		static public const CAST_CANCEL:String = "cancel";
		static public const CAST_COMPLETE:String = "complete";
		static public const CAST_DROP:String = "drop";

		private var currentRadius:Number = 0;

		protected var listeners:Vector.<Function> = new Vector.<Function>();

		protected var _castRadius:Number = CIRCLE_WIDTH / 2;

		protected var castHint:CastHint = new CastHint();
		protected var object:IGameObject;
		protected var timer:Timer = new Timer(CAST_TIME, 1);
		protected var game:SquirrelGame;

		protected var currentPin:JointRevolute;
		protected var pinPosId:int = -1;

		protected var casting:Boolean = false;
		protected var aimCursor:StarlingAdapterSprite = new StarlingAdapterSprite(new AimCursor());

		public var runCastRadius:Number = CIRCLE_WIDTH / 2;
		public var telekinezRadius:Number = CIRCLE_WIDTH / 2;

		private var eventAnimObject:Boolean = false;
		private var eventMoveObject:Boolean = false;
		private var eventMoveDrawable:Boolean = false;
		private var _localPos: Point = new Point();
		private var _fastCast: Boolean = false;

		public function Cast(game:SquirrelGame):void
		{
			super();
			Logger.add("Cast.Cast");
			InstanceCounter.onCreate(this);

			this.game = game;

			timer = new Timer(CAST_TIME, 1);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCastComplete, false, 0, true);

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);

			setHint();

			Starling.current.stage.addChild(this.castHint.getStarlingView());
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
			changeFullscreen();
		}

		private function changeFullscreen(): void
		{
			this.castHint.getStarlingView().scaleX = this.castHint.getStarlingView().scaleY =
				FullScreenManager.instance().fullScreen ? ScreenStarling.scaleFactorScreen : 1;

			this.castHint.x = CAST_HINT_X;
			this.castHint.y = Footers.FOOTER_OFFSET + CAST_HINT_Y;
		}

		private function onFullScreen(e: Event): void
		{
			changeFullscreen();
		}

		public function round(packet:PacketRoomRound):void
		{
			if (packet) {/*unused*/}

			this.castHint.clearHints();
		}

		public function dispose():void
		{
			aimCursor.removeFromParent();

			Logger.add("Cast.dispose");
			InstanceCounter.onDispose(this);

			this.castHint.clearHints();

			Mouse.show();

			this.listeners = null;
			this.castObject = null;
			this.timer = null;
			this.game = null;

			if (this.castHint) {
				this.castHint.dispose();
				this.castHint.removeFromParent();
			}

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastDrawableComplete);
			FullScreenManager.instance().removeEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingTouch);
		}

		public function set castRadius(value:Number):void
		{
			this._castRadius = value;
			updateRadius();
		}

		public function get radius():Number
		{
			return this.useRunCast ? this.runCastRadius : ((this.castObject != null && this.castObject is DragTool) ? this.telekinezRadius : this._castRadius);
		}

		public function get castRadius():Number
		{
			return this._castRadius;
		}

		public function set castTime(value:Number):void
		{
			this._fastCast = value == 0;
			if (!this.timer)
				return;
			this.timer.reset();
			this.timer.delay = value;
		}

		public function get castTime():Number
		{
			return this.timer.delay;
		}

		public function set castObject(value:IGameObject):void
		{
			if (!Hero.self)
				return;
			if (this.casting)
				onCastCancel();

			if (this.casting)
				return;

			if (this.castObject == value)
				return;

			if (this.castObject != null)
			{
				for each (var listener:Function in this.listeners)
					listener(CAST_DROP);
			}

			if (this.castObject is ICastChange)
				(this.castObject as ICastChange).resetCastParams();

			if (!this.castObject is IStarlingAdapter)
				return;

			if (this.castObject is IShoot)
				resetCursor();

			if (this.castObject != null && this.castObject is IDispose && containsStarling(this.castObject as IStarlingAdapter))
				(this.castObject as IDispose).dispose();

			this.object = value;

			if (this.currentPin != null)
			{
				this.currentPin.dispose();
				this.currentPin = null;
				this.pinPos = -1;
			}

			this.castHint.visible = value != null;
			this.castHint.pinsVisible = this.castHint.visible && ((value is IPinable) || value is BalloonBody);

			if (value != null)
			{
				setLegend();

				if (value is IStarlingAdapter)
					addChildStarling(value as IStarlingAdapter);

				if (value is GameBody)
				{
					(value as GameBody).castType = 0;
					(value as GameBody).playerId = Game.selfId;
				}

				if (value is ICastTool)
					(value as ICastTool).game = this.game;

				if (value is ICastChange)
				{
					(value as ICastChange).cast = this;
					(value as ICastChange).setCastParams();
				}

				Hero.self.showCircle();

				if (value is IShoot)
				{
					if (Hero.self)
					{
						Hero.self.heroView.circle.visible = false;
						value.position = positionWeapon;
					}

					Mouse.hide();
					this.aimCursor = (this.castObject as IShoot).aimCursor;
					addChildStarling(this.aimCursor);
					onAimObject(_localPos);

					if (value is IStarlingAdapter)
						addChildStarling(value as IStarlingAdapter);

					eventAnimObject = true;
				}
				else
				{
					var pos:Point = globalToLocal(new Point(Game.stage.mouseX, Game.stage.mouseY));
					value.position = new b2Vec2(pos.x / Game.PIXELS_TO_METRE, pos.y / Game.PIXELS_TO_METRE);

					eventMoveObject = true;
					Game.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject, false, 0, true);
				}

				Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, onCastStart, false, 0, true);
			}
			else
			{
				if (Hero.self)
					Hero.self.removeCircle();

				resetCursor();

				eventAnimObject = false;
				eventMoveObject = false;

				Game.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject);
				Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastCancel);
			}

			eventMoveDrawable = false;

			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastDrawableComplete);
			onMoveObject(_localPos);
		}

		public function onStarlingTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(ScreenStarling.instance);
			var drawPos: Point;
			// if mouse leave stage
			if (!touch)
				return;

			if (this.castObject is IShoot)
				this._localPos = touch.getLocation(ScreenStarling.instance);
			else
			{
				this._localPos = touch.getLocation(this.getStarlingView());
				if (this.castObject is ICastDrawable)
					drawPos = touch.getLocation(ScreenStarling.instance);
			}

			if (this.eventMoveObject)
				onMoveObject(this._localPos);

			if (this.eventAnimObject)
				onAimObject(this._localPos);

			if (this.eventMoveDrawable)
				onMoveDrawable(drawPos);
		}

		public function get castObject():IGameObject
		{
			return this.object;
		}

		public function onObjectSelect(e:CastEvent):void
		{
			var itemClass:Class = (e.objectId is Class) ? e.objectId : EntityFactory.getEntity(e.objectId) as Class;
			if (itemClass == null)
				return;

			if (this.castObject is itemClass)
			{
				if (this.castObject is IShootBattle && (Hero.self is HeroBattle))
					return;
				dropObject();
				return;
			}

			if (Hero.self is HeroBattle)
			{
				var item:CastItem = Hero.self.castItems.getItem(itemClass, CastItem.TYPE_ROUND);
				if (item == null || item.count <= 0)
					return;
			}
			this.castObject = new itemClass();
			FooterGame.selectShamanElement(e.objectId);
		}

		public function update(timeStep:Number = 0):void
		{
			updateRadius();

			if (this.castObject == null)
				return;

			if (Hero.self && !Hero.selfAlive)
			{
				if (casting)
					onCastCancel();
				dropObject();
				Hero.self.removeCircle();
				return;
			}

			if (!Hero.self && containsStarling(this.aimCursor))
				resetCursor();

			if (this.castObject is GameBody && GameBody(this.castObject).ghost)
				(this.castObject as IStarlingAdapter).alpha = 0.5;
			else
				(this.castObject as IStarlingAdapter).alpha = resolve() ? 1 : 0.5;

			if (this.currentPin != null && !this.casting)
				this.currentPin.update(timeStep);

			if (this.castObject is IUpdate && !this.casting)
				(this.castObject as IUpdate).update(timeStep);

			if (this.castObject is IShoot)
				onAimObject(_localPos);

			if (this.timer && this.timer.running && !resolve())
				onCastCancel();

			updateDragPos();
		}

		public function listen(listener:Function):void
		{
			var index:int = this.listeners.indexOf(listener);

			if (index != -1)
				return;

			this.listeners.push(listener);
		}

		public function forget(listener:Function):void
		{
			var index:int = this.listeners.indexOf(listener);

			if (index == -1)
				return;

			this.listeners.splice(index, 1);
		}

		protected function setHint():void
		{
			this.castHint.setPins(PINS, PINKEYS);
			this.castHint.visible = false;
			this.castHint.x = CAST_HINT_X;
			this.castHint.y = Footers.FOOTER_OFFSET + CAST_HINT_Y;
		}

		protected function onMoveObject(e:*):void
		{
			var x:int = 0;
			var y:int = 0;

			if (e is MouseEvent)
			{
				x = e.stageX;
				y = e.stageY;
			}
			else
			{
				x = e.x;
				y = e.y;
			}
			if (this.castObject == null)
				return;

			var pos:Point = new Point(x, y);
			var worldPos:b2Vec2 = new b2Vec2(pos.x / Game.PIXELS_TO_METRE, pos.y / Game.PIXELS_TO_METRE);
			if (this.castObject is GameBody && GameBody(this.castObject).ghost)
				(this.castObject as IStarlingAdapter).alpha = 0.5;
			else
				(this.castObject as IStarlingAdapter).alpha = resolve() ? 1 : 0.5;

			this.castObject.position = worldPos;
			updateDragPos();
		}

		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (this.casting)
				return;

			var key:int = e.keyCode;

			switch (key)
			{
				case Keyboard.ESCAPE:
				case Keyboard.DELETE:
					dropObject();
					break;
				case Keyboard.Q:
				case Keyboard.E:
					if (this.castObject == null)
						break;

					this.castObject.angle += CAST_ROTATE_DELTA * ((key == Keyboard.Q ? -1 : 0) + (key == Keyboard.E ? 1 : 0));
					break;
				case Keyboard.Z:
					if (this.castObject == null || !(this.castObject is GameBody))
						break;
					(this.castObject as GameBody).ghost = !(this.castObject as GameBody).ghost;

					setLegend();
					break;
				case Keyboard.C:
					setPin(JointToWorld);
					break;
				case Keyboard.V:
					setPin(JointToWorldFixed);
					break;
				case Keyboard.B:
					setPin(JointToBody);
					break;
				case Keyboard.N:
					setPin(JointToBodyFixed);
					break;
				case Keyboard.M:
					setPin(JointToBodyMotor);
					break;
				case Keyboard.COMMA:
					setPin(JointToBodyMotorCCW);
					break;
				case Keyboard.PERIOD:
					setPin(JointToWorldMotor);
					break;
				case Keyboard.SLASH:
					setPin(JointToWorldMotorCCW);
					break;
			}

			if (this.currentPin != null && this.castObject != null)
				this.currentPin.body = (this.castObject as GameBody);
		}

		protected function get pinPos():int
		{
			return this.pinPosId;
		}

		protected function set pinPos(value:int):void
		{
			if (this.castObject == null)
				return;

			this.pinPosId = value;

			if (this.castObject is IPinable && this.pinPosId >= (this.castObject as IPinable).pinPositions.length)
			{
				this.pinPosId = -1;
				this.currentPin.dispose();
				this.currentPin = null;
			}

			if (this.pinPosId > -1 && this.currentPin != null)
				this.currentPin.position = (this.castObject as IPinable).pinPositions[this.pinPosId];
		}

		protected function onRotateObject(e:MouseEvent):void
		{
			this.castObject.angle += e.delta * 2 * (Game.D2R);
		}

		protected function onCastStart(e:MouseEvent):Boolean
		{
			if (!resolve() || !this.castObject)
				return false;

			if (this.castObject is BodyDestructor && !(this.castObject as BodyDestructor).destroyObject)
				return false;

			if (this.castObject is Hammer && !(this.castObject as Hammer).destroyObject)
				return false;

			if (this.castObject is DragTool)
			{
				var dragJoint:JointDrag = (this.castObject as DragTool).dragJoint;
				if (!dragJoint)
					return false;
				else
				{
					var body:GameBody = dragJoint.body;
					if (body == null)
						return false;

					if (this.radius == 0)
						return true;

					var circlePoint:Point = Hero.self.getCirclePosition();

					var point:Point = Hero.self.globalToLocal(dragJoint.localToGlobal(new Point(0, 0))).add(new Point(Hero.self.x, Hero.self.y));
					var lenght:Number = circlePoint.add(new Point(this.radius, this.radius)).subtract(point).length;
					if (lenght >= this.radius)
						return false;
				}
			}

			this.casting = true;

			if (this.castObject is ICastDrawable)
				Game.stage.addEventListener(MouseEvent.MOUSE_UP, onCastDrawableComplete, false, 0, true);
			else
				Game.stage.addEventListener(MouseEvent.MOUSE_UP, onCastCancel, false, 0, true);

			if (this.castObject is ICastTool)
				(this.castObject as ICastTool).onCastStart();
			if (this.currentPin is ICastTool)
				(this.currentPin as ICastTool).onCastStart();

			if (this.castObject is DragTool)
			{
				Hero.self.castStart(0);
				(this.castObject as DragTool).owner = Hero.self;
				return true;
			}

			if (!(this.castObject is IShoot))
			{
				eventMoveObject = false;
				Game.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject);
			}

			Game.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onCastStart);

			ControllerHeroLocal.resetKickTimer();
			this.timer.reset();

			Hero.self.castStart(this.castTime);

			if (this.castObject is ICastDrawable)
			{
				eventMoveDrawable = true;
				if (this.castObject is IStarlingAdapter && (this.castObject as IStarlingAdapter).parentStarling)
					(this.castObject as IStarlingAdapter).parentStarling.removeChildStarling(this.castObject as IStarlingAdapter);
				return true;
			}

			if (this.castTime == 0)
			{
				setTimeout(onCastComplete, 0, null);
				return true;
			}

			GameSounds.play("shaman_spell");

			this.timer.start();

			if (this._fastCast)
				onCastComplete();

			return true;
		}

		protected function onCastCancel(e:MouseEvent = null):void
		{
			this.casting = false;

			for each (var listener:Function in this.listeners)
				listener(CAST_CANCEL);

			if (this.castObject is ICastTool)
				(this.castObject as ICastTool).onCastCancel();

			if (this.currentPin is ICastTool)
				(this.currentPin as ICastTool).onCastCancel();

			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastCancel);

			if (this.castObject is IShoot)
				eventAnimObject = true;
			else
			{
				eventMoveObject = true;
				Game.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject, false, 0, true);
			}

			Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, onCastStart, false, 0, true);

			if (Hero.self)
				Hero.self.castStop(false);

			if (this.timer)
				this.timer.stop();
		}

		protected function onCastComplete(e:TimerEvent = null):void
		{
			this.casting = false;

			for each (var listener:Function in this.listeners)
				listener(CAST_COMPLETE);

			if (this.castObject is ICastTool)
				(this.castObject as ICastTool).onCastComplete();

			if (this.currentPin is ICastTool)
				(this.currentPin as ICastTool).onCastComplete();

			if (this.castObject is ICastChange)
				(this.castObject as ICastChange).resetCastParams();

			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastCancel);

			if (this.castObject == null)
				return;

			GameSounds.playCasted(this.castObject);

			buildCasted();

			this.currentPin = null;
			this.castObject = null;
			this.pinPosId = -1;
			Hero.self.castStop(true);
		}

		protected function onCastDrawableComplete(e:MouseEvent):void
		{
			this.casting = false;

			if (this.castObject is ICastChange)
				(this.castObject as ICastChange).resetCastParams();

			eventMoveDrawable = false;
			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastDrawableComplete);

			if (this.castObject == null)
				return;

			GameSounds.playCasted(this.castObject);

			this.castObject = null;
			Hero.self.castStop(true);
		}

		protected function buildCasted():void
		{
			removeChildStarling(this.castObject as IStarlingAdapter, false);
			this.game.map.add(this.castObject);

			this.castObject.build(this.game.world);

			if (this.currentPin != null)
			{
				this.game.map.add(this.currentPin);
				this.currentPin.build(this.game.world);
			}
		}

		protected function resolve():Boolean
		{
			if (!Hero.self)
				return false;

			if (this.castObject is IShoot)
				return true;

			if (this.radius == 0)
				return true;

			if (!Hero.self.getCirclePosition())
				return false;

			var circlePoint:Point = Hero.self.getCirclePosition();

			if (!this.castObject || !this.castObject.position.x)
				return false;

			var pos:Point = new Point(this.castObject.position.x * Game.PIXELS_TO_METRE, this.castObject.position.y * Game.PIXELS_TO_METRE);
			var length:Number = circlePoint.add(new Point(this.radius, this.radius)).subtract(pos).length;

			if (length < this.radius)
				return true;

			var remoteCasts:Array = this.game.map.get(ICastRemote, true);
			if (remoteCasts.length == 0 || this.castObject is Portal)
				return false;

			for each (var item:ICastRemote in remoteCasts)
			{
				if ((item as IStarlingAdapter).parentStarling == null || item.playerId != Game.selfId || !item.resolve(localToGlobal(pos)))
					continue;

				return true;
			}

			return false;
		}

		protected function dropObject():void
		{
			if (this.timer && this.timer.running)
				return;

			if (this.castObject != null)
			{
				for each (var listener:Function in this.listeners)
					listener(CAST_DROP);

				if (this.castObject is ICastChange)
					(this.castObject as ICastChange).resetCastParams();

				if (this.castObject is IDispose)
					(this.castObject as IDispose).dispose();

				if (containsStarling(this.castObject as IStarlingAdapter))
					removeChildStarling(this.castObject as IStarlingAdapter);
				this.castObject = null;

				FooterGame.unselectShamanElement();
			}

			resetCursor();

			if (this.currentPin != null)
			{
				if (this.currentPin is IDispose)
					(this.currentPin as IDispose).dispose();
				if (containsStarling(this.currentPin as IStarlingAdapter))
					removeChildStarling(this.currentPin as IStarlingAdapter);
				this.pinPosId = -1;
				this.currentPin = null;
			}
		}

		protected function castDrawable():void
		{
			var castedObject:IGameObject = (this.castObject as ICastDrawable).clone();
			this.game.map.add(castedObject);
			castedObject.build(this.game.world);
		}

		private function onAimObject(point:Point):void
		{
			if (!point)
				return;

			if (this.castObject == null || this.casting || !Hero.self || !(this.castObject is IShoot))
				return;

			var pos:Point = globalToLocal(new Point(point.x, point.y));
			var mousePosition:b2Vec2 = new b2Vec2(pos.x / Game.PIXELS_TO_METRE, pos.y / Game.PIXELS_TO_METRE);
			var weaponAngle:Number = Math.atan2(mousePosition.y - Hero.self.position.y, mousePosition.x - Hero.self.position.x);

			this.castObject.angle = weaponAngle;
			this.castObject.position = positionWeapon;
			(this.castObject as IShoot).onAim(pos);
			(this.castObject as GameBody).linearVelocity = new b2Vec2(Math.cos(weaponAngle) * (this.castObject as IShoot).maxVelocity, Math.sin(weaponAngle) * (this.castObject as IShoot).maxVelocity);

			if (this.castObject is GameBody && GameBody(this.castObject).ghost)
				(this.castObject as IStarlingAdapter).alpha = 0.5;
			else
				(this.castObject as IStarlingAdapter).alpha = resolve() ? 1 : 0.5;

			if (!isGameObject(this.castObject as IStarlingAdapter))
			{
				if (this.aimCursor.visible == true)
				{
					this.aimCursor.visible = false;
					Mouse.show();
				}
			}
			else
			{
				if (this.aimCursor.visible == false)
				{
					this.aimCursor.visible = true;
					Mouse.hide();
				}
			}
		}

		private function isGameObject(object:IStarlingAdapter):Boolean
		{
			if (object.parentStarling is SquirrelGame)
				return true;
			if (object.parentStarling == Game.gameSprite || object.parentStarling == null)
				return false;
			return isGameObject(object.parentStarling);
		}

		private function get positionWeapon():b2Vec2
		{
			if (!Hero.self)
				return null;
			return Hero.self.position.Copy();
		}

		private function get avaliblePins():Array
		{
			var result:Array = [[], []];

			if (this.castObject is BalloonBody)
				return [[PINS[0]], [PINKEYS[0]]];

			var i:int = 0;
			for each (var pinClass:Class in PINS)
			{
				if (isPinAvalible(pinClass))
				{
					result[0].push(PINS[i]);
					result[1].push(PINKEYS[i]);
				}
				i++;
			}
			return result;
		}

		private function setPin(pinClass:Class):void
		{
			if (this.castObject is BalloonBody && pinClass == JointToWorld)
			{
				(this.castObject as BalloonBody).ropeEnabled = !(this.castObject as BalloonBody).ropeEnabled;
				return;
			}

			if (!isPinAvalible(pinClass))
				return;
			if (this.castObject == null || !(this.castObject is IPinable))
				return;

			var pinChanged:Boolean = !(getQualifiedClassName(this.currentPin) == getQualifiedClassName(pinClass));

			if (pinChanged)
			{
				if (this.currentPin != null)
					this.currentPin.dispose();
				this.currentPin = new pinClass();
				this.currentPin.world = this.game.world;
				this.pinPos = this.pinPos;
				if (pinPos == -1)
					pinPos = 0;
			}
			else
				pinPos++;
		}

		private function setLegend():void
		{
			var pins:Array = avaliblePins;
			this.castHint.canGhost = this.castObject is GameBody;
			this.castHint.isGhost = this.castHint.canGhost && (this.castObject as GameBody).ghost;
			this.castHint.setPins(pins[0], pins[1]);
		}

		private function isPinAvalible(pinClass:Class):Boolean
		{
			if (ClassUtil.isImplement(pinClass, "ISaveInvert"))
				return this.game.map.shamanTools.indexOf(EntityFactory.getId(pinClass)) == -1;
			else
				return this.game.map.shamanTools.indexOf(EntityFactory.getId(pinClass)) != -1;
		}

		private function updateDragPos():void
		{
			if (!(this.castObject is DragTool) || this.resolve() || !this.casting || !Hero.self)
				return;

			var dir:b2Vec2 = b2Math.SubtractVV(Hero.self.position, this.castObject.position);
			dir.Normalize();
			dir.Multiply(-this.radius / Game.PIXELS_TO_METRE);
			dir.Add(Hero.self.position);
			this.castObject.position = dir;
		}

		private function get useRunCast():Boolean
		{
			return Hero.self && Hero.self.heroView.running && Hero.self.useRunningCast;
		}

		private function updateRadius():void
		{
			var radius:Number = this.radius;
			if (radius == this.currentRadius)
				return;

			this.currentRadius = radius;

			if (!Hero.self)
				return;

			Hero.self.heroView.circle.visible = ((this.castObject != null || !Hero.self.hideCircle) && this.currentRadius != 0);
			if (this.currentRadius == 0)
				return;
			Hero.self.setCircleWidth(this.currentRadius * 2);
		}

		private function resetCursor():void
		{
			if (!containsStarling(this.aimCursor))
				return;

			removeChildStarling(this.aimCursor, false);
			Mouse.show();
		}

		private function onMoveDrawable(drawPoint: Point):void
		{
			if (!drawPoint || this.castObject == null || !(this.castObject is ICastDrawable))
				return;

			var pos:Point = globalToLocal(new Point(drawPoint.x, drawPoint.y));
			var worldPos:b2Vec2 = new b2Vec2(pos.x / Game.PIXELS_TO_METRE, pos.y / Game.PIXELS_TO_METRE);

			this.castObject.position = worldPos;

			if (!resolve())
				return;

			if (!(this.castObject as ICastDrawable).resolve())
				return;

			castDrawable();
		}
	}
}