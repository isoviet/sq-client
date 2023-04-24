package game.mainGame.entity.cast
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.ISerialize;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.joints.JointDrag;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.gameNet.CastNet;
	import screens.ScreenStarling;

	import interfaces.IDispose;

	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.starling.StarlingAdapterSprite;

	public class DragTool extends StarlingAdapterSprite implements ICastTool, IGameObject, IDispose, ISerialize
	{
		static public const DEFAULT_DRAG_COLOR:int = 0xFFFFFF;

		static private const FILTER:GlowFilter = new GlowFilter(0x9AFF00, 1, 12, 12, 2);
		static private const SEND_DELAY:int = 1 * 1000;

		private var _dragJoint:JointDrag = null;
		private var _game:SquirrelGame;
		private var casting:Boolean;
		private var posQueue:Array = [];
		private var sendTimer:Timer = new Timer(SEND_DELAY);

		private var _owner:Hero;

		private var lastMousePosition: Point = new Point(0,0);

		public function DragTool():void
		{
			sendTimer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			sendTimer.start();
			Game.stage.addEventListener(Event.ENTER_FRAME, onDraw, false, 0, true);

			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingMOVE);
			this.touchable = false;
		}

		public function onStarlingMOVE(event:TouchEvent): void {
			var touch:Touch = event.getTouch(ScreenStarling.instance);
			// if mouse leave stage
			if(!touch)
				return;

			var localPos:Point = touch.getLocation(ScreenStarling.instance);

			if (lastMousePosition == localPos) return;

			lastMousePosition = localPos;
			if (this._game && this._game.map) {
				for each(var joint:JointDrag in this._game.map.get(JointDrag)) {
					var point: Point = joint.globalToLocal(localPos);

					if (point.x < -5 || point.x > 5 || point.y < -5 || point.y > 5)
						continue;

					this.dragJoint = joint;
					break;
				}
			}
			if (touch.phase == TouchPhase.BEGAN) {

			} else if (touch.phase == TouchPhase.ENDED) {
				this.dragJoint = null;
			} else if (touch.phase == TouchPhase.MOVED) {
			}
			redraw();
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;

			if (!this._game || !this._game.map)
				return;

			if (this.casting)
			{
				if (this.dragJoint == null)
					return;

				if (this.owner && this.owner.isSelf)
				{
					var dir:b2Vec2 = b2Math.SubtractVV(owner.position, value);
					if ((dir.Length() - _game.cast.radius / Game.PIXELS_TO_METRE) > 0.01)
					{
						dir.Normalize();
						dir.Multiply(-_game.cast.radius / Game.PIXELS_TO_METRE);
						dir.Add(owner.position);
						this.position = dir;
					}
				}

				this.dragJoint.active = true;
				this.dragJoint.toPos = this.position;

				if (this.dragJoint.toPos.x != this.position.y || this.dragJoint.toPos.y != this.position.y)
				{
					var data:Array = [getTimer(), [this.position.x, this.position.y]];
					this.posQueue.push(data);
				}
				onTimer();
			}

		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function build(world:b2World):void
		{}

		public function set game(value:SquirrelGame):void
		{
			_game = value;
		}

		public function get dragJoint():JointDrag
		{
			return _dragJoint;
		}

		public function set dragJoint(value:JointDrag):void
		{
			if (_dragJoint == value)
				return;

			if (_dragJoint != null)
			{
				_dragJoint.active = false;
			}

			_dragJoint = value;
		}

		public function get owner():Hero
		{
			return this._owner;
		}

		public function set owner(value:Hero):void
		{
			this._owner = value;

			if (this._owner == null)
				return;

			this._owner.addEventListener(HollowEvent.HOLLOW, onHollow);
		}

		public function onCastStart():void
		{
			this.casting = true;
			if (this.dragJoint)
				this.dragJoint.active = this.casting;
			this.sendTimer.reset();
			this.sendTimer.start();
		}

		public function onCastCancel():void
		{
			onTimer();

			this.casting = false;
			if (this.dragJoint)
				this.dragJoint.active = this.casting;
			this.posQueue = [];

			this.position = this.position;
			this.sendTimer.stop();
		}

		public function onCastComplete():void
		{
			onTimer();
			this.casting = false;

			if (this.dragJoint)
				this.dragJoint.active = this.casting;

			this.posQueue = [];
			this.sendTimer.stop();
		}

		public function dispose():void
		{
			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingMOVE);

			this.game = null;
			this.dragJoint = null;

			if (this.owner != null)
				this.owner.removeEventListener(HollowEvent.HOLLOW, onHollow);

			this.owner = null;

			if (this.parentStarling)
				this.parentStarling.removeChildStarling(this);

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			this.removeFromParent(true);

			Game.stage.removeEventListener(Event.ENTER_FRAME, onDraw);
		}

		public function serialize():*
		{
			if (this.posQueue.length == 0)
				this.posQueue.push([getTimer(), [this.position.x, this.position.y]]);

			var result:Array = [this.casting, this._game.map.getID(this._dragJoint), posQueue];
			this.posQueue = [];
			return result;
		}

		public function deserialize(data:*):void
		{
			if (data[1] == -1 && this._game && this._game.map)
				return;
			this.dragJoint = this._game.map.getObject(data[1]) as JointDrag;

			if (this.dragJoint != null)
			{
				this.dragJoint.active = Boolean(data[0]);

				this.casting = Boolean(data[0]);

				this.position = new b2Vec2(data[2][0][1][0], data[2][0][1][1]);
				if (this.dragJoint.posQueue)
					this.dragJoint.posQueue = data[2];
			}
		}

		private function onHollow(e:HollowEvent):void
		{
			dispose();
		}

		private function onTimer(e:TimerEvent = null):void
		{
			if (this._game == null)
				return;

			if (!(this._game.cast is CastNet))
				return;

			if (!Hero.self || this.owner != Hero.self)
				return;

			if (!this.casting)
				return;

			if (this.posQueue.length == 0)
				return;

			(this._game.cast as CastNet).sendData();
		}

		private function redraw():void
		{
			var graph: Shape = new Shape();

			while (numChildren > 0)
				removeChildStarlingAt(0, true);

			graph.graphics.clear();
			graph.graphics.beginFill(0xFFFFFF, 0.2);
			graph.graphics.drawCircle(0, 0, 10);
			graph.graphics.endFill();
			graph.filters = [FILTER];

			var sprGraph: StarlingAdapterSprite = new StarlingAdapterSprite(graph);
			sprGraph.touchable = false;
			addChildStarling(sprGraph);

			if (!owner || !dragJoint || !this.casting)
				return;

			var heroPos:Point = owner.localToGlobal(new Point(owner.heroView.direction ? -20 : 20, -20));
			heroPos = this.globalToLocal(heroPos);

			var pointPos:Point = this.globalToLocal(dragJoint.localToGlobal(new Point(0, 0)));

			graph.graphics.lineStyle(5, this.owner.telekinesisColor, 0.7);

			graph.graphics.moveTo(heroPos.x, heroPos.y);
			graph.graphics.curveTo(0, 0, pointPos.x, pointPos.y);
			graph.graphics.lineStyle();
			var spr: StarlingAdapterSprite = new StarlingAdapterSprite(graph);

			spr.touchable = false;

			addChildStarling(spr);

			this.touchable = false;
		}

		private function onDraw(e:Event):void
		{
			redraw();
		}
	}
}